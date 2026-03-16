import 'package:flutter/material.dart';

/// A toggle / switch row in the settings screen.
class SettingsToggleTile extends StatelessWidget {
  const SettingsToggleTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      secondary: icon != null ? Icon(icon) : null,
      value: value,
      onChanged: onChanged,
    );
  }
}
