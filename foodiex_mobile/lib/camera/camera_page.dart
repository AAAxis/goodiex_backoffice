import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'food_scan_result_screen.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(438, 950),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CameraPreview(_controller!),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomProgressBar(value: 0.7),
                // Padding(
                //   padding: EdgeInsets.only(),
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         "Thinking",
                //         style: GoogleFonts.inter(
                //           color: Colors.white.withValues(alpha: 0.70),
                //           fontSize: 11.sp,
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //       SizedBox(
                //         width: 77.w,
                //       ),
                //       Text(
                //         "Testing Food",
                //         style: GoogleFonts.inter(
                //           color: Colors.white,
                //           fontSize: 17.sp,
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //       SizedBox(
                //         width: 34.w,
                //       ),
                //       Text(
                //         "Checking Carbs",
                //         style: GoogleFonts.inter(
                //           color: Colors.white.withValues(alpha: 0.70),
                //           fontSize: 11.sp,
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //     ],
                //   ),
                // )
                // checking protein
                // Container(
                //   alignment: Alignment.center,
                //   height: 50.h,
                //   width: 241.w,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(44.r),
                //     color: Color(0xffFEFEFE),
                //   ),
                //   margin: EdgeInsets.only(top: 46.h, left: 27.w),
                //   padding: EdgeInsets.only(left: 13.9.w),
                //   child: Row(
                //     children: [
                //       Image.asset(
                //         "assets/checkProteinImage.png",
                //         height: 32.48.h,
                //         width: 32.48.w,
                //       ),
                //       Text(
                //         "Checking Protein",
                //         style: GoogleFonts.inter(
                //           fontSize: 22.sp,
                //           fontWeight: FontWeight.w400,
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                // progress bar

                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 102.h),
                    width: 300.w,
                    height: 300.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.r),
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                        color: Colors.white, width: 2.w),
                                    left: BorderSide(
                                        color: Colors.white, width: 2.w),
                                  ),
                                ),
                                width: 66.w,
                                height: 66.h),
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.r),
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                        color: Colors.white, width: 2.w),
                                    right: BorderSide(
                                        color: Colors.white, width: 2.w),
                                  ),
                                ),
                                width: 66.w,
                                height: 66.h),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10.r),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.white, width: 2.w),
                                    left: BorderSide(
                                        color: Colors.white, width: 2.w),
                                  ),
                                ),
                                width: 66.w,
                                height: 66.h),
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10.r),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.white, width: 2.w),
                                    right: BorderSide(
                                        color: Colors.white, width: 2.w),
                                  ),
                                ),
                                width: 66.w,
                                height: 66.h),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    containerButton(
                        assetName: "assets/barCodeIcon.png",
                        onTap: () {},
                        text: "Barcode"),
                    containerButton(
                        assetName: "assets/scanFoodIcon.png",
                        onTap: () {},
                        text: "Scan Food"),
                    containerButton(
                        assetName: "assets/menuIcon.png",
                        onTap: () {},
                        text: "Menu"),
                  ],
                ),
                MainCameraButtonsWidget()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      {required String iconPath, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 24.w,
            height: 24.h,
          ),
        ),
      ),
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final double value;

  const CustomProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.r)),
              color: Color(0xffF4F4F4)),
          margin: EdgeInsets.only(
            left: 39.w,
            top: 35.h,
            right: 35.w,
            bottom: 13.h,
          ),
          height: 7.h,
          width: 347.w,
          child: LinearProgressIndicator(
            borderRadius: BorderRadius.all(Radius.circular(20.r)),
            value: value,
            backgroundColor: Color(0xff6B6B6B).withValues(alpha: 0.70),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 43.w, right: 35.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Thinking",
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 77.w,
              ),
              Text(
                "Testing Food",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 34.w,
              ),
              Text(
                "Checking Carbs",
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget containerButton(
    {required String assetName,
    required Function() onTap,
    required String text}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      width: 102.w,
      height: 95.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetName,
            height: 44.h,
            width: 44.w,
          ),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    ),
  );
}

class MainCameraButtonsWidget extends StatelessWidget {
  const MainCameraButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 49.h, left: 53.w, right: 48.w, bottom: 78.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            "assets/flashIcon.png",
            height: 34.h,
            width: 34.w,
          ),
          SizedBox(width: 96.w),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FoodScanResultScreen()),
              );
            },
            child: Image.asset(
              "assets/cameraButtonIcon.png",
              height: 75.h,
              width: 75.w,
            ),
          ),



          SizedBox(width: 77.w),
          Image.asset(
            "assets/galleryIcon.png",
            height: 55.h,
            width: 55.w,
          )
        ],
      ),
    );
  }
}
