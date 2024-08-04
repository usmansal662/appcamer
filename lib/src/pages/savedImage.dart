import 'dart:io';
import 'package:camery/google%20ads/adId.dart';
import 'package:camery/google%20ads/constantremote.dart';
import 'package:camery/model/locationModel.dart';
import 'package:camery/src/pages/video/savedVideoScreen.dart';
import 'package:camery/src/utils/apputils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:camery/src/pages/photoGaller/photoView.dart';
import 'package:camery/src/utils/preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'photoGaller/photoGallery.dart';

class SavedImageScreen extends StatefulWidget {
  const SavedImageScreen({super.key});

  @override
  State<SavedImageScreen> createState() => _SavedImageScreenState();
}

class _SavedImageScreenState extends State<SavedImageScreen> {
  Map<String, List<LocationModel>> imgList = {};

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  loadImages() async {
    if (imgList.isEmpty) {
      imgList = {};
      setState(() {});
    }
    imgList.clear();
    List<LocationModel> list = Preferences.latlongList;
    for (int i = 0; i < list.length; i++) {
      File file = File(list[i].imageUrl);

      if (await file.exists()) {
        String dateKey = DateFormat('dd, MMMyyyy').format(list[i].dateTime);
        List<LocationModel> listfile = imgList[dateKey] ?? [];
        listfile.add(list[i]);
        imgList[dateKey] = listfile;
        setState(() {});
      } else {
        Preferences.removeLatlong = i;
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
      adUnitId: AdHelper.imageBannerAd,
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
    if (!AppUtils.isSubscribed && imageBannerAd) {
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
      bottomNavigationBar: _anchoredAdaptiveAd != null &&
              _isLoaded &&
              !AppUtils.isSubscribed &&
              imageBannerAd
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
                              color: const Color(0xff8E36FF)),
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
                            color: Colors.transparent,
                          ),
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
              imgList.entries.isEmpty
                  ? Image.asset(
                      'assets/images/noimg.png',
                    )
                  : Expanded(
                      child: ListView(
                        children: imgList.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: Get.height * 0.2,
                                width: Get.width,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xff8E36FF)
                                        .withOpacity(0.2)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                          color: const Color(0xff863CE5),
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                      child: Text(entry.key,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'poppins',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    FittedBox(
                                      child: Text(entry.value.last.address,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'poppins',
                                            color: Colors.white,
                                          )),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              82, 141, 54, 255),
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                      child: Text(
                                          "Lat:${entry.value.last.lat} Long:${entry.value.last.long}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'poppins',
                                            color: Colors.white,
                                          )),
                                    )
                                  ],
                                ),
                              ),
                              GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 10,
                                ),
                                itemCount: entry.value.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  String imageFile =
                                      entry.value[index].imageUrl;
                                  return GestureDetector(
                                    onLongPress: () {
                                      Vibration.vibrate(duration: 100);
                                      Get.dialog(CupertinoAlertDialog(
                                        title: const Text(
                                          'Are you sure to delete this picture?',
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
                                              Preferences.removeLatlong = index;

                                              await File(imageFile).delete();
                                              loadImages();
                                            },
                                            child: const Text(
                                              'Yes',
                                            ),
                                          ),
                                        ],
                                      ));
                                    },
                                    onTap: () {
                                      Get.to(() =>
                                          PhotoViewPage(imageUrl: imageFile));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.file(
                                        File(imageFile),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
