import 'package:flutter/material.dart';

/// A tile that shows a label + current value and opens a selection dialog.
class SettingsSelectTile<T> extends StatelessWidget {
  const SettingsSelectTile({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    this.icon,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      subtitle: Text(subtitle ?? labelOf(value)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDialog(context),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog<T>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: options.map((opt) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, opt),
            child: Row(
              children: [
                if (opt == value)
                  Icon(
                    Icons.check,
                    size: 20,
                    color: Theme.of(ctx).colorScheme.primary,
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(labelOf(opt)),
              ],
            ),
          );
        }).toList(),
      ),
    ).then((selected) {
      if (selected != null) onChanged(selected);
    });
  }
}
