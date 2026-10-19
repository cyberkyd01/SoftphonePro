#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/encodable_value.h>

#include <memory>
#include <string>
#include <vector>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

  // When true the window is not shown on the first frame (autostart with
  // --minimized); Dart decides whether to show it.
  void SetStartHidden(bool hidden) { start_hidden_ = hidden; }

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  // "softphonepro/desktop": forwards command lines of later launches.
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
  bool dart_ready_ = false;
  bool start_hidden_ = false;
  std::vector<std::string> pending_args_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
