import 'package:camery/google%20ads/adId.dart';
import 'package:camery/google%20ads/constantremote.dart';
import 'package:camery/src/utils/apputils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camery/src/pages/photoGaller/photoGallery.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:camery/src/utils/images.dart';
import 'package:camery/src/utils/preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  List<String> imagesList = [];
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBgColor,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/slidingpuzzleBg.png',
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
          child: Column(
            children: [
              repAppBar(
                fn: () {
                  Get.back();
                },
                title: 'Templates',
              ),
              Expanded(
                  child: ListView.separated(
                itemCount: AppImage.tempImgList.length ~/ 4,
                itemBuilder: (context, index) {
                  int init = (index * 4);
                  int end = AppImage.tempImgList.length - init;
                  return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.8),
                      itemCount: end > 4 ? 4 : end,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Preferences.setTemplate(
                                AppImage.tempImgList[init + index].$2);
                            setState(() {});
                          },
                          child: Center(
                            child: Stack(
                              children: [
                                Image.asset(
                                  AppImage.tempImgList[init + index].$1,
                                  fit: BoxFit.fill,
                                ),
                                Visibility(
                                  visible: Preferences.getTemplate ==
                                      AppImage.tempImgList[init + index].$2,
                                  child: const Center(
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
                separatorBuilder: (context, index) {
                  return !AppUtils.isSubscribed && tempNativeAd
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.15,
                              vertical: 5),
                          child: const tempNAtiveAd(),
                        )
                      : Container();
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class tempNAtiveAd extends StatefulWidget {
  const tempNAtiveAd({super.key});

  @override
  tempNAtiveAdState createState() => tempNAtiveAdState();
}

class tempNAtiveAdState extends State<tempNAtiveAd> {
  //ad setup
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  @override
  void initState() {
    _loadAd();

    super.initState();
  }

  void _loadAd() {
    setState(() {
      _nativeAdIsLoaded = false;
    });

    _nativeAd = NativeAd(
        adUnitId: AdHelper.templateNativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) async {
            // ignore: avoid_print

            setState(() {
              _nativeAdIsLoaded = true;
            });
            await FirebaseAnalytics.instance.logEvent(
              name: "templateNativeAd",
              parameters: {
                "Ad_Loaded": 'Ad Loaded Successfully',
              },
            );
          },
          onAdFailedToLoad: (ad, error) async {
            ad.dispose();
            await FirebaseAnalytics.instance.logEvent(
              name: "templateNativeAd",
              parameters: {
                "Ad_fail": 'Ad fail',
              },
            );
          },
          onAdClicked: (ad) async {
            await FirebaseAnalytics.instance.logEvent(
              name: "templateNativeAd",
              parameters: {
                "Ad_click": 'Ad click',
              },
            );
          },
          onAdImpression: (ad) {},
          onAdClosed: (ad) {},
          onAdOpened: (ad) {},
          onAdWillDismissScreen: (ad) {},
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.small,
            mainBackgroundColor: const Color.fromARGB(255, 234, 228, 228),
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.white,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  //the card takes will either take editable form or view form
  Widget build(BuildContext context) {
    return _nativeAdIsLoaded && _nativeAd != null
        ? ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 320, // minimum recommended width
              minHeight: 120, // minimum recommended height
              maxWidth: 320,
              maxHeight: 120,
            ),
            child: AdWidget(ad: _nativeAd!),
          )
        : Container();
  }
}
