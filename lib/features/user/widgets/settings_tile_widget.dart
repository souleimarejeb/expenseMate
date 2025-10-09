// settings_tile_widget.dart
import 'package:flutter/material.dart';

class SettingsTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool showDivider;
  final bool isEnabled;

  const SettingsTileWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.showDivider = true,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        ListTile(
          enabled: isEnabled,
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? theme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? theme.primaryColor,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isEnabled ? null : Colors.grey,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                  ),
                )
              : null,
          trailing: trailing,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: Colors.grey[300],
          ),
      ],
    );
  }
}

// Toggle Settings Tile
class ToggleSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;
  final bool showDivider;
  final bool isEnabled;

  const ToggleSettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconColor,
    this.showDivider = true,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsTileWidget(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      showDivider: showDivider,
      isEnabled: isEnabled,
      trailing: Switch(
        value: value,
        onChanged: isEnabled ? onChanged : null,
        activeColor: Theme.of(context).primaryColor,
      ),
      onTap: isEnabled ? () => onChanged(!value) : null,
    );
  }
}

// Selection Settings Tile
class SelectionSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String currentValue;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final Color? iconColor;
  final bool showDivider;
  final bool isEnabled;

  const SelectionSettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.currentValue,
    required this.options,
    required this.onChanged,
    this.iconColor,
    this.showDivider = true,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsTileWidget(
      icon: icon,
      title: title,
      subtitle: currentValue,
      iconColor: iconColor,
      showDivider: showDivider,
      isEnabled: isEnabled,
      trailing: const Icon(Icons.chevron_right),
      onTap: isEnabled ? () => _showSelectionDialog(context) : null,
    );
  }

  void _showSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: currentValue,
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

// Slider Settings Tile
class SliderSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? valueFormatter;
  final Color? iconColor;
  final bool showDivider;
  final bool isEnabled;

  const SliderSettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.valueFormatter,
    this.iconColor,
    this.showDivider = true,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedValue = valueFormatter?.call(value) ?? value.toStringAsFixed(1);
    
    return Column(
      children: [
        ListTile(
          enabled: isEnabled,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isEnabled ? null : Colors.grey,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                  ),
                )
              : null,
          trailing: Text(
            formattedValue,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isEnabled ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: isEnabled ? onChanged : null,
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.grey[300],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[300],
          ),
      ],
    );
  }
}

// Action Settings Tile
class ActionSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showDivider;
  final bool isEnabled;
  final bool isDangerous;

  const ActionSettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.showDivider = true,
    this.isEnabled = true,
    this.isDangerous = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = isDangerous 
        ? Colors.red 
        : iconColor ?? Theme.of(context).primaryColor;
    
    final effectiveTextColor = isDangerous 
        ? Colors.red 
        : textColor;

    return SettingsTileWidget(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: effectiveIconColor,
      showDivider: showDivider,
      isEnabled: isEnabled,
      onTap: onTap,
      trailing: Icon(
        Icons.chevron_right,
        color: isEnabled ? effectiveTextColor : Colors.grey,
      ),
    );
  }
}

// Settings Section Header
class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final EdgeInsets padding;

  const SettingsSectionHeader({
    Key? key,
    required this.title,
    this.icon,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}