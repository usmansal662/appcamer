// ignore_for_file: camel_case_types, file_names

import 'dart:io';

import 'package:camery/google%20ads/adId.dart';
import 'package:camery/google%20ads/constantremote.dart';
import 'package:camery/src/pages/puzzles/puzzlesolscreen.dart';
import 'package:camery/src/pages/templates_screen.dart';
import 'package:camery/src/utils/apputils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:camery/src/pages/camera_page.dart';
import 'package:camery/src/pages/mapScreen.dart';
import 'package:camery/src/pages/photoGaller/photoGallery.dart';
import 'package:camery/src/pages/savedImage.dart';
import 'package:camery/src/pages/settings/setting_screen.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../google ads/adservice.dart';
import '../../../subscription/subscription.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  getCurrentLocation() async {
    LocationPermission permissionStatus = await Geolocator.checkPermission();
    bool hasLocationPermission =
        permissionStatus == LocationPermission.always ||
            permissionStatus == LocationPermission.whileInUse;

    if (hasLocationPermission) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        lat = position.latitude;
        long = position.longitude;
      });
      GeoData geoData = await Geocoder2.getDataFromCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          googleMapApiKey: 'AIzaSyCIB-7DOsSUhZeqIfz3k3scAjvdD6j_OAE');
      setState(() {
        location = geoData;
      });
    } else {
      await Geolocator.requestPermission();
      getCurrentLocation();
    }
  }

  @override
  void initState() {
    setnavbar();
    super.initState();
    getCurrentLocation();
    _checkAndShowDialog();
    if (!AppUtils.isSubscribed && homeScreenBannerAd) {
      _loadAd();
    }
  }

  Future<void> _checkAndShowDialog() async {
    // Show the dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: const SubscriptionScreen(),
            );
          });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
    _anchoredAdaptiveAd = null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return showExitPopup(context);
      },
      child: Scaffold(
        backgroundColor: AppColor.scaffoldBgColor,
        bottomNavigationBar: _anchoredAdaptiveAd != null &&
                _isLoaded &&
                !AppUtils.isSubscribed &&
                homeScreenBannerAd
            ? Container(
                color: Colors.white,
                height: _anchoredAdaptiveAd!.size.height.toDouble(),
                child: AdWidget(ad: _anchoredAdaptiveAd!),
              )
            : null,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/homeBg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GPS Photo Camera',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'poppins'),
                        ),
                        const proButton(),
                        effectButton(
                            onClick: () {
                              Get.to(() => const SettingsScreen())?.then((_) {
                                if (!AppUtils.isSubscribed &&
                                    homeScreenBannerAd) {
                                  _loadAd();
                                }
                                setState(() {});
                              });
                            },
                            child: Image.asset(
                              'assets/icon/setIcon.png',
                              height: 30,
                            ))
                      ],
                    ),
                    Divider(
                      color: const Color(0xffFFFFFF).withOpacity(0.23),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      effectButton(
                        onClick: () {
                          Get.to(() => CameraPage(
                                isVideoCameraSelected: false,
                                isSimpleCamera: false,
                              ))?.then((value) {
                            if (!AppUtils.isSubscribed && homeScreenBannerAd) {
                              _loadAd();
                              setState(() {});
                            }
                          });
                        },
                        child: Image.asset(
                          'assets/images/camera.png',
                          height: 210,
                        ),
                      ),
                      effectButton(
                        onClick: () {
                          Get.to(() => CameraPage(
                                isVideoCameraSelected: true,
                                isSimpleCamera: false,
                              ))?.then((value) {
                            if (!AppUtils.isSubscribed && homeScreenBannerAd) {
                              _loadAd();
                              setState(() {});
                            }
                          });
                        },
                        child: Image.asset(
                          'assets/images/vcamera.png',
                          height: 200,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      effectButton(
                        onClick: () {
                          Get.to(() => const PhotoGalleryScreen())
                              ?.then((value) {
                            if (!AppUtils.isSubscribed && homeScreenBannerAd) {
                              _loadAd();
                              setState(() {});
                            }
                          });
                        },
                        child: Image.asset(
                          'assets/images/puzzle.png',
                          height: 200,
                        ),
                      ),
                      effectButton(
                        onClick: () async {
                          if (Platform.isAndroid) {
                            imageLocations = {};
                            fetchImagesWithLocation();
                          }
                          if (!AppUtils.isSubscribed &&
                              myVisitInterstitial &&
                              AdServices.myVisitInterstitial == null) {
                            AdServices.loadmyVisitInterstitial();
                          }
                          if (!AppUtils.isSubscribed && myVisitInterstitial) {
                            await showLoadingDialogInterstialAd(() {
                              if (AdServices.myVisitInterstitial != null) {
                                AdServices.myVisitInterstitial?.show();
                              }
                              Get.back();
                            }, sec: 6);
                          }
                          Get.to(() => const MapScreen());
                        },
                        child: Image.asset(
                          'assets/images/map.png',
                          height: 200,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      effectButton(
                        onClick: () {
                          Get.to(() => const SavedImageScreen())?.then((value) {
                            if (!AppUtils.isSubscribed && homeScreenBannerAd) {
                              _loadAd();
                              setState(() {});
                            }
                          });
                        },
                        child: Image.asset(
                          'assets/images/gallery.png',
                          height: 140,
                        ),
                      ),
                      effectButton(
                        onClick: () {
                          Get.to(() => const TemplateScreen())?.then((value) {
                            if (!AppUtils.isSubscribed && homeScreenBannerAd) {
                              _loadAd();
                              setState(() {});
                            }
                          });
                        },
                        child: Image.asset(
                          'assets/images/templ.png',
                          height: 150,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 110,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  Future<void> _loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            Get.width.truncate());

    if (size == null) {
      if (kDebugMode) {
        print('Unable to get height of anchored banner.');
      }
      return;
    }
    _anchoredAdaptiveAd = BannerAd(
      adUnitId: AdHelper.homeBannerAd,
      size: size,
      request: const AdRequest(extras: {"collapsible": "bottom"}),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            print('$ad loaded: ${ad.responseInfo}');
          }
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );

    return _anchoredAdaptiveAd!.load();
  }
}

class proButton extends StatelessWidget {
  const proButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          Get.to(() => const SubscriptionScreen());
        },
        icon: Image.asset(
          'assets/icon/pro.png',
          height: 35,
        ));
  }
}

class repFolderCon extends StatelessWidget {
  const repFolderCon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
            image: AssetImage(
              'assets/icon/folderIcon.png',
            ),
          ),
          border: Border.fromBorderSide(
              BorderSide(color: AppColor.lightpinkColor))),
    );
  }
}

class repTryBtn extends StatelessWidget {
  const repTryBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
              colors: [AppColor.lightpinkColor, AppColor.blueColor])),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: const Text(
        'Try it now',
        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
      ),
    );
  }
}

Future<bool> showExitPopup(context) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Do you want to exit?",
                  style: TextStyle(fontFamily: 'poppins'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (Platform.isAndroid) {
                            SystemNavigator.pop();
                          } else if (Platform.isIOS) {
                            exit(0);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor),
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'poppins'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          "No",
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'poppins'),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      });
}
