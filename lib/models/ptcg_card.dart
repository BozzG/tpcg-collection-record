import 'package:freezed_annotation/freezed_annotation.dart';

part 'ptcg_card.freezed.dart';
part 'ptcg_card.g.dart';

@freezed
class PTCGCard with _$PTCGCard {
  const factory PTCGCard({
    int? id, // 系统分配的id，可以为空
    required int projectId, // 所属项目Id
    required String name, // 卡片名字
    required String issueNumber, // 卡片发行编号
    required String issueDate, // 发行时间
    required String grade, // 评级
    required String acquiredDate, // 入手时间
    required double acquiredPrice, // 入手价格
    required double currentPrice, // 当前成交价
    String? frontImage, // 正面图
    String? backImage, // 背面图
    String? gradeImage, // 评级图
  }) = _PTCGCard;

  factory PTCGCard.fromJson(Map<String, dynamic> json) =>
      _$PTCGCardFromJson(json);
}