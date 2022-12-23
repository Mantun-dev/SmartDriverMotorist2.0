import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/constants.dart';
import 'package:video_player/video_player.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/mantunStart.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
    _controller!.play();
  }

  Future<void> initializeSettings() async {
    //Simulate other services for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return waitingView();
        } else {
          if (snapshot.hasError) {
            return errorView(snapshot);
          } else {
            return WelcomeScreen();
          }
        }
      },
    );
  }

  Scaffold errorView(AsyncSnapshot<dynamic> snapshot) {
    return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
  }

  Scaffold waitingView() {
    const primary = backgroundColor;
    return Scaffold(
        body: Container(
            color: primary,
            child: Center(
                child: _controller!.value.isInitialized
                    ? SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Transform.scale(
                              scale: 1.1,
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: _controller!.value.size.width,
                                      height: _controller!.value.size.height,
                                      child: AspectRatio(
                                          aspectRatio:
                                              _controller!.value.aspectRatio,
                                          child: VideoPlayer(_controller!))),
                                ],
                              )),
                        ),
                      )
                    : Container(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: LiquidCircularProgressIndicator(
                            value: 0.5, // Defaults to 0.5.
                            valueColor: AlwaysStoppedAnimation(
                                thirdColor), // Defaults to the current Theme's accentColor.
                            backgroundColor:
                                backgroundColor, // Defaults to the current Theme's backgroundColor.
                            borderColor: thirdColor,
                            borderWidth: 5.0,
                            direction: Axis.vertical,
                            center: Text(
                              'Cargando...',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ))));
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }
}
