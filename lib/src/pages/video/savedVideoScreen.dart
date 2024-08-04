// ignore_for_file: file_names, depend_on_referenced_packages, deprecated_member_use

import 'dart:io';

import 'package:camery/src/pages/savedImage.dart';
import 'package:camery/src/utils/apputils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:camery/src/utils/preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../../google ads/adId.dart';
import '../../../google ads/constantremote.dart';
import '../photoGaller/photoGallery.dart';
import 'videoPlayScreen.dart';

class SavedVideoScreen extends StatefulWidget {
  const SavedVideoScreen({super.key});

  @override
  State<SavedVideoScreen> createState() => _SavedVideoScreenState();
}

class _SavedVideoScreenState extends State<SavedVideoScreen> {
  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  List<File> videoList = [];
  loadVideo() async {
    if (videoList.length == 1) {
      videoList = [];
      setState(() {});
    }
    videoList.clear();
    for (var element in Preferences.videoList) {
      File file = File(element);

      if (await file.exists()) {
        videoList.add(file);

        setState(() {});
      } else {
        Preferences.removevideo = element;
      }
    }
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
      adUnitId: AdHelper.videoBannerAd,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AppUtils.isSubscribed && videoBannerAd) {
      _loadAd();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
    _anchoredAdaptiveAd = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBgColor,
      bottomNavigationBar: _anchoredAdaptiveAd != null &&
              _isLoaded &&
              !AppUtils.isSubscribed &&
              videoBannerAd
          ? Container(
              color: Colors.white,
              height: _anchoredAdaptiveAd!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredAdaptiveAd!),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/slidingpuzzleBg.png'),
              fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
          child: Column(
            children: [
              repAppBar(
                fn: () {
                  Get.back();
                },
                title: 'Gallery',
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 200,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xff8E36FF).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.off(() => const SavedImageScreen());
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.transparent),
                          child: const Text(
                            'Photos',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.off(() => const SavedVideoScreen());
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xff8E36FF)),
                          child: const Text(
                            'Videos',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              videoList.isEmpty
                  ? Image.asset(
                      'assets/images/nosavev.png',
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: videoList.length,
                        itemBuilder: (context, index) {
                          String fileName = basename(videoList[index].path);

                          return ListTile(
                            onLongPress: () {
                              Get.dialog(
                                CupertinoAlertDialog(
                                  title: const Text(
                                    'Are you sure to delete this video?',
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: const Text(
                                        'No',
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Get.back();
                                        await File(videoList[index].path)
                                            .delete();
                                        Preferences.removevideo =
                                            videoList[index].path;
                                        loadVideo();
                                      },
                                      child: const Text(
                                        'Yes',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onTap: () {
                              Get.to(
                                VideoPlayScreen(
                                  pathed: videoList[index].path,
                                ),
                              );
                            },
                            leading: const Icon(
                              Icons.video_collection,
                              color: Colors.white,
                            ),
                            title: Text(
                              fileName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                Share.shareFiles(
                                  [
                                    videoList[index].path,
                                  ],
                                );
                              },
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
