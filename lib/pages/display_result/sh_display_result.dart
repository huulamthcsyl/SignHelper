import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:sign_helper/utils/utility.dart';
import 'package:sign_helper/widgets/appbars/sh_main_app_bar.dart';
import 'package:sign_helper/widgets/sh_background_container.dart';
import 'package:video_player/video_player.dart';

class SHDisplayResultPage extends StatefulWidget {
  const SHDisplayResultPage({super.key, required this.inputVideo});

  final File inputVideo;

  @override
  State<SHDisplayResultPage> createState() => _SHDisplayResultPageState();
}

class _SHDisplayResultPageState extends State<SHDisplayResultPage> {
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  var textExtracted = "";

  void getVideoFromServer() async {
    var stream = widget.inputVideo.readAsBytes().asStream();
    var length = widget.inputVideo.lengthSync();
    var uri = Uri.parse("http://222.252.4.92:9091/uploadVideo/");
    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: widget.inputVideo.path.split("/").last
    );
    request.files.add(multipartFile);
    EasyLoading.show(status: "Loading...");
    var response = await request.send();
    EasyLoading.dismiss();
    final responseJson = json.decode(await response.stream.bytesToString());
    setState(() {
      textExtracted = responseJson["text"];
    });
    // print("Text: $textExtracted");
  }

  @override
  void initState() {
    getVideoFromServer();
    // _videoController = VideoPlayerController.asset("assets/videos/demo.mp4");
    // _videoController =
    //     VideoPlayerController.asset("assets/videos/action_4.mov");
    // _videoController = VideoPlayerController.networkUrl(Uri.parse(
    //     "https://dl.dropboxusercontent.com/scl/fi/efg51rjoo2f0ufb8jie26/sign_helper_demo.mp4?rlkey=mjnvi95b4cbp04ae5mpzwh779&dl=0"));
    // _videoController = VideoPlayerController.networkUrl(Uri.parse(
    //     "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"));
    _initializeVideoPlayerFuture = _videoController.initialize().then((value) {
      _videoController.setLooping(true);
      _videoController.setVolume(0);
      _videoController.play();
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _videoController.pause();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SHMainAppBar(
        title: "Kết quả",
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Wrap the play or pause in a call to `setState`. This ensures the
      //     // correct icon is shown.
      //     setState(() {
      //       // If the video is playing, pause it.
      //       if (_videoController.value.isPlaying) {
      //         _videoController.pause();
      //       } else {
      //         // If the video is paused, play it.
      //         _videoController.play();
      //       }
      //     });
      //   },
      //   shape: const CircleBorder(),
      //   backgroundColor: SHColors.primaryBlue,
      //   // Display the correct icon depending on the state of the player.
      //   child: Icon(
      //     _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //     color: Colors.white,
      //   ),
      // ),
      body: SafeArea(
        child: SHBackgroundContainer(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: double.maxFinite,
                  // child: FutureBuilder(
                  //   future: _initializeVideoPlayerFuture,
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.done) {
                  //       return FittedBox(
                  //         fit: BoxFit.contain,
                  //         child: SizedBox(
                  //           height: _videoController.value.size.height,
                  //           width: _videoController.value.size.width,
                  //           child: VideoPlayer(_videoController),
                  //         ),
                  //       );
                  //     } else {
                  //       return const Center(
                  //         child: CircularProgressIndicator(
                  //           color: SHColors.primaryBlue,
                  //         ),
                  //       );
                  //     }
                  //   },
                  // ),
                  child: Text(textExtracted)
                ),
              ),
              // Expanded(
              //   flex: 1,
              //   child: Image.asset(
              //     Utility.getFullImagePath("meo_con_di_hoc"),
              //     width: double.maxFinite,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
