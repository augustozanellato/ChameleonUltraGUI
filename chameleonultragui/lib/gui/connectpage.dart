import 'dart:typed_data';
import 'package:chameleonultragui/connector/serial_abstract.dart';
import 'package:chameleonultragui/helpers/flash.dart';
import 'package:chameleonultragui/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Get State

    return FutureBuilder(
      future: appState.connector.availableChameleons(false),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Connect'),
              ),
              body: const Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final result = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Connect'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        // Refresh
                        appState.changesMade();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                  Expanded(
                    child: GridView(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        scrollDirection: Axis.vertical,
                        children: [
                          // "Add" Button for Bluetooth
                          ElevatedButton(
                            onPressed: () {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) =>
                                    const AlertDialog(
                                  content: Text('Identifies as BLE Dialog'),
                                ),
                              );
                              // Connect via BLE here
                              appState.connector.connected =
                                  true; // Bypass / Dummy for testing
                              appState.changesMade();
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                            ),
                            child: const Icon(Icons.add),
                          ),
                          ...result.map<Widget>((chameleonDevice) {
                            return ElevatedButton(
                              onPressed: () async {
                                if (chameleonDevice['type'] ==
                                    ChameleonConnectType.dfu) {
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text(
                                          'Chameleon is in DFU mode'),
                                      content: const Text(
                                          'This probably means your firmware is corrupted. Do you want to flash latest FW?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context, 'Flash');
                                            appState.changesMade();
                                            Uint8List applicationDat,
                                                applicationBin;

                                            Uint8List content =
                                                await fetchFirmware(
                                                    appState.connector.device);

                                            (applicationDat, applicationBin) =
                                                await unpackFirmware(content);

                                            flashFile(
                                                null,
                                                appState,
                                                applicationDat,
                                                applicationBin,
                                                (progress) =>
                                                    appState.setProgressBar(
                                                        progress / 100),
                                                enterDFU: false);

                                            appState.changesMade();
                                          },
                                          child: const Text('Flash'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  await appState.connector
                                      .connectSpecific(chameleonDevice['port']);
                                  appState.changesMade();
                                }
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Icon(Icons.usb),
                                        Text(chameleonDevice['port'] ??
                                            "MISSING"),
                                        if (chameleonDevice['type'] ==
                                            ChameleonConnectType.dfu)
                                          const Text(" (DFU)"),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Chameleon ${(chameleonDevice['device'] == ChameleonDevice.ultra) ? 'Ultra' : 'Lite'}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.4,
                                      child: Image.asset(
                                        chameleonDevice['device'] ==
                                                ChameleonDevice.ultra
                                            ? 'assets/black-ultra-standing-front.png'
                                            : 'assets/black-lite-standing-front.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ]),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
