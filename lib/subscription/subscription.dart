// ignore_for_file: must_be_immutable, camel_case_types

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camery/src/pages/puzzles/puzzlesolscreen.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:camery/subscription/endless_animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onepref/onepref.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Package selectedPackage = Package.removeAdmonthly;

  InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<dynamic> subscription;
  List<ProductDetails> products = [];
  bool isStoreLoaded = false;
  final Set<String> variants = {
    'com.monthlyremoveadsgpscamera',
    'com.yearlyremoveadsgpscamera',
  };

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isshowbtn = true;
        });
      }
    });
    super.initState();

    Stream purchaseUpdate = inAppPurchase.purchaseStream;

    subscription = purchaseUpdate.listen((purchaseList) {
      listenToPurchase(purchaseList);
    }, onDone: () {
      subscription.cancel();
    }, onError: (error) {
      Fluttertoast.showToast(msg: error, textColor: Colors.white);
    });
    initStore();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  bool isshowbtn = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColor.scaffoldBgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: isshowbtn
            ? IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.cancel_outlined))
            : const SizedBox(),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [_buildRestoreButton()],
      ),
      body: Stack(
        children: [
          EndlessAnimation(height: Get.height * 0.4, width: Get.width),
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.black
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: Get.height * 0.35,
                  ),
                  Image.asset(
                    'assets/icon/jointxt.png',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  !isStoreLoaded
                      ? SizedBox(
                          height: Get.height * 0.3,
                          child: Center(
                            child: LoadingAnimationWidget.stretchedDots(
                                color: const Color(0xff2C68B8), size: 50),
                          ),
                        )
                      : products.isEmpty
                          ? SizedBox(
                              height: Get.height * 0.1,
                              child: Center(
                                child: Text(
                                  "No Package Found. Try Again Later!".tr,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  products.length,
                                  (index) => InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedProductIndex = index;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: premiumTile(
                                            selectIndex: index,
                                            productsDetails: products,
                                          ),
                                        ),
                                      )),
                            ),
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  effectButton(
                    onClick: () {
                      if (products.isEmpty) {
                        Fluttertoast.showToast(msg: 'No Packages Found');
                      } else {
                        buy(products[selectedProductIndex]);
                      }
                    },
                    child: Image.asset(
                      'assets/icon/subs.png',
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'poppins'),
                        children: [
                          TextSpan(
                              text: 'By placing this order, you agree to the '
                                  .tr),
                          TextSpan(
                              text: 'Terms of Service '.tr,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _launchURL(Platform.isAndroid
                                      ? "https://pearsoft.app/terms-of-use/"
                                      : "https://dartsol.net/terms-of-conditions");
                                },
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const TextSpan(text: 'and '),
                          TextSpan(
                            text: 'Privacy Policy. ',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _launchURL(Platform.isAndroid
                                    ? "https://pearsoft.app/privacy-policy/"
                                    : "https://dartsol.net/privacy-policy/");
                              },
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                              text:
                                  'Without commitment, you can cancel whenever you want. if you don\'t cancel the subscription 24 hour before the end of the current period, you will be automatically changed through your play store account.\nEven if you don\'t subscribe you can still use all the free feature.')
                        ],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.02,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton() {
    return IconButton(
      onPressed: () async {
        if (products.isEmpty) {
          Fluttertoast.showToast(msg: 'No Packages Found');
        } else {
          final bool isAvailable = await inAppPurchase.isAvailable();

          if (!isAvailable) {
            Get.snackbar(
                'Restore Purchase', 'There are no upgrades at this time',
                colorText: Colors.white);

            return;
          } else {
            await inAppPurchase.restorePurchases();
          }
        }
      },
      icon: const Icon(
        Icons.restore,
        color: Colors.white,
      ),
    );
  }

  listenToPurchase(List<PurchaseDetails> purchaseList) {
    // ignore: avoid_function_literals_in_foreach_calls
    purchaseList.forEach((purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        Fluttertoast.showToast(msg: 'Pending');
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await inAppPurchase.completePurchase(purchaseDetails);
      }
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        try {
          await inAppPurchase.completePurchase(purchaseDetails);

          OnePref.setRemoveAds(true);

          Get.snackbar("Success", "Subscribed Successfully",
              colorText: Colors.white);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
      if (purchaseDetails.status == PurchaseStatus.restored) {
        try {
          await inAppPurchase.completePurchase(purchaseDetails);

          OnePref.setRemoveAds(true);

          Get.snackbar("Success", "Subscribed Successfully",
              colorText: Colors.white);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    });
  }

  Future<void> initStore() async {
    ProductDetailsResponse response =
        await inAppPurchase.queryProductDetails(variants);

    if (response.error == null) {
      setState(() {
        products = response.productDetails;
        isStoreLoaded = true;
      });
      log("${response.notFoundIDs}");
    } else {
      log("${response.error}");
    }
  }

  buy(ProductDetails productDetails) {
    final PurchaseParam param = PurchaseParam(productDetails: productDetails);
    inAppPurchase.buyNonConsumable(purchaseParam: param);
  }

  void _launchURL(url) async {
    await canLaunchUrl(Uri.parse(url))
        ? await launchUrl(Uri.parse(url))
        : throw 'could not launch the url';
  }
}

class premiumTile extends StatelessWidget {
  premiumTile(
      {super.key, required this.productsDetails, required this.selectIndex});
  List<ProductDetails> productsDetails;
  int selectIndex;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.4,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(
            color: selectIndex == selectedProductIndex
                ? const Color(0xff663DC1)
                : Colors.transparent, // Your border color here
            width: 2.0, // Border width
          ),
          borderRadius: BorderRadius.circular(8.0), // Border radius
          color: AppColor.scaffoldBgColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            productsDetails[selectIndex].title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
          Text(
            productsDetails[selectIndex].price,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class SubscriptionImageModel {
  final String image;
  final String text;

  SubscriptionImageModel({required this.text, required this.image});
}

int selectedProductIndex = 0;

enum Package { removeAdmonthly, removeAdyearly }

class SubscriptionBulletPoint extends StatelessWidget {
  final String text;

  const SubscriptionBulletPoint({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
