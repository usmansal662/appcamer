import 'dart:io';

import 'package:camery/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertUpdates extends StatelessWidget {
  const AlertUpdates({super.key});
// Function to launch Play Store for rating

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.4,
      child: AlertDialog(
        surfaceTintColor: AppColor.scaffoldBgColor,
        backgroundColor: AppColor.primaryColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icon/applogo.png',
                  height: 53.0,
                  width: 53.0,
                ),
                const SizedBox(width: 10),
                const Text(
                  "GPS Map Camera\nTimeStamp Tag",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Would you like to check the update is available on ${Platform.isAndroid ? "play store" : "App Store"}",
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.white, fontFamily: 'poppins'),
            ),
          ],
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(width: 1, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Platform.isAndroid ? launchPlayStore() : launchAppStore();
            },
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(AppColor.primaryColor),
              backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            child: const Text(
              'Check',
              style: TextStyle(fontFamily: 'poppins'),
            ),
          ),
        ],
      ),
    );
  }
}

void launchPlayStore() async {
  const url =
      'https://play.google.com/store/apps/details?id=com.GPSMapCameraTimeStampTag';
  final Uri playStoreUrl = Uri.parse(url);
  if (await canLaunchUrl(playStoreUrl)) {
    await launchUrl(playStoreUrl);
  } else {
    throw 'Could not launch $url';
  }
}

launchAppStore() async {
  if (!await launchUrl(Uri.parse('https://apps.apple.com/us/app/id6503334107'),
      mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launcn');
  } else {}
}
