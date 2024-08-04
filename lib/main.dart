import 'dart:async';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:camera/camera.dart';
import 'package:camery/firebase_options.dart';
import 'package:camery/google%20ads/constantremote.dart';
import 'package:camery/src/app.dart';
import 'package:camery/src/pages/mapScreen.dart';
import 'package:camery/src/utils/apputils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onepref/onepref.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'src/utils/preferences.dart';

List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    MobileAds.instance.initialize();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await OnePref.init();
    AppUtils.isSubscribed = OnePref.getRemoveAds() ?? false;
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    cameras = await availableCameras();
  } on CameraException catch (e) {
    if (kDebugMode) {
      print('Error: ${e.code}\nError Message: ${e.description}');
    }
  }
  initializeRemoteConfig();
  await checkVersionAndRequestPermission();
  await Preferences.init();
  if (Platform.isIOS) {
    await initPlugin();
  }
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  if (Preferences.getMaximumScreenBrightness()) {
    await ScreenBrightness().setScreenBrightness(1.0);
  }
  if (Platform.isAndroid) {
    fetchImagesWithLocation();
  }
  runApp(const CameraApp());
}

Future<void> checkVersionAndRequestPermission() async {
  List<Permission> permissions = [
    Permission.storage,
  ];

  permissions.add(Permission.audio);
  permissions.add(Permission.videos);
  permissions.add(Permission.photos);

  await permissions.request();
}

//remote config
final remoteConfig = FirebaseRemoteConfig.instance;
initializeRemoteConfig() async {
  await remoteConfig.fetchAndActivate();
  if (Platform.isAndroid) {
    getallValue();
  } else {
    getallValueIOS();
  }
  remoteConfig.onConfigUpdated.listen((RemoteConfigUpdate event) async {
    await remoteConfig.activate();
    if (Platform.isAndroid) {
      getallValue();
    } else {
      getallValueIOS();
    }
  });
}

getallValue() {
  splash_screen_interstitial =
      remoteConfig.getBool('splash_screen_interstitial');
  app_open_ad = remoteConfig.getBool('app_open_ad');
  puzzleBannerAd = remoteConfig.getBool('puzzleBannerAd');
  imageBannerAd = remoteConfig.getBool('imageBannerAd');
  videoBannerAd = remoteConfig.getBool('videoBannerAd');
  myVisitInterstitial = remoteConfig.getBool('myVisitInterstitial');
  slidingPuzzleGameBAckInterstitial =
      remoteConfig.getBool('slidingPuzzleBAckInterstitial');
  everythirdImageSavedInterstitial =
      remoteConfig.getBool('thirdImageSavedInterstitial');
  removeWaterMarkReward = remoteConfig.getBool('removeWaterMarkReward');
  puzzleHintReward = remoteConfig.getBool('puzzleHintReward');
  homeScreenBannerAd = remoteConfig.getBool('homeScreenBannerAd');
  tempNativeAd = remoteConfig.getBool('tempNativeAd');
}

getallValueIOS() {
  splash_screen_interstitial =
      remoteConfig.getBool('splash_screen_interstitialIOS');
  app_open_ad = remoteConfig.getBool('app_open_adIOS');
  puzzleBannerAd = remoteConfig.getBool('puzzleBannerAdIOS');
  imageBannerAd = remoteConfig.getBool('imageBannerAdIOS');
  videoBannerAd = remoteConfig.getBool('videoBannerAdIOS');
  myVisitInterstitial = remoteConfig.getBool('myVisitInterstitialIOS');
  slidingPuzzleGameBAckInterstitial =
      remoteConfig.getBool('slidingPuzzleBAckInterstitialIOS');
  everythirdImageSavedInterstitial =
      remoteConfig.getBool('thirdImageSavedInterstitialIOS');
  removeWaterMarkReward = remoteConfig.getBool('removeWaterMarkRewardIOS');
  puzzleHintReward = remoteConfig.getBool('puzzleHintRewardIOS');
  homeScreenBannerAd = remoteConfig.getBool('homeScreenBannerAdIOS');
  tempNativeAd = remoteConfig.getBool('tempNativeAdIOS');
}

Future<void> initPlugin() async {
  final TrackingStatus status =
      await AppTrackingTransparency.trackingAuthorizationStatus;

  // If the system can show an authorization request dialog
  if (status == TrackingStatus.notDetermined) {
    // Show a custom explainer dialog before the system dialog

    // Wait for dialog popping animation
    await Future.delayed(const Duration(milliseconds: 200));
    // Request system's tracking authorization dialog
    final TrackingStatus status =
        await AppTrackingTransparency.requestTrackingAuthorization();
  }

  final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
  debugPrint("UUID: $uuid");
}
