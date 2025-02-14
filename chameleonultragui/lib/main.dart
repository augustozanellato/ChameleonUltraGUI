import 'dart:io';
import 'package:chameleonultragui/connector/serial_abstract.dart';
import 'package:chameleonultragui/gui/flashing.dart';
import 'package:chameleonultragui/gui/mfkey32page.dart';
import 'package:chameleonultragui/gui/readcardpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Comms Imports
import 'connector/serial_mobile.dart';
import 'connector/serial_native.dart';

// GUI Imports
import 'gui/homepage.dart';
import 'gui/savedcardspage.dart';
import 'gui/settingspage.dart';
import 'gui/connectpage.dart';
import 'gui/devpage.dart';
import 'gui/slotmanagerpage.dart';

// Shared Preferences Provider
import 'sharedprefsprovider.dart';

// Logger
import 'package:logger/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferencesProvider = SharedPreferencesProvider();
  await sharedPreferencesProvider.load();
  runApp(MyApp(sharedPreferencesProvider));
}

class MyApp extends StatelessWidget {
  // Root Widget
  final SharedPreferencesProvider _sharedPreferencesProvider;
  const MyApp(this._sharedPreferencesProvider, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _sharedPreferencesProvider),
        ChangeNotifierProvider(
          create: (context) => MyAppState(_sharedPreferencesProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Chameleon Ultra GUI', // App Name
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor:
                  _sharedPreferencesProvider.getThemeColor()), // Color Scheme
          brightness: Brightness.light, // Light Theme
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: _sharedPreferencesProvider.getThemeColor(),
              brightness: Brightness.dark), // Color Scheme
          brightness: Brightness.dark, // Dark Theme
        ),
        themeMode: _sharedPreferencesProvider.getTheme(), // Dark Theme
        home: const MyHomePage(),
      ),
    );

    //return ChangeNotifierProvider(
    //  create: (context) => MyAppState(),
    //  child:
    //);
  }
}

class MyAppState extends ChangeNotifier {
  final SharedPreferencesProvider sharedPreferencesProvider;
  MyAppState(this.sharedPreferencesProvider);
  // State
  bool onAndroid =
      Platform.isAndroid; // Are we on android? (mostly for serial port)
  AbstractSerial connector = Platform.isAndroid
      ? MobileSerial()
      : NativeSerial(); // Chameleon Object, connected Chameleon
  bool switchOn = true;
  bool devMode = false;
  double? progress;
  // Flashing Easteregg
  bool easteregg = false;

  /*void toggleswitch() {
    setState(() {
      switchOn = !switchOn;
    })
  }
  // This doesn't work because we aren't working stateful
  */
  // maybe via this: https://www.woolha.com/tutorials/flutter-switch-input-widget-example or this https://dev.to/naidanut/adding-expandable-side-bar-using-navigationrail-in-flutter-5ai8
  Logger log = Logger(); // Logger, App wide logger
  void changesMade() {
    notifyListeners();
  }

  void setProgressBar(dynamic value) {
    progress = value;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  // Main Page
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Main Page State, Sidebar visible, Navigation
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Get State
    if (appState.sharedPreferencesProvider.getSideBarAutoExpansion()) {
      double width = MediaQuery.of(context).size.width;
      if (width >= 600) {
        appState.sharedPreferencesProvider.setSideBarExpanded(true);
      } else {
        appState.sharedPreferencesProvider.setSideBarExpanded(false);
      }
    }

    appState.devMode = appState.sharedPreferencesProvider.getDeveloperMode();

    Widget page; // Set Page
    if (appState.connector.connected == false &&
        selectedIndex != 0 &&
        selectedIndex != 5 &&
        selectedIndex != 6) {
      // If not connected, and not on home, settings or dev page, go to home page
      selectedIndex = 0;
    }
    switch (selectedIndex) {
      // Sidebar Navigation
      case 0:
        if (appState.connector.connected == true) {
          if (appState.connector.connectionType == ChameleonConnectType.dfu) {
            page = const FlashingPage();
            selectedIndex = 0;
          } else {
            page = const HomePage();
          }
        } else {
          page = const ConnectPage();
        }
        break;
      case 1:
        page = const SlotManagerPage();
        break;
      case 2:
        page = const SavedCardsPage();
        break;
      case 3:
        page = const ReadCardPage();
        break;
      case 4:
        page = const Mfkey32Page();
        break;
      case 5:
        page = const SettingsMainPage();
        break;
      case 6:
        page = const DevPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.surface,
    ));

    return LayoutBuilder(// Build Page
        builder: (context, constraints) {
      return Scaffold(
          body: Row(
            children: [
              (appState.connector.connectionType != ChameleonConnectType.dfu ||
                      !appState.connector.connected)
                  ? SafeArea(
                      child: NavigationRail(
                        // Sidebar
                        extended: appState.sharedPreferencesProvider
                            .getSideBarExpanded(),
                        destinations: [
                          // Sidebar Items
                          const NavigationRailDestination(
                            icon: Icon(Icons.home),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.widgets,
                                color: appState.connector.connected == false
                                    ? Colors.grey
                                    : null),
                            label: Text('Slot Manager',
                                style: appState.connector.connected == false
                                    ? const TextStyle(color: Colors.grey)
                                    : null),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.auto_awesome_motion_outlined,
                                color: appState.connector.connected == false
                                    ? Colors.grey
                                    : null),
                            label: Text('Saved Cards',
                                style: appState.connector.connected == false
                                    ? const TextStyle(color: Colors.grey)
                                    : null),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.wifi,
                                color: appState.connector.connected == false
                                    ? Colors.grey
                                    : null),
                            label: Text('Read Card',
                                style: appState.connector.connected == false
                                    ? const TextStyle(color: Colors.grey)
                                    : null),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.credit_card,
                                color: appState.connector.connected == false
                                    ? Colors.grey
                                    : null),
                            label: Text('Mfkey32',
                                style: appState.connector.connected == false
                                    ? const TextStyle(color: Colors.grey)
                                    : null),
                          ),
                          const NavigationRailDestination(
                            icon: Icon(Icons.settings),
                            label: Text('Settings'),
                          ),
                          if (appState.devMode)
                            const NavigationRailDestination(
                              icon: Icon(Icons.developer_mode),
                              label: Text('🐞 Debug 🐞'),
                            ),
                        ],
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (value) {
                          setState(() {
                            selectedIndex = value;
                          });
                        },
                      ),
                    )
                  : const SizedBox(),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
          bottomNavigationBar: const BottomProgressBar());
    });
  }
}

class BottomProgressBar extends StatelessWidget {
  const BottomProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return (appState.connector.connected == true &&
            appState.connector.connectionType == ChameleonConnectType.dfu)
        ? LinearProgressIndicator(
            value: appState.progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          )
        : const SizedBox();
  }
}
