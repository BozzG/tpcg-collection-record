import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';

part 'ptcg_project.freezed.dart';
part 'ptcg_project.g.dart';

@freezed
class TCGProject with _$TCGProject {
  const factory TCGProject({
    int? id, // 系统分配的id，可以为空
    required String name, // 项目名字
    required String description, // 项目描述
    @Default([]) List<TCGCard> cards, // 卡片列表
  }) = _TCGProject;

  factory TCGProject.fromJson(Map<String, dynamic> json) =>
      _$TCGProjectFromJson(json);
}