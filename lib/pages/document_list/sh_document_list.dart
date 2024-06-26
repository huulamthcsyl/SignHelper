import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_helper/pages/document_list/document_item/sh_document_list_item.dart';
import 'package:sign_helper/pages/select_document/sh_select_document_page.dart';
import 'package:sign_helper/resources/app_colors.dart';
import 'package:sign_helper/widgets/app_icon.dart';
import 'package:sign_helper/widgets/appbars/sh_main_app_bar.dart';
import 'package:sign_helper/widgets/sh_background_container.dart';

class SHDocumentListPage extends StatefulWidget {
  const SHDocumentListPage({super.key});

  @override
  State<SHDocumentListPage> createState() => _SHDocumentListPageState();
}

class _SHDocumentListPageState extends State<SHDocumentListPage> {

  List<Map<String, String>> documents = [];

  @override
  void initState(){
    SharedPreferences.getInstance().then((preferences) {
      preferences.getKeys().forEach((key) {
        documents.add(Map<String, String>.from(jsonDecode(preferences.getString(key)!)));
      });
      setState(() {
        documents = documents;
      });
    });

    super.initState();
  }

  void _onTapPlusClosure({required BuildContext context}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SHSelectDocumentPage(),
      ),
    ).then((value) => setState(() {
      SharedPreferences.getInstance().then((preferences) {
        documents.clear();
        preferences.getKeys().forEach((key) {
          documents.add(Map<String, String>.from(jsonDecode(preferences.getString(key)!)));
        });
        setState(() {
          documents = documents;
        });
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SHMainAppBar(
        title: "Danh sách tập tin",
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTapPlusClosure(context: context),
        backgroundColor: SHColors.primaryBlue,
        shape: const CircleBorder(),
        child: const SHIcon(
          "plus",
          color: Colors.white,
        ),
      ),
      body: SHBackgroundContainer(
        child: Container(
          color: Colors.transparent,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return SHDocumentListItem(
                sourceVideoName: documents[index]["name"]!,
                sourceVideoPath: documents[index]["sourceVideoPath"]!,
                signHelperVideoPath: documents[index]["signHelperVideoPath"]!,
                uploadDate: documents[index]["date"]!,
              );
            },
          ),
        ),
      ),
    );
  }
}
