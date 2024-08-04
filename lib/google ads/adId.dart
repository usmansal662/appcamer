// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';

class AdHelper {
  static String get puzzleBannerAd {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/4521925590';
    } else {
      return 'ca-app-pub-8273658227029655/3287222200';
    }
  }

  static String get imageBannerAd {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/6892938067';
    } else {
      return 'ca-app-pub-8273658227029655/6205029589';
    }
  }

  static String get homeBannerAd {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/4143566315';
    } else {
      return 'ca-app-pub-8273658227029655/9764224934';
    }
  }

  static String get videoBannerAd {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/4243358455';
    } else {
      return 'ca-app-pub-8273658227029655/1706994337';
    }
  }

  static String get welcomScreenInterstitial {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/7339660621';
    } else {
      return 'ca-app-pub-8273658227029655/3782046226';
    }
  }

  static String get appOpenAd {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/8983914784';
    } else {
      return 'ca-app-pub-8273658227029655/5610580322';
    }
  }

  static String get myVisitInterstitial {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/6026578955';
    } else {
      return 'ca-app-pub-8273658227029655/2165712228';
    }
  }

  static String get slidingPuzzleGameBAckInterstitial {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/7670833116';
    } else {
      return 'ca-app-pub-8273658227029655/8264663825';
    }
  }

  static String get everythirdImageSavedInterstitial {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/5579856394';
    } else {
      return 'ca-app-pub-8273658227029655/2357283910';
    }
  }

  static String get removeWaterMarkReward {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/1269076298';
    } else {
      return 'ca-app-pub-8273658227029655/7143153848';
    }
  }

  static String get puzzleHintReward {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/2063917677';
    } else {
      return 'ca-app-pub-8273658227029655/6089726939';
    }
  }

  static String get templateNativeAd {
    if (Platform.isAndroid) {
      return 'ca-app-pub-8273658227029655/2389702763';
    } else {
      return 'ca-app-pub-8273658227029655/1926668332';
    }
  }
}

class LoadingAd extends StatelessWidget {
  const LoadingAd({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: 90.0,
      width: MediaQuery.of(context).size.width / 2.25,
      //width: 150,
      decoration: BoxDecoration(
          color: Colors.black87, borderRadius: BorderRadius.circular(15.0)),
      child: const Padding(
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 12.0, right: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 10.0),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    ));
  }
}
