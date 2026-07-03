import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/models/ptcg_project.dart';
import 'package:tpcg_collection_record/services/image_service.dart';
import 'package:tpcg_collection_record/services/share_service.dart';
import 'package:tpcg_collection_record/views/widgets/share_card_templates.dart';

/// 分享预览页：渲染分享海报（单卡 / 项目），预解码图片后一键调起系统分享。
class SharePreviewPage extends StatefulWidget {
  /// 单卡分享。
  const SharePreviewPage.card(TCGCard card, {super.key})
      : _card = card,
        _project = null,
        _projectCards = null;

  /// 项目分享。
  const SharePreviewPage.project(
    TCGProject project,
    List<TCGCard> cards, {
    super.key,
  })  : _card = null,
        _project = project,
        _projectCards = cards;

  final TCGCard? _card;
  final TCGProject? _project;
  final List<TCGCard>? _projectCards;

  bool get _isProject => _project != null;

  @override
  State<SharePreviewPage> createState() => _SharePreviewPageState();
}

class _SharePreviewPageState extends State<SharePreviewPage> {
  final GlobalKey _boundaryKey = GlobalKey();
  final GlobalKey _shareButtonKey = GlobalKey();

  bool _ready = false;
  bool _sharing = false;

  PosterCardItem? _cardItem;
  List<PosterCardItem> _projectItems = const [];

  /// 项目海报最多展示的缩略图数量（与模板一致）。
  static const int _maxThumbs = 9;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    if (widget._isProject) {
      final cards = widget._projectCards ?? const [];
      final items = <PosterCardItem>[];
      for (var i = 0; i < cards.length; i++) {
        // 仅前 _maxThumbs 张需要图片（其余只参与统计）
        String? path;
        if (i < _maxThumbs) {
          path = await ImageService.resolveAbsolutePath(cards[i].frontImage);
          if (path != null && mounted) {
            await precacheImage(FileImage(File(path)), context);
          }
        }
        items.add(PosterCardItem(card: cards[i], imagePath: path));
      }
      if (!mounted) return;
      setState(() {
        _projectItems = items;
        _ready = true;
      });
    } else {
      final card = widget._card!;
      final path = await ImageService.resolveAbsolutePath(card.frontImage);
      if (path != null && mounted) {
        await precacheImage(FileImage(File(path)), context);
      }
      if (!mounted) return;
      setState(() {
        _cardItem = PosterCardItem(card: card, imagePath: path);
        _ready = true;
      });
    }
  }

  Future<void> _onShare() async {
    if (_sharing || !_ready) return;
    setState(() => _sharing = true);
    // 等当前帧绘制完成，确保 RepaintBoundary 已是最终画面
    await WidgetsBinding.instance.endOfFrame;

    final String fileName;
    final String shareText;
    if (widget._isProject) {
      final p = widget._project!;
      fileName = 'tpcg_project_${p.id ?? 'x'}.png';
      shareText = '${p.name} · 共 ${_projectItems.length} 张藏品';
    } else {
      final c = widget._card!;
      fileName = 'tpcg_card_${c.id ?? 'x'}.png';
      shareText = '${c.name} · ¥${c.currentPrice.toStringAsFixed(2)}';
    }

    final ok = await ShareService.captureAndShare(
      boundaryKey: _boundaryKey,
      fileName: fileName,
      shareText: shareText,
      sharePositionOrigin: _originFrom(_shareButtonKey),
    );

    if (!mounted) return;
    setState(() => _sharing = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('生成分享图失败，请重试')),
      );
    }
  }

  /// 计算给定 key 所指控件的全局矩形，用作 iPad 分享弹层锚点。
  Rect? _originFrom(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final posterWidth = (screenWidth - 32).clamp(280.0, 420.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget._isProject ? '分享项目' : '分享藏品'),
      ),
      body: _ready
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget._isProject
                        ? ProjectPosterCard(
                            project: widget._project!,
                            items: _projectItems,
                            width: posterWidth,
                            maxThumbs: _maxThumbs,
                          )
                        : CollectionPosterCard(
                            item: _cardItem!,
                            width: posterWidth,
                          ),
                  ),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            key: _shareButtonKey,
            onPressed: _ready && !_sharing ? _onShare : null,
            icon: _sharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.ios_share),
            label: Text(_sharing ? '生成中…' : '分享长图'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ),
    );
  }
}
