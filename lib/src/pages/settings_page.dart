// ignore_for_file: deprecated_member_use

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:get/route_manager.dart';
import 'package:camery/src/pages/photoGaller/photoGallery.dart';
import 'package:camery/src/utils/preferences.dart';
import 'package:screen_brightness/screen_brightness.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
    required this.onPressed,
    required this.controller,
  });

  final void Function()? onPressed;
  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      disabledColor: Colors.white24,
      onPressed: onPressed,
      icon: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.settings_suggest_outlined,
            size: 25,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Setting',
            style: TextStyle(color: Colors.white, fontSize: 9.16),
          )
        ],
      ),
      tooltip: 'Settings',
      iconSize: 25,
      color: Colors.white,
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.controller,
    required this.onNewCameraSelected,
  });

  final CameraController? controller;
  final Function(CameraDescription) onNewCameraSelected;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String currentSavePath = Preferences.getSavePath();
  bool isMoreOptions = false;

  ScrollController listScrollController = ScrollController();

  //Compress quality slider
  double value = Preferences.getCompressQuality().toDouble();

  TextStyle style = const TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white);

  bool isenable = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() async {
        await widget.onNewCameraSelected(widget.controller!.description);
        return true;
      }),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/slidingpuzzleBg.png'),
                  fit: BoxFit.fill)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 40, 10, 8.0),
            child: Column(
              children: [
                repAppBar(
                  fn: () {
                    Get.back();
                  },
                  title: 'Camera Settings',
                ),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      reptilecamerasetting(
                          title: 'Add Tag',
                          icondata: Image.asset('assets/icon/tagIcon.png'),
                          advswitch: AdvancedSwitch(
                            onChanged: (val) async {
                              Preferences.setAddTagComplete(val);
                              setState(() {});
                            },
                            activeChild: const Text('ON'),
                            inactiveChild: const Text('OFF'),
                            activeColor: const Color(0xff3E2955),
                            inactiveColor: const Color(0xff3E2955),
                            width: 60.0,
                            initialValue: Preferences.getAddTagComplete(),
                            thumb: Icon(
                              Icons.circle,
                              color: Preferences.getAddTagComplete() == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          )),
                      reptilecamerasetting(
                          title: 'Max. Screen Brightness',
                          icondata: const Icon(
                            Icons.brightness_4_outlined,
                            color: Colors.white,
                          ),
                          advswitch: AdvancedSwitch(
                            onChanged: (val) async {
                              await Preferences.setMaximumScreenBrightness(val);
                              Preferences.getMaximumScreenBrightness()
                                  ? await ScreenBrightness()
                                      .setScreenBrightness(1.0)
                                  : await ScreenBrightness()
                                      .resetScreenBrightness();
                              setState(() {});
                            },
                            activeChild: const Text('ON'),
                            inactiveChild: const Text('OFF'),
                            activeColor: const Color(0xff3E2955),
                            inactiveColor: const Color(0xff3E2955),
                            width: 60.0,
                            initialValue:
                                Preferences.getMaximumScreenBrightness(),
                            thumb: Icon(
                              Icons.circle,
                              color: Preferences.getMaximumScreenBrightness() ==
                                      true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          )),
                      reptilecamerasetting(
                          title: 'Focus & Exposure Mode',
                          icondata: const Icon(
                            Icons.center_focus_strong_outlined,
                            color: Colors.white,
                          ),
                          advswitch: AdvancedSwitch(
                            onChanged: (val) async {
                              await Preferences.setEnableModeRow(val);
                              setState(() {});
                            },
                            activeChild: const Text('ON'),
                            inactiveChild: const Text('OFF'),
                            activeColor: const Color(0xff3E2955),
                            inactiveColor: const Color(0xff3E2955),
                            width: 60.0,
                            initialValue: Preferences.getEnableModeRow(),
                            thumb: Icon(
                              Icons.circle,
                              color: Preferences.getEnableModeRow() == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          )),
                      reptilecamerasetting(
                          title: 'Enable Zoom Slider',
                          icondata: const Icon(
                            Icons.zoom_in_outlined,
                            color: Colors.white,
                          ),
                          advswitch: AdvancedSwitch(
                            onChanged: (val) async {
                              await Preferences.setEnableZoomSlider(val);
                              setState(() {});
                            },
                            activeChild: const Text('ON'),
                            inactiveChild: const Text('OFF'),
                            activeColor: const Color(0xff3E2955),
                            inactiveColor: const Color(0xff3E2955),
                            width: 60.0,
                            initialValue: Preferences.getEnableZoomSlider(),
                            thumb: Icon(
                              Icons.circle,
                              color: Preferences.getEnableZoomSlider() == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          )),
                      reptilecamerasetting(
                          title: 'Enable Exposure slider',
                          icondata: const Icon(
                            Icons.exposure_outlined,
                            color: Colors.white,
                          ),
                          advswitch: AdvancedSwitch(
                            onChanged: (val) async {
                              await Preferences.setEnableExposureSlider(val);
                              setState(() {});
                            },
                            activeChild: const Text('ON'),
                            inactiveChild: const Text('OFF'),
                            activeColor: const Color(0xff3E2955),
                            inactiveColor: const Color(0xff3E2955),
                            width: 60.0,
                            initialValue: Preferences.getEnableExposureSlider(),
                            thumb: Icon(
                              Icons.circle,
                              color:
                                  Preferences.getEnableExposureSlider() == true
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container reptilecamerasetting(
      {required String title,
      required Widget icondata,
      required Widget advswitch}) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xff863CE5))),
      child: ListTile(
          leading: Container(
              height: 35,
              width: 35,
              decoration: const BoxDecoration(
                  color: Color(0xff2E1649), shape: BoxShape.circle),
              child: icondata),
          onTap: () {},
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontFamily: 'poppins'),
          ),
          trailing: advswitch),
    );
  }
}
