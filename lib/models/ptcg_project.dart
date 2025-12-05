import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';

part 'ptcg_project.freezed.dart';
part 'ptcg_project.g.dart';

@freezed
class PTCGProject with _$PTCGProject {
  const factory PTCGProject({
    int? id, // 系统分配的id，可以为空
    required String name, // 项目名字
    required String description, // 项目描述
    @Default([]) List<PTCGCard> cards, // 卡片列表
  }) = _PTCGProject;

  factory PTCGProject.fromJson(Map<String, dynamic> json) =>
      _$PTCGProjectFromJson(json);
}