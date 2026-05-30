import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'o_core.dart';

const _presetColors = [
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.teal,
  Colors.cyan,
  Colors.green,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.red,
  Colors.pink,
  Colors.blueGrey,
];

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Theme mode
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(l10n.appearance, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.primary)),
          ),
          Consumer<ThemeSettings>(
            builder: (context, theme, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 0, label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.followSystem)), icon: const Icon(Icons.phone_android_rounded)),
                    ButtonSegment(value: 1, label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.light)), icon: const Icon(Icons.light_mode_rounded)),
                    ButtonSegment(value: 2, label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.dark)), icon: const Icon(Icons.dark_mode_rounded)),
                  ],
                  selected: {theme.themeMode.index},
                  onSelectionChanged: (Set<int> selected) {
                    theme.setThemeMode(ThemeMode.values[selected.first]);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Seed color
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(l10n.themeColor, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.primary)),
          ),
          Consumer<ThemeSettings>(
            builder: (context, theme, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _presetColors.map((color) {
                    final selected = theme.seedColor.toARGB32() == color.toARGB32();
                    return GestureDetector(
                      onTap: () => theme.setSeedColor(color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: colorScheme.onSurface, width: 3)
                              : null,
                          boxShadow: selected
                              ? [BoxShadow(color: color.withAlpha(100), blurRadius: 8, spreadRadius: 1)]
                              : null,
                        ),
                        child: selected
                            ? Icon(Icons.check_rounded, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 24)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Language
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(l10n.language, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.primary)),
          ),
          Consumer<ThemeSettings>(
            builder: (context, theme, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 0, label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.followSystem)), icon: const Icon(Icons.phone_android_rounded)),
                    ButtonSegment(value: 1, label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.chinese))),
                    ButtonSegment(value: 2, label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.english))),
                  ],
                  selected: {
                    theme.locale == null
                        ? 0
                        : theme.locale!.languageCode == 'zh'
                            ? 1
                            : 2
                  },
                  onSelectionChanged: (Set<int> selected) {
                    final value = selected.first;
                    theme.setLocale(value == 0 ? null : Locale(value == 1 ? 'zh' : 'en'));
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
