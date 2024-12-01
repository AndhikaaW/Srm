import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    print("InternetController initialized");
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen(NetStatus);
  }

  Future<void> _checkInitialConnection() async {
    print("Checking initial connection");
    ConnectivityResult result = await _connectivity.checkConnectivity();
    print("Initial connection status: $result");
    NetStatus(result);
  }

  void NetStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.none:
        print("No internet connection - attempting to show snackbar");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!Get.isSnackbarOpen) {
            Get.rawSnackbar(
              titleText: SizedBox(
                width: double.infinity,
                height: Get.size.height / 1.1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: NoInternetConnection(),
                ),
              ),
              messageText: Container(),
              backgroundColor: Colors.transparent,
              isDismissible: false,
              duration: const Duration(days: 1),
            );
          }
        });
        break;
      default:
        if (Get.isSnackbarOpen) {
          print("Closing snackbar");
          Get.closeCurrentSnackbar();
        }
        break;
    }
  }
}

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        ClipPath(
          clipper: CustomClip(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            width: double.maxFinite,
            height: 200,
            child: const Center(
              child: Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ),
        const Positioned(
          top: 180,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Whoops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'No Internet Connection found.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Check your connection & try again.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
