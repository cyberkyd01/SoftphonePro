#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#include <string.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

// Method channel shared with lib/platform/desktop/desktop_channel.dart:
//   Dart -> native  "ready"   => {"pending": [String...], "launchedAtLogin": false}
//   native -> Dart  "onArgs"  <= String: a later launch's argv (without argv[0]) joined with
//                                "\n"; "--show" when it had no arguments.
// Payloads that arrive before Dart called "ready" are queued and returned in "pending".
static const char kDesktopChannelName[] = "softphonepro/desktop";
static const char kWindowTitle[] = "SoftphonePro";

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  GtkWindow* window;
  FlMethodChannel* channel;
  gboolean dart_ready;
  GPtrArray* pending;  // char* payloads received before Dart was ready
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Sends |payload| to Dart, or queues it until Dart called "ready".
static void my_application_deliver(MyApplication* self, const gchar* payload) {
  if (g_getenv("SOFTPHONEPRO_DEBUG_DESKTOP") != nullptr) {
    g_message("desktop channel: onArgs %s: %s", self->dart_ready ? "sent" : "queued", payload);
  }
  if (self->dart_ready && self->channel != nullptr) {
    fl_method_channel_invoke_method(self->channel, "onArgs",
                                    fl_value_new_string(payload), nullptr,
                                    nullptr, nullptr);
  } else {
    g_ptr_array_add(self->pending, g_strdup(payload));
  }
}

static void desktop_method_call_cb(FlMethodChannel* channel,
                                   FlMethodCall* method_call,
                                   gpointer user_data) {
  MyApplication* self = MY_APPLICATION(user_data);
  g_autoptr(FlMethodResponse) response = nullptr;
  if (strcmp(fl_method_call_get_name(method_call), "ready") == 0) {
    g_autoptr(FlValue) pending = fl_value_new_list();
    for (guint i = 0; i < self->pending->len; i++) {
      fl_value_append_take(
          pending,
          fl_value_new_string(
              static_cast<const gchar*>(g_ptr_array_index(self->pending, i))));
    }
    g_ptr_array_set_size(self->pending, 0);
    self->dart_ready = TRUE;
    g_autoptr(FlValue) result = fl_value_new_map();
    fl_value_set_string(result, "pending", pending);
    fl_value_set_string_take(result, "launchedAtLogin",
                             fl_value_new_bool(FALSE));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  g_autoptr(GError) error = nullptr;
  if (!fl_method_call_respond(method_call, response, &error)) {
    g_warning("Failed to send desktop channel response: %s", error->message);
  }
}

// Window icon: the themed icon once installed (.deb), otherwise the PNG shipped in the
// bundle's data directory (tarball, or running straight from the build output).
static void my_application_set_window_icon(GtkWindow* window) {
  g_autofree gchar* exe = g_file_read_link("/proc/self/exe", nullptr);
  if (exe != nullptr) {
    g_autofree gchar* dir = g_path_get_dirname(exe);
    g_autofree gchar* png =
        g_build_filename(dir, "data", APPLICATION_ID ".png", nullptr);
    if (g_file_test(png, G_FILE_TEST_EXISTS)) {
      g_autoptr(GError) error = nullptr;
      if (!gtk_window_set_default_icon_from_file(png, &error)) {
        g_warning("Failed to load window icon %s: %s", png, error->message);
      }
    }
  }
  GtkIconTheme* theme = gtk_icon_theme_get_default();
  if (gtk_icon_theme_has_icon(theme, APPLICATION_ID)) {
    gtk_window_set_icon_name(window, APPLICATION_ID);
  }
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  if (self->window != nullptr) {
    // Already running; later launches are reported to Dart through "onArgs".
    return;
  }
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, kWindowTitle);
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, kWindowTitle);
  }

  gtk_window_set_default_size(window, 1200, 780);
  my_application_set_window_icon(window);
  self->window = window;
  g_object_add_weak_pointer(G_OBJECT(window),
                            reinterpret_cast<gpointer*>(&self->window));
  // Realize only: Dart (window_manager) decides when to show the window so that a
  // "--minimized" start does not flash a window.
  gtk_widget_realize(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  FlBinaryMessenger* messenger =
      fl_engine_get_binary_messenger(fl_view_get_engine(view));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_clear_object(&self->channel);
  self->channel = fl_method_channel_new(messenger, kDesktopChannelName,
                                        FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      self->channel, desktop_method_call_cb, self, nullptr);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line. Runs in every process, before the
// application registers on the session bus: remember this process's own arguments as the Dart
// entrypoint arguments (like the Flutter template), then let GApplication continue. It either
// becomes the primary instance (command_line below, is_remote == FALSE) or forwards argv to the
// primary and exits. Without a session bus it simply runs as a non-unique instance.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);
  return FALSE;
}

// Implements GApplication::command_line (HANDLES_COMMAND_LINE).
static int my_application_command_line(GApplication* application, GApplicationCommandLine* command_line) {
  MyApplication* self = MY_APPLICATION(application);
  if (!g_application_command_line_get_is_remote(command_line)) {
    // The primary's own launch: its arguments already are the Dart entrypoint arguments.
    g_application_activate(application);
    return 0;
  }

  // A later launch: forward argv (without argv[0]) to Dart.
  gint argc = 0;
  g_auto(GStrv) argv = g_application_command_line_get_arguments(command_line, &argc);
  g_autofree gchar* payload = nullptr;
  if (argc > 1) {
    payload = g_strjoinv("\n", argv + 1);
  } else {
    payload = g_strdup("--show");
  }
  my_application_deliver(self, payload);
  return 0;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_object(&self->channel);
  g_clear_pointer(&self->pending, g_ptr_array_unref);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->command_line = my_application_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {
  self->pending = g_ptr_array_new_with_free_func(g_free);
}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  //
  // SoftphonePro keeps the program name (= X11 WM_CLASS) equal to the binary name so that the
  // desktop file's StartupWMClass=softphonepro matches; GTK uses the application ID below as the
  // Wayland app_id, which matches the desktop file ID.
  g_set_prgname("softphonepro");

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_HANDLES_COMMAND_LINE,
                                     nullptr));
}
