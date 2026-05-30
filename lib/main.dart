import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'o_core.dart';
import 'settings_page.dart';
import 'sync_card.dart';
import 'log_card.dart';
import 'account_card.dart';
import 'task_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const OSynk());
}

ThemeData buildTheme(Color seedColor, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, scrolledUnderElevation: 1),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
  );
}

class OSynk extends StatelessWidget {
  const OSynk({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeSettings()),
        ChangeNotifierProvider(create: (_) => SyncTaskRepository()),
        ChangeNotifierProvider(create: (_) => SyncLogRepository()),
        ChangeNotifierProxyProvider3<ThemeSettings, SyncTaskRepository, SyncLogRepository, OCore>(
          create: (context) => OCore(
            themeSettings: context.read<ThemeSettings>(),
            taskRepo: context.read<SyncTaskRepository>(),
            logRepo: context.read<SyncLogRepository>(),
          ),
          update: (context, theme, tasks, logs, oCore) => oCore!,
        ),
      ],
      child: Consumer2<ThemeSettings, OCore>(
        builder: (context, theme, oCore, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: theme.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: theme.themeMode,
              theme: buildTheme(theme.seedColor, Brightness.light),
              darkTheme: buildTheme(theme.seedColor, Brightness.dark),
              home: const HomePage(),
            ),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (locale != _lastLocale) {
      _lastLocale = locale;
      final l10n = AppLocalizations.of(context)!;
      context.read<OCore>().setNotificationStrings(
        syncing: l10n.notifSyncing,
        complete: l10n.notifComplete,
        failed: l10n.notifFailed,
        channelName: l10n.notifChannelName,
        channelDesc: l10n.notifChannelDesc,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Osynk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
        children: const [
          SyncCard(),
          SizedBox(height: 12),
          LogCard(),
          SizedBox(height: 12),
          AccountCard(),
          SizedBox(height: 12),
          TaskCard(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
