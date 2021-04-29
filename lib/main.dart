import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

Random random = new Random();
int randomNumber = random.nextInt(100000);
Timer timer;
bool updated = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(MyApp());
}

bool isSwitched = false;
bool change = false;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<int, Color> color = {
    50: Color.fromRGBO(37, 141, 202, .1),
    100: Color.fromRGBO(37, 141, 202, .2),
    200: Color.fromRGBO(37, 141, 202, .3),
    300: Color.fromRGBO(37, 141, 202, .4),
    400: Color.fromRGBO(37, 141, 202, .5),
    500: Color.fromRGBO(37, 141, 202, .6),
    600: Color.fromRGBO(37, 141, 202, .7),
    700: Color.fromRGBO(37, 141, 202, .8),
    800: Color.fromRGBO(37, 141, 202, .9),
    900: Color.fromRGBO(37, 141, 202, 1),
  };

  Map<int, Color> dcolor = {
    50: Color.fromRGBO(96, 96, 96, .1),
    100: Color.fromRGBO(96, 96, 96, .2),
    200: Color.fromRGBO(96, 96, 96, .3),
    300: Color.fromRGBO(96, 96, 96, .4),
    400: Color.fromRGBO(96, 96, 96, .5),
    500: Color.fromRGBO(96, 96, 96, .6),
    600: Color.fromRGBO(96, 96, 96, .7),
    700: Color.fromRGBO(96, 96, 96, .8),
    800: Color.fromRGBO(96, 96, 96, .9),
    900: Color.fromRGBO(96, 96, 96, 1),
  };
  void initState() {
    super.initState();
    void changeTheme() {
      setState(() => {
            if (isSwitched == false) {change = true} else {change = false}
          });
    }

    changeTheme();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => changeTheme());
  }

  @override
  Widget build(BuildContext context) {
    MaterialColor colorCustom = MaterialColor(0XFF258dca, color);
    MaterialColor colorCustoms = MaterialColor(0XFF606060, dcolor);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: (change == true)
          ? ThemeData(
              cardColor: Color.fromRGBO(153, 204, 255, .6),
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.

              primarySwatch: colorCustom,
            )
          : ThemeData(
              textTheme: TextTheme(
                subtitle1: TextStyle(),
                bodyText1: TextStyle(),
                bodyText2: TextStyle(),
              ).apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
              primarySwatch: colorCustoms,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.white,
                  primary: Colors.black,
                ),
              ),
              scaffoldBackgroundColor: Colors.black,
              cardTheme: CardTheme(
                color: Colors.grey[700],
              )),
      home: MainBody(),
    );
  }
}

class MainBody extends StatefulWidget {
  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  List Datas = [];
  int length;
  String content;
  void initState() {
    super.initState();
    FlutterLocalNotificationsPlugin localnotification;
    var androidInitilize =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSinitilize);
    localnotification = new FlutterLocalNotificationsPlugin();
    localnotification.initialize(initilizationsSettings);

    Future shown() async {
      var androidDetails = new AndroidNotificationDetails(
          "channelID", "Local Notification", "New Announcement",
          importance: Importance.high);
      var iSODetails = new IOSNotificationDetails();
      var generalNotificationDetails =
          new NotificationDetails(android: androidDetails, iOS: iSODetails);

      await localnotification.show(randomNumber, "Notification",
          "New Announcement", generalNotificationDetails);
    }

    void apicall() async {
      print("Executing");
      final response = await get(
        Uri.parse("https://ktu-notifier-api.herokuapp.com/"),
      );
      final responseJson = jsonDecode(response.body);
      length = responseJson.length;

      setState(() {
        Datas = responseJson;
      });

      String time = responseJson[0]['dte'];
      String link = responseJson[0]['link'];
      content = responseJson[0]['notification_head'];
      updated = responseJson[0]['updated'];
      print("Finished");
    }

    void real() {
      if (updated == true) {
        shown();
      }
    }

    apicall();
    real();
    timer = Timer.periodic(Duration(seconds: 900), (Timer t) => apicall());
    timer = Timer.periodic(Duration(seconds: 900), (Timer t) => real());
  }

  var textValue = 'Too Bright';

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Too Dark';
      });
      print('Dark Theme');
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Too Bright';
      });
      print('Switch Button is OFF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("KTU Notifier"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        onChanged: toggleSwitch,
                        value: isSwitched,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.grey,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Color.fromRGBO(37, 141, 202, 1),
                      )),
                  Text(
                    '$textValue',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: (Datas.isNotEmpty)
                    ? Container(
                        margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
                        child: ListView.builder(
                          itemCount: length,
                          itemBuilder: (context, index) {
                            return Card(
                                margin: EdgeInsets.fromLTRB(7, 0, 7, 35),
                                child: ListTile(
                                  onTap: null,
                                  title: Container(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        Text(Datas[index]['notification_head']),
                                        Text(" "),
                                        Text(Datas[index]['dte'])
                                      ],
                                    ),
                                  ),
                                  // title: Text(Datas[index]['notification_head']),
                                  subtitle: ElevatedButton.icon(
                                    style: ButtonStyle(),
                                    onPressed: () async {
                                      final status =
                                          await Permission.storage.request();

                                      if (status.isGranted) {
                                        final externalDir =
                                            await getExternalStorageDirectory();

                                        final id =
                                            await FlutterDownloader.enqueue(
                                          url: Datas[index]['link'],
                                          savedDir: externalDir.path,
                                          fileName: "Download",
                                          showNotification: true,
                                          openFileFromNotification: true,
                                        );
                                      } else {
                                        print("Permission deined");
                                      }
                                    },
                                    icon: const Icon(Icons.download_outlined),
                                    label: Text("Download"),
                                  ),
                                ));
                          },
                        ),
                      )
                    : Container(
                        child: Center(
                          child: Image.asset('./assets/loader.gif'),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
