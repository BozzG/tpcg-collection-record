import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/views/edit_card_page.dart';

class AddCardPage extends StatelessWidget {
  final int projectId;

  const AddCardPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return EditCardPage(projectId: projectId);
  }
}
