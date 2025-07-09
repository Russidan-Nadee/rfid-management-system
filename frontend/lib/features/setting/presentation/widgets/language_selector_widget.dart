// Path: frontend/lib/features/setting/presentation/widgets/language_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_state.dart';
import '../bloc/settings_event.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoaded || state is SettingsUpdating) {
          final settings = state is SettingsLoaded
              ? state.settings
              : (state as SettingsUpdating).settings;
          return _buildLanguageSelector(context, settings);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context, settings) {
    final theme = Theme.of(context);
    final currentLanguage = settings.language;

    return Card(
      elevation: 1,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildLanguageOption(
            context,
            '🇺🇸',
            'EN',
            'English',
            'en',
            currentLanguage == 'en',
          ),
          const Divider(height: 1),
          _buildLanguageOption(
            context,
            '🇹🇭',
            'TH',
            'ไทย',
            'th',
            currentLanguage == 'th',
          ),
          const Divider(height: 1),
          _buildLanguageOption(
            context,
            '🇯🇵',
            'JA',
            '日本語',
            'ja',
            currentLanguage == 'ja',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String flag,
    String code,
    String name,
    String languageCode,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    // แก้สีให้แตกต่างกันระหว่าง Light และ Dark Mode
    final trailingIconColor = isSelected
        ? (Theme.of(context).brightness == Brightness.dark
              ? theme
                    .colorScheme
                    .onSurface // Dark Mode: สีขาว
              : theme.colorScheme.primary) // Light Mode: สีน้ำเงิน
        : null;

    return ListTile(
      title: _buildLanguageTitle(context, flag, code, name, isSelected),
      trailing: isSelected ? Icon(Icons.check, color: trailingIconColor) : null,
      onTap: isSelected
          ? null
          : () {
              _changeLanguage(context, languageCode);
            },
    );
  }

  Widget _buildLanguageTitle(
    BuildContext context,
    String flag,
    String code,
    String name,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    // แก้สีให้แตกต่างกันระหว่าง Light และ Dark Mode
    final textColor = isSelected
        ? (Theme.of(context).brightness == Brightness.dark
              ? theme.colorScheme.onSurface
              : theme.colorScheme.primary)
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Row(
      children: [
        Text(flag, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Text(
          code,
          style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
        ),
        const SizedBox(width: 12),
        Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
      ],
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    // เรียกใช้ SettingsBloc เพื่อเปลี่ยนภาษา
    context.read<SettingsBloc>().add(UpdateLanguage(languageCode));

    // แสดง SnackBar ยืนยันการเปลี่ยนภาษา
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to: $languageCode'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
