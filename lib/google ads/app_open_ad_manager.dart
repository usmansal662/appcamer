import 'package:camery/google%20ads/adId.dart';
import 'package:camery/google%20ads/constantremote.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../src/utils/apputils.dart';

class AppOpenAdManager {
  final Duration maxCacheDuration = const Duration(hours: 4);

  DateTime? _appOpenLoadTime;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Load an [AppOpenAd].
  Future loadAd() async {
    if (!AppUtils.isSubscribed && app_open_ad) {
      await AppOpenAd.load(
        adUnitId: AdHelper.appOpenAd,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenLoadTime = DateTime.now();
            _appOpenAd = ad;
          },
          onAdFailedToLoad: (error) {},
        ),
      );
    } else {
      return;
    }
  }

  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  /// Shows the ad, if one exists and is not already being shown.
  ///
  /// If the previously cached ad has expired, this just loads and caches a
  /// new ad.
  void showAdIfAvailable() {
    if (!isAdAvailable) {
      loadAd();
      return;
    }
    if (_isShowingAd) {
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd();

      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    if (!AppUtils.isSubscribed && app_open_ad) {
      _appOpenAd!.show();
    }
  }
}
