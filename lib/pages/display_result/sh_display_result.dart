import 'dart:convert';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:sign_helper/utils/utility.dart';
import 'package:sign_helper/widgets/appbars/sh_main_app_bar.dart';
import 'package:sign_helper/widgets/sh_background_container.dart';
import 'package:video_player/video_player.dart';

import '../../resources/app_colors.dart';


class SHDisplayResultPage extends StatefulWidget {
  const SHDisplayResultPage({super.key, required this.inputVideo, required this.signHelperVideo});

  final File inputVideo;
  final File signHelperVideo;

  @override
  State<SHDisplayResultPage> createState() => _SHDisplayResultPageState();
}

class _SHDisplayResultPageState extends State<SHDisplayResultPage> {
  late VideoPlayerController _signHelperVideoController;
  late VideoPlayerController _sourceVideoController;
  late Future<void> _initializeSignHelperVideoPlayerFuture;
  late Future<void> _initializeSourceVideoPlayerFuture;
  late ChewieController _sourceVideoControllerChewie;
  late ChewieController _signHelperVideoControllerChewie;


  @override
  void initState() {
    _sourceVideoController = VideoPlayerController.file(widget.inputVideo);
    _initializeSourceVideoPlayerFuture = _sourceVideoController.initialize().then((value) {
      _sourceVideoControllerChewie = ChewieController(
        videoPlayerController: _sourceVideoController,
        autoPlay: false,
        looping: false,
        allowPlaybackSpeedChanging: false,
        allowFullScreen: false,
        showControls: true,
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
    });

    _signHelperVideoController = VideoPlayerController.file(widget.signHelperVideo);
    _initializeSignHelperVideoPlayerFuture = _signHelperVideoController.initialize().then((value) => _signHelperVideoControllerChewie = ChewieController(
        videoPlayerController: _signHelperVideoController,
        autoPlay: false,
        looping: false,
        allowPlaybackSpeedChanging: false,
        allowFullScreen: false,
        showControls: true,
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      )
    );

    super.initState();
  }

  @override
  void dispose() {
    _sourceVideoController.dispose();
    _sourceVideoControllerChewie.dispose();
    _signHelperVideoController.dispose();
    _signHelperVideoControllerChewie.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SHMainAppBar(
        title: "Kết quả",
      ),
      body: SafeArea(
        child: SHBackgroundContainer(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: FutureBuilder(
                  future: _initializeSourceVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _sourceVideoController.value.aspectRatio,
                        child: Chewie(controller: _sourceVideoControllerChewie),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 1,
                child: FutureBuilder(
                  future: _initializeSignHelperVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _signHelperVideoController.value.aspectRatio,
                        child: Chewie(controller: _signHelperVideoControllerChewie),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              const SizedBox(height: 50)
            ],
          ),
        ),
      ),
    );
  }
}
