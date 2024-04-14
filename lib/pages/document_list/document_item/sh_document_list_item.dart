import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_helper/resources/app_colors.dart';
import 'package:sign_helper/utils/utility.dart';
import 'package:sign_helper/widgets/app_icon.dart';
import 'package:sign_helper/widgets/sh_text.dart';
import 'dart:io';

import '../../display_result/sh_display_result.dart';

class SHDocumentListItem extends StatelessWidget {
  final String sourceVideoName;
  final String sourceVideoPath;
  final String signHelperVideoPath;
  final String uploadDate;

  const SHDocumentListItem({
    super.key,
    required this.uploadDate,
    required this.sourceVideoName,
    required this.sourceVideoPath,
    required this.signHelperVideoPath,
  });
  
  void _showDocument({required BuildContext context}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SHDisplayResultPage(
          inputVideo: File(sourceVideoPath),
          signHelperVideo: File(signHelperVideoPath),
        ),
      ),
    );

  }

  void _deleteDocument({required BuildContext context}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(sourceVideoName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SHText(
          title: "Đã xóa tập tin $sourceVideoName thành công",
          fontSize: 14,
          textColor: SHColors.neutral6,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDocument(context: context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SHText(
                  title: sourceVideoName,
                  fontSize: 14,
                  textColor: SHColors.neutral6,
                  fontWeight: FontWeight.w400,
                ),
                SHText(
                  title: "Tải lên ngày ${uploadDate}",
                  fontSize: 11,
                  textColor: SHColors.neutral8,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => _deleteDocument(context: context),
            child: const SHIcon(
              "trash_can",
              color: Color(0xFFFF3030),
              size: 24,
            ),
          ),
        ],
      )
    );
  }
}
