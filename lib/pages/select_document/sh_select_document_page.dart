import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_helper/pages/display_result/sh_display_result.dart';
import 'package:sign_helper/resources/app_colors.dart';
import 'package:sign_helper/utils/utility.dart';
import 'package:sign_helper/widgets/appbars/sh_main_app_bar.dart';
import 'package:sign_helper/widgets/buttons/sh_no_splash_button.dart';
import 'package:sign_helper/widgets/sh_background_container.dart';
import 'package:sign_helper/widgets/sh_text.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class SHSelectDocumentPage extends StatefulWidget {
  const SHSelectDocumentPage({super.key});

  @override
  State<SHSelectDocumentPage> createState() => _SHSelectDocumentPageState();
}

class _SHSelectDocumentPageState extends State<SHSelectDocumentPage> {

  late File inputVideo;
  late String textExtracted;
  late File signHelperVideo;
  late String signHelperVideoLink;

  void _saveSourceVideo() async {
    var dir = await getApplicationDocumentsDirectory();
    final inputVideoName = inputVideo.path.split("/").last;
    inputVideo.copy("${dir.path}/${inputVideoName}");
    _uploadVideoToServer();
  }

  void _addSourceVideoToDocumentList() async {
    Map<String, String> document = {
      "name": inputVideo.path.split("/").last,
      "sourceVideoPath": inputVideo.path,
      "signHelperVideoPath": signHelperVideo.path,
      "date": DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0).toString().replaceAll("00:00:00.000", ""),
    };
    try {
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString(inputVideo.path.split("/").last, jsonEncode(document));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SHDisplayResultPage(
            inputVideo: inputVideo,
            signHelperVideo: signHelperVideo,
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SHText(
            title: "Không thể thêm tệp tin",
            fontSize: 16,
            textColor: SHColors.neutral0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  void _downloadSignHelperVideo() async {
    Dio dio = Dio();
    EasyLoading.show(status: "Đang tải video ngôn ngữ ký hiệu...");
    try {
      var dir = await getApplicationDocumentsDirectory();
      debugPrint(dir.path);
      final inputVideoName = inputVideo.path.split("/").last;
      await dio.download("https://dl.dropboxusercontent.com/scl/fi/efg51rjoo2f0ufb8jie26/sign_helper_demo.mp4?rlkey=mjnvi95b4cbp04ae5mpzwh779&dl=0", "${dir.path}/${inputVideoName}_sign_helper_video.mp4");
      signHelperVideo = File("${dir.path}/${inputVideoName}_sign_helper_video.mp4");
      _addSourceVideoToDocumentList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SHText(
            title: "Không thể tải video ngôn ngữ ký hiệu",
            fontSize: 16,
            textColor: SHColors.neutral0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    EasyLoading.dismiss();
  }

  void _getSignHelperVideoLink() async {
    const url = "222.252.4.92:9091";
    var uri = Uri.http(url, "/transformTextToSpeech/", {"text": textExtracted});
    EasyLoading.show(status: "Đang chuyển sang ngôn ngữ ký hiệu...");
    try {
      var response = await http.post(uri);
      var responseJson = jsonDecode(response.body);
      var message = jsonDecode(responseJson["message"]);
      var result = message["result"];
      signHelperVideoLink = result["audio_link"];
      debugPrint(signHelperVideoLink);
      _downloadSignHelperVideo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SHText(
            title: "Không thể chuyển sang ngôn ngữ ký hiệu",
            fontSize: 16,
            textColor: SHColors.neutral0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    EasyLoading.dismiss();
  }

  void _getKeywordListFromText(text){
    const start = "[";
    const end = "]";
    final startIndex = text.indexOf(start);
    final endIndex = text.indexOf(end, startIndex + start.length);
    var result = text.substring(startIndex + start.length, endIndex);
    setState(() {
      textExtracted = result;
    });
    _getSignHelperVideoLink();
  }

  void _uploadVideoToServer() async {
    var stream = inputVideo.readAsBytes().asStream();
    var length = inputVideo.lengthSync();
    var uri = Uri.parse("http://222.252.4.92:9091/uploadVideo/");
    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: inputVideo.path
            .split("/")
            .last
    );
    request.files.add(multipartFile);
    EasyLoading.show(status: "Đang xử lý video...");
    try {
      var response = await request.send();
      final responseJson = json.decode(await response.stream.bytesToString());
      _getKeywordListFromText(responseJson["message"]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SHText(
            title: "Không thể tải video lên máy chủ",
            fontSize: 16,
            textColor: SHColors.neutral0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    EasyLoading.dismiss();
  }

  void _onTapSelectFile({required BuildContext context}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        inputVideo = file;
      });
      _saveSourceVideo();
    }
  }

  void _onTapCamera({required BuildContext context}) {
    const SnackBar snackBar = SnackBar(
      content: SHText(
        title: "Chức năng đang phát triển",
        fontSize: 16,
        textColor: SHColors.neutral0,
        fontWeight: FontWeight.w600,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SHMainAppBar(title: "Thêm tệp tin mới"),
      body: SHBackgroundContainer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SHNoSplashButton(
                  onTap: () => _onTapSelectFile(context: context),
                  child: SizedBox(
                    height: 250,
                    width: double.maxFinite,
                    child: DottedBorder(
                      borderPadding: EdgeInsets.zero,
                      dashPattern: const [8, 8],
                      radius: const Radius.circular(16),
                      borderType: BorderType.RRect,
                      color: SHColors.primaryBlue,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              Utility.getFullImagePath("select_file"),
                              height: 120,
                              width: 120,
                            ),
                            const SHText(
                              title: "Tải lên tập tin",
                              fontSize: 16,
                              textColor: SHColors.neutral3,
                              fontWeight: FontWeight.w600,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  width: double.maxFinite,
                  child: SHNoSplashButton(
                    onTap: () => _onTapCamera(context: context),
                    child: DottedBorder(
                      borderPadding: EdgeInsets.zero,
                      dashPattern: const [8, 8],
                      radius: const Radius.circular(16),
                      borderType: BorderType.RRect,
                      color: SHColors.primaryBlue,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              Utility.getFullImagePath("select_camera"),
                              height: 120,
                              width: 120,
                            ),
                            const SHText(
                              title: "Chụp ảnh/Quay video",
                              fontSize: 16,
                              textColor: SHColors.neutral3,
                              fontWeight: FontWeight.w600,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                )
              ],
            ),
          )
      ),
    );
  }
}
