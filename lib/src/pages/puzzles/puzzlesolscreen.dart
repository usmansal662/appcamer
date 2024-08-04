// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:camery/google%20ads/adId.dart';
import 'package:camery/google%20ads/adservice.dart';
import 'package:camery/google%20ads/constantremote.dart';
import 'package:camery/src/utils/apputils.dart';
import 'package:camery/src/widgets/solvePuzzleDialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:camery/src/pages/photoGaller/photoGallery.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../utils/colors.dart';
import 'package:image/image.dart' as image;

class PuzzleSolveScreen extends StatefulWidget {
  File imgPath;
  PuzzleSolveScreen({super.key, required this.imgPath});

  @override
  State<PuzzleSolveScreen> createState() => _PuzzleSolveScreenState();
}

class _PuzzleSolveScreenState extends State<PuzzleSolveScreen> {
  bool isRewardWatch = false;
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;
  Future<void> _loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      if (kDebugMode) {
        print('Unable to get height of anchored banner.');
      }
      return;
    }
    _anchoredAdaptiveAd = BannerAd(
      adUnitId: AdHelper.puzzleBannerAd,
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
    if (!AppUtils.isSubscribed && puzzleBannerAd) {
      _loadAd();
    }
  }

  final GlobalKey _globalKey = GlobalKey();
  late Size size;

  // list array slide objects
  List<SlideObject>? slideObjects;
  // image load with renderer
  image.Image? fullImage;
  // success flag
  bool success = false;
  // flag already start slide
  bool startSlide = false;
  // save current swap process for reverse checking
  List<int>? process;
  // flag finish swap
  bool finishSwap = false;

  @override
  void initState() {
    if (AdServices.slidingPuzzleGameBAckInterstitial == null &&
        !AppUtils.isSubscribed) {
      AdServices.loadslidingPuzzleGameBAckInterstitial();
    }

    super.initState();

    size = Size(Get.width - 0 * 2, Get.width - 0);
    Future.delayed(const Duration(milliseconds: 500), () {
      generatePuzzle();
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
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar:
            _anchoredAdaptiveAd != null && _isLoaded && puzzleBannerAd
                ? Container(
                    color: Colors.white,
                    height: _anchoredAdaptiveAd!.size.height.toDouble(),
                    child: AdWidget(ad: _anchoredAdaptiveAd!),
                  )
                : null,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/puzzleBg.png'),
                fit: BoxFit.cover),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
            child: Column(
              children: [
                const SizedBox(
                  height: 25,
                ),
                repAppBar(
                  title: 'Sliding Puzzle',
                  fn: () async {
                    if (!AppUtils.isSubscribed &&
                        slidingPuzzleGameBAckInterstitial &&
                        AdServices.slidingPuzzleGameBAckInterstitial == null) {
                      AdServices.loadslidingPuzzleGameBAckInterstitial();
                    }
                    if (!AppUtils.isSubscribed &&
                        slidingPuzzleGameBAckInterstitial) {
                      await showLoadingDialogInterstialAd(() {
                        if (AdServices.slidingPuzzleGameBAckInterstitial !=
                            null) {
                          AdServices.slidingPuzzleGameBAckInterstitial?.show();
                        }
                        Get.back();
                      }, sec: 1);
                    }
                    Get.back();
                  },
                ),
                const SizedBox(
                  height: 35,
                ),
                Expanded(
                  child: slideWidget(
                    // set size puzzle
                    size: Size(Get.width, Get.height),
                    sizePuzzle: selectedSize,
                    imageBckGround: Image(
                      alignment: Alignment.center,
                      // u can use your own image
                      image: FileImage(
                        widget.imgPath,
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int selectedSize = 3;
  Widget repsizeTile({required int size, required icon, required title}) {
    return ListTile(
      onTap: () {
        Get.back();
        setState(() {
          selectedSize = size;
        });
        generatePuzzle();
      },
      trailing: selectedSize == size ? icon : const SizedBox(),
      selectedTileColor: const Color.fromARGB(128, 0, 6, 21),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400),
      ),
    );
  }

  Future<image.Image> _getImageFromWidget() async {
    RenderObject? boundary = _globalKey.currentContext?.findRenderObject();

    if (boundary is RenderRepaintBoundary) {
      var img = await boundary.toImage();
      var byteData = await img.toByteData(format: ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      return image.decodeImage(pngBytes)!;
    } else {
      throw Exception('Boundary is not a RenderRepaintBoundary');
    }
  }

  // method to generate our puzzle
  Future<void> generatePuzzle() async {
    // dclare our array puzzle
    finishSwap = false;
    setState(() {});
    // 1st load render image to crop, we need load just once
    fullImage ??= await _getImageFromWidget();

    // ok nice..full image loaded

    // calculate box size for each puzzle
    Size sizeBox = Size(size.width / selectedSize, size.width / selectedSize);

    // let proceed with generate box puzzle
    // power of 2 because we need generate row & column same number
    slideObjects = List.generate(selectedSize * selectedSize, (index) {
      // we need setup offset 1st
      Offset offsetTemp = Offset(
        index % selectedSize * sizeBox.width,
        index ~/ selectedSize * sizeBox.height,
      );

      // set image crop for nice effect, check also if image is null
      image.Image? tempCrop;
      if (fullImage != null) {
        tempCrop = image.copyCrop(
          fullImage!,
          x: offsetTemp.dx.toInt(),
          y: offsetTemp.dy.toInt(),
          width: sizeBox.width.toInt(),
          height: sizeBox.height.toInt(),
        );
      }

      return SlideObject(
        posCurrent: offsetTemp,
        posDefault: offsetTemp,
        indexCurrent: index,
        indexDefault: index + 1,
        size: sizeBox,
        image: tempCrop == null
            ? null
            : Image.memory(
                image.encodePng(tempCrop),
                fit: BoxFit.cover,
              ),
      );
    }); //let set empty on last child

    slideObjects!.last.empty = true;

    // make random.. im using smple method..just rndom with move it.. haha

    // setup moveMethod 1st
    // proceed with swap block place
    // swap true - we swap horizontal line.. false - vertical
    bool swap = true;
    process = [];

    // 20 * size puzzle shuffle
    for (var i = 0; i < selectedSize * 20; i++) {
      for (var j = 0; j < selectedSize / 2; j++) {
        SlideObject slideObjectEmpty = getEmptyObject();

        // get index of empty slide object
        int emptyIndex = slideObjectEmpty.indexCurrent;
        process!.add(emptyIndex);
        int randKey;

        if (swap) {
          // horizontal swap
          int row = emptyIndex ~/ selectedSize;
          randKey = row * selectedSize + Random().nextInt(selectedSize);
        } else {
          int col = emptyIndex % selectedSize;
          randKey = selectedSize * Random().nextInt(selectedSize) + col;
        }

        // call change pos method we create before to swap place

        changePos(randKey);
        // ops forgot to swap
        // hmm bug.. :).. let move 1st with click..check whther bug on swap or change pos
        swap = !swap;
      }
    }

    startSlide = false;
    finishSwap = true;
    setState(() {});
  }
  // eyay.. end

  // get empty slide object from list
  SlideObject getEmptyObject() {
    return slideObjects!.firstWhere((element) => element.empty);
  }

  void changePos(int indexCurrent) {
    // problem here i think..
    SlideObject slideObjectEmpty = getEmptyObject();

    // get index of empty slide object
    int emptyIndex = slideObjectEmpty.indexCurrent;

    // min & max index based on vertical or horizontal

    int minIndex = min(indexCurrent, emptyIndex);
    int maxIndex = max(indexCurrent, emptyIndex);

    // temp list moves involves
    List<SlideObject> rangeMoves = [];

    // check if index current from vertical / horizontal line
    if (indexCurrent % selectedSize == emptyIndex % selectedSize) {
      // same vertical line
      rangeMoves = slideObjects!
          .where((element) =>
              element.indexCurrent % selectedSize ==
              indexCurrent % selectedSize)
          .toList();
    } else if (indexCurrent ~/ selectedSize == emptyIndex ~/ selectedSize) {
      rangeMoves = slideObjects!;
    } else {
      rangeMoves = [];
    }

    rangeMoves = rangeMoves
        .where((puzzle) =>
            puzzle.indexCurrent >= minIndex &&
            puzzle.indexCurrent <= maxIndex &&
            puzzle.indexCurrent != emptyIndex)
        .toList();

    // check empty index under or above current touch
    if (emptyIndex < indexCurrent) {
      rangeMoves.sort((a, b) => a.indexCurrent < b.indexCurrent ? 1 : 0);
    } else {
      rangeMoves.sort((a, b) => a.indexCurrent < b.indexCurrent ? 0 : 1);
    }

    // check if rangeMOves is exist,, then proceed switch position
    if (rangeMoves.isNotEmpty) {
      int tempIndex = rangeMoves[0].indexCurrent;

      Offset tempPos = rangeMoves[0].posCurrent;

      // yeayy.. sorry my mistake.. :)
      for (var i = 0; i < rangeMoves.length - 1; i++) {
        rangeMoves[i].indexCurrent = rangeMoves[i + 1].indexCurrent;
        rangeMoves[i].posCurrent = rangeMoves[i + 1].posCurrent;
      }

      rangeMoves.last.indexCurrent = slideObjectEmpty.indexCurrent;
      rangeMoves.last.posCurrent = slideObjectEmpty.posCurrent;

      // haha ..i forget to setup pos for empty puzzle box.. :p
      slideObjectEmpty.indexCurrent = tempIndex;
      slideObjectEmpty.posCurrent = tempPos;
    }

    // this to check if all puzzle box already in default place.. can set callback for success later
    if (slideObjects!
                .where((slideObject) =>
                    slideObject.indexCurrent == slideObject.indexDefault - 1)
                .length ==
            slideObjects!.length &&
        finishSwap) {
      success = true;
    } else {
      success = false;
    }

    startSlide = true;
    setState(() {});
  }

  void clearPuzzle() {
    setState(() {
      // checking already slide for reverse purpose
      startSlide = true;
      slideObjects = null;
      finishSwap = true;
    });
  }

  Future<void> reversePuzzle(int mililsec) async {
    startSlide = true;
    finishSwap = true;
    setState(() {});

    await Stream.fromIterable(process!.reversed)
        .asyncMap((event) async =>
            await Future.delayed(Duration(milliseconds: mililsec))
                .then((value) => changePos(event)))
        .toList();

    // yeayy
    process = [];
    setState(() {});
    clearPuzzle();
  }

  Widget slideWidget({
    required Size size,
    double innerPadding = 0,
    required Image imageBckGround,
    required int sizePuzzle,
  }) {
    return Column(
      // let make ui
      children: [
        // make 2 column, 1 for puzzle box, 2nd for button testing
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'assets/images/puzzleBg.png',
                ),
                fit: BoxFit.cover),
          ),
          width: size.width,
          height: size.width,
          child: Stack(
            children: [
              // we use stack stack our background & puzzle box
              // 1st show image use

              if (slideObjects == null) ...[
                RepaintBoundary(
                  key: _globalKey,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.transparent,
                        height: double.maxFinite,
                        width: double.maxFinite,
                        child: imageBckGround,
                      ),
                    ),
                  ),
                )
              ],
              // 2nd show puzzle with empty
              if (slideObjects != null)
                ...slideObjects!.where((slideObject) => slideObject.empty).map(
                  (slideObject) {
                    return Positioned(
                      left: slideObject.posCurrent.dx,
                      top: slideObject.posCurrent.dy,
                      child: SizedBox(
                        width: slideObject.size.width,
                        height: slideObject.size.height,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          color: Colors.black,
                          child: Stack(
                            children: [
                              if (slideObject.image != null) ...[
                                Opacity(
                                  opacity: success ? 1 : 0.15,
                                  child: slideObject.image,
                                )
                              ]
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              // this for box with not empty flag
              if (slideObjects != null)
                ...slideObjects!.where((slideObject) => !slideObject.empty).map(
                  (slideObject) {
                    // change to animated position
                    // disabled checking success on swap process
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.ease,
                      left: slideObject.posCurrent.dx,
                      top: slideObject.posCurrent.dy,
                      child: GestureDetector(
                        onTap: () => changePos(slideObject.indexCurrent),
                        child: SizedBox(
                          width: slideObject.size.width,
                          height: slideObject.size.height,
                          child: Container(
                            padding: const EdgeInsets.all(5),

                            child: Stack(
                              children: [
                                if (slideObject.image != null) ...[
                                  slideObject.image!
                                ],
                                Center(
                                  child: Text(
                                    "${slideObject.indexDefault}",
                                    style: TextStyle(
                                        color: AppColor.scaffoldBgColor),
                                  ),
                                ),
                                // nice one.. lets make it random
                              ],
                            ),
                            // nice one
                          ),
                        ),
                      ),
                    );
                  },
                )

              // now not show at all because we dont generate slideObjects yet.. lets generate
            ],
          ),
        ),

        SizedBox(
          height: Get.height * 0.01,
        ),
        FittedBox(
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  if (selectedSize >= 6) {
                    setState(() {
                      selectedSize = 3;
                    });
                  } else {
                    setState(() {
                      selectedSize++;
                    });
                  }
                  generatePuzzle();
                },
                child: Container(
                  height: 200,
                  width: Get.width,
                  alignment: Alignment.centerRight,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/icon/gribtn.png',
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "      ${selectedSize.toString()}" +
                          'x' '${selectedSize.toString()}',
                      style: const TextStyle(
                          fontFamily: 'poppins',
                          color: Colors.white,
                          fontSize: 30),
                    ),
                  ),
                ),
              ),
              effectButton(
                  onClick: () {
                    Get.dialog(
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: AlertDialog(
                          backgroundColor: AppColor.scaffoldBgColor,
                          content: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(File(widget.imgPath.path))),
                        ),
                      ),
                    );
                  },
                  child: Image.asset('assets/icon/eye.png'))
            ],
          ),
        ),
        SizedBox(
          height: Get.height * 0.01,
        ),

        GestureDetector(
          onTap: () {
            if (!AppUtils.isSubscribed && puzzleHintReward) {
              Get.dialog(SolvePuzzle(
                onExit: (ctx) {
                  setState(() {});
                },
              ), barrierDismissible: false)
                  .then((value) => setState(() {
                        if (value[0] == true) {
                          reversePuzzle(50);
                        }
                      }));
            } else {
              reversePuzzle(50);
            }
          },
          child: Image.asset(
            'assets/icon/hintbt.png',
            height: 80,
          ),
        )
      ],
    );
  }
}

class SlideObject {
  // setup offset for default / current position
  Offset posDefault;
  Offset posCurrent;
  // setup index for default / current position
  int indexDefault;
  int indexCurrent;
  // status box is empty
  bool empty;
  // size each box
  Size size;
  // Image field for crop later
  Image? image;

  SlideObject({
    this.empty = false,
    this.image,
    required this.indexCurrent,
    required this.indexDefault,
    required this.posCurrent,
    required this.posDefault,
    required this.size,
  });
}

Widget effectButton({
  required VoidCallback onClick,
  required Widget child,
  double? borderRadius,
}) =>
    Stack(
      children: [
        child,

        //*
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius ?? 0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClick,
              ),
            ),
          ),
        ),
      ],
    );
