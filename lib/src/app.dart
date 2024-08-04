import 'dart:io';
import 'package:camery/google%20ads/app_open_ad_manager.dart';
import 'package:camery/src/pages/splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../google ads/app_life_cycle_reactor.dart';

const defaultThemeColour = Color(0xFF1E88E5);

class CameraApp extends StatefulWidget {
  const CameraApp({
    super.key,
  });

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with WidgetsBindingObserver {
  late AppLifecycleReactor _appLifecycleReactor;
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _requestConsentInfoUpdate();
    }
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();
  }

  void loadForm() {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        var status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show(
            (FormError? formError) {
              // Handle dismissal by reloading form
              loadForm();
            },
          );
        }
      },
      (formError) {
        // Handle the error
      },
    );
  }

  Future<void> _requestConsentInfoUpdate() async {
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          loadForm();
        }
      },
      (FormError? error) {
        // Handle the error
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [observer],
      home: const SplashScreen(),
    );
  }
}
