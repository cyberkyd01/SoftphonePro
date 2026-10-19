import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'basic_widgets.dart';

/// Rounded card containing settings rows.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children, this.footer});
  final String? title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) SectionHeader(title!) else const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1) const Divider(height: 1, indent: 16),
                ],
              ],
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(footer!, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          ),
      ],
    );
  }
}

class SwitchTile extends StatelessWidget {
  const SwitchTile({super.key, required this.title, this.subtitle, required this.value, required this.onChanged, this.icon});
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      value: value,
      onChanged: onChanged,
    );
  }
}

class SelectTile<T> extends StatelessWidget {
  const SelectTile({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.subtitle,
    this.icon,
  });
  final String title;
  final String? subtitle;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 190),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: options.containsKey(value) ? value : null,
            isExpanded: true,
            borderRadius: BorderRadius.circular(12),
            style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurface),
            items: [
              for (final e in options.entries) DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }
}

/// Tile that edits a text value in a dialog.
class TextTile extends StatelessWidget {
  const TextTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.icon,
    this.validator,
  });
  final String title;
  final String? subtitle;
  final String value;
  final String? hint;

  /// Returns an error message for an invalid value, or null when valid.
  final String? Function(String)? validator;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final shown = obscure && value.isNotEmpty ? '••••••••' : value;
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: Text(
        shown.isEmpty ? (hint ?? subtitle ?? context.l10n.commonNotSet) : shown,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.edit_outlined, size: 18),
      onTap: () async {
        final r = await promptText(
          context,
          title: title,
          initial: value,
          hint: hint,
          obscure: obscure,
          keyboardType: keyboardType,
          helper: subtitle,
          validator: validator,
        );
        if (r != null) onChanged(r);
      },
    );
  }
}

class SliderTile extends StatelessWidget {
  const SliderTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.format,
    this.icon,
  });
  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? format;
  final ValueChanged<double> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: format?.call(value),
        onChanged: onChanged,
      ),
      trailing: Text(format?.call(value) ?? value.toStringAsFixed(1)),
    );
  }
}

class NavTile extends StatelessWidget {
  const NavTile({super.key, required this.title, this.subtitle, required this.onTap, this.icon, this.trailing});
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

Future<String?> promptText(
  BuildContext context, {
  required String title,
  String initial = '',
  String? hint,
  String? helper,
  bool obscure = false,
  TextInputType? keyboardType,
  int maxLines = 1,
  String? Function(String)? validator,
}) {
  final ctl = TextEditingController(text: initial);
  String? error;
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) {
        void submit(String raw) {
          final v = raw.trim();
          final e = validator?.call(v);
          if (e != null) {
            setLocal(() => error = e);
            return;
          }
          Navigator.pop(ctx, v);
        }

        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctl,
            autofocus: true,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLines: obscure ? 1 : maxLines,
            textDirection: keyboardType == TextInputType.number || keyboardType == TextInputType.phone ? TextDirection.ltr : null,
            decoration: InputDecoration(hintText: hint, helperText: helper, helperMaxLines: 3, errorText: error, errorMaxLines: 3),
            onChanged: (_) {
              if (error != null) setLocal(() => error = null);
            },
            onSubmitted: submit,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.l10n.actionCancel)),
            FilledButton(onPressed: () => submit(ctl.text), child: Text(ctx.l10n.actionSave)),
          ],
        );
      },
    ),
  );
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = true,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(ctx.l10n.actionCancel)),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error) : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel ?? ctx.l10n.actionDelete),
        ),
      ],
    ),
  );
  return r ?? false;
}
