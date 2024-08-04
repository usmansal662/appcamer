// ignore_for_file: must_be_immutable, camel_case_types

import 'dart:io';
import 'package:camery/src/check_update/update.dart';
import 'package:camery/src/pages/about_us.dart';
import 'package:camery/src/pages/puzzles/puzzlesolscreen.dart';
import 'package:camery/subscription/subscription.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camery/src/pages/rate_us.dart';
import 'package:url_launcher/url_launcher.dart';

import '../photoGaller/photoGallery.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/slidingpuzzleBg.png'),
              fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              repAppBar(
                fn: () {
                  Get.back();
                },
                title: 'Settings',
              ),
              const SizedBox(
                height: 20,
              ),
              effectButton(
                  onClick: () {
                    Get.to(() => const SubscriptionScreen())
                        ?.then((value) => setState(() {}));
                  },
                  child: Image.asset('assets/icon/uppro.png')),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    effectButton(
                      onClick: () {
                        Get.to(() => const AboutUsScreen())
                            ?.then((value) => setState(() {}));
                      },
                      child: repListtile(
                        title: 'About Us',
                        onatp: () {},
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    effectButton(
                      onClick: () {
                        Get.to(() => const RateUsScreen())
                            ?.then((value) => setState(() {}));
                      },
                      child: repListtile(
                        title: 'Rate Us',
                        onatp: () {},
                        icon: const Icon(
                          Icons.star_outline,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    effectButton(
                      onClick: () {
                        goToContactUs();
                      },
                      child: repListtile(
                        title: 'Contact Us',
                        onatp: () {},
                        icon: Image.asset(
                          'assets/icon/contact_icon.png',
                        ),
                      ),
                    ),
                    effectButton(
                      onClick: () {
                        Get.dialog(const AlertUpdates());
                      },
                      child: repListtile(
                        title: 'Check For Update',
                        onatp: () {},
                        icon: Image.asset(
                          'assets/icon/chupdate.png',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

goToContactUs() {
  if (Platform.isAndroid) {
    launchEmail('support@metasol.dev', 'GPS Map Camera TimeStamp Tag');
  } else {
    launchEmail('support@metasol.dev', 'GPS Map Camera TimeStamp Tag');
  }
}

Future launchEmail(String to, String subject) async {
  String url = 'mailto:$to?subject=${Uri.encodeFull(subject)}';

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  }
}

class repListtile extends StatelessWidget {
  String title;
  void Function() onatp;
  Widget icon;
  repListtile({
    required this.title,
    required this.onatp,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xff863CE5))),
      child: ListTile(
        leading: Container(
            height: 35,
            width: 35,
            decoration: const BoxDecoration(
                color: Color(0xff863CE5), shape: BoxShape.circle),
            child: icon),
        onTap: onatp,
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontFamily: 'poppins'),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white60,
          size: 15,
        ),
      ),
    );
  }
}

class repListtileCamera extends StatelessWidget {
  String title;
  Widget radioBtn;
  repListtileCamera({
    required this.title,
    required this.radioBtn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        trailing: radioBtn);
  }
}
