import 'dart:developer';

import 'package:camery/google%20ads/adId.dart';
import 'package:camery/src/pages/onboard.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/route_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdServices {
  // //+++++++++++++ Welcome INTERSTITIAL +++++++++++++++++++++++++++
  static InterstitialAd? welcomScreenInterstitial;

  static Future<void> loadwelcomScreenInterstitial() async {
    await InterstitialAd.load(
      adUnitId: AdHelper.welcomScreenInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          welcomScreenInterstitial = ad;
          ad.show();
          Future.delayed(const Duration(seconds: 2), () {
            Get.off(() => const OnBoard());
          });
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              welcomScreenInterstitial = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              welcomScreenInterstitial = null;
            },
          );
        },
        onAdFailedToLoad: (err) {
          welcomScreenInterstitial = null;
          Future.delayed(const Duration(seconds: 4), () {
            Get.off(() => const OnBoard());
          });
        },
      ),
    );
  }

  // //+++++++++++++ myVisit INTERSTITIAL +++++++++++++++++++++++++++
  static InterstitialAd? myVisitInterstitial;

  static Future<void> loadmyVisitInterstitial() async {
    await InterstitialAd.load(
        adUnitId: AdHelper.myVisitInterstitial,
        request: const AdRequest(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          myVisitInterstitial = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              myVisitInterstitial = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              myVisitInterstitial = null;
            },
          );
        }, onAdFailedToLoad: (err) {
          myVisitInterstitial = null;
        }));
  }

  //+++++++++++++ Siren INTERSTITIAL +++++++++++++++++++++++++++
  static InterstitialAd? slidingPuzzleGameBAckInterstitial;

  static Future<void> loadslidingPuzzleGameBAckInterstitial() async {
    await InterstitialAd.load(
        adUnitId: AdHelper.slidingPuzzleGameBAckInterstitial,
        request: const AdRequest(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          slidingPuzzleGameBAckInterstitial = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              slidingPuzzleGameBAckInterstitial = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              slidingPuzzleGameBAckInterstitial = null;
            },
          );
        }, onAdFailedToLoad: (err) {
          slidingPuzzleGameBAckInterstitial = null;
        }));
  }

  static InterstitialAd? everythirdImagesavedInterstitial;

  static Future<void> loadeverythirdImagesavedInterstitial() async {
    await InterstitialAd.load(
        adUnitId: AdHelper.everythirdImageSavedInterstitial,
        request: const AdRequest(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          everythirdImagesavedInterstitial = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              everythirdImagesavedInterstitial = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              everythirdImagesavedInterstitial = null;
            },
          );
        }, onAdFailedToLoad: (err) {
          everythirdImagesavedInterstitial = null;
        }));
  }

  // //+++++++++++++ Reward Ad INTERSTITIAL +++++++++++++++++++++++++++
  RewardedAd? rewardedAd;

  Future loadRewardAd(
    Function(bool isLoad) update,
  ) async {
    await RewardedAd.load(
      adUnitId: AdHelper.removeWaterMarkReward,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
            },

            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              ad.dispose();
              update(false);
              Get.back(
                result: [true],
              );
            },
          );
          //rewardedAd = ad;
          ad.show(onUserEarnedReward: (ad, item) {});
        },
        onAdFailedToLoad: (error) {
          rewardedAd?.dispose();
          Get.back();
        },
      ),
    );
  }

  // //+++++++++++++ Reward Ad puzzlesolve INTERSTITIAL +++++++++++++++++++++++++++
  RewardedAd? rewardedAdPuzzle;

  Future loadRewardAdPuzzle(
    Function(bool isLoad) update,
  ) async {
    await RewardedAd.load(
      adUnitId: AdHelper.puzzleHintReward,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
            },

            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              ad.dispose();
              update(false);
              Get.back(
                result: [true],
              );
            },
          );
          //rewardedAd = ad;
          ad.show(onUserEarnedReward: (ad, item) {});
        },
        onAdFailedToLoad: (error) {
          rewardedAd?.dispose();
          Get.back();
        },
      ),
    );
  }
}
