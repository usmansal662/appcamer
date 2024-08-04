import 'package:camery/google%20ads/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

bool splash_screen_interstitial = true;
bool app_open_ad = true;
bool puzzleBannerAd = true;
bool imageBannerAd = true;
bool videoBannerAd = true;
bool myVisitInterstitial = true;
bool slidingPuzzleGameBAckInterstitial = true;
bool everythirdImageSavedInterstitial = true;
bool removeWaterMarkReward = true;
bool puzzleHintReward = true;
bool homeScreenBannerAd = true;
bool tempNativeAd = true;

showLoadingDialogInterstialAd(VoidCallback vc, {int? sec}) async {
  Get.dialog(
      barrierDismissible: false,
      const Material(color: Colors.transparent, child: Loading()));

  await Future.delayed(Duration(seconds: sec ?? 1), vc);
}
