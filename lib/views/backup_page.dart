import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/services/backup_service.dart';
import 'package:tpcg_collection_record/services/database_service.dart';
import 'package:tpcg_collection_record/viewmodels/home_viewmodel.dart';
import 'package:tpcg_collection_record/views/widgets/showcase_background.dart';

/// 数据备份页：导出全量数据为 JSON 分享；从 JSON 导入整体恢复。
class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _busy = false;
  final GlobalKey _exportTileKey = GlobalKey();

  /// 计算给定 key 所指控件的全局矩形，用作 iPad 分享弹层锚点。
  Rect? _originFrom(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);
    final db = context.read<DatabaseService>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await BackupService.exportAndShare(
      db,
      sharePositionOrigin: _originFrom(_exportTileKey),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('导出备份失败，请重试')),
      );
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入恢复'),
        content: const Text(
          '导入将【清空当前全部项目与卡片】，并以所选备份完整替换，此操作无法撤销。\n\n确定继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定导入'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    final db = context.read<DatabaseService>();
    final homeVm = context.read<HomeViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await BackupService.pickAndImport(db);
      if (!mounted) return;
      setState(() => _busy = false);
      if (result == null) return; // 用户取消选择
      await homeVm.refresh();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              '恢复成功：${result.projects} 个项目 · ${result.cards} 张卡片'),
        ),
      );
    } on FormatException {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('备份文件格式不正确，无法导入')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('导入失败，请检查文件后重试')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('数据备份')),
      body: ShowcaseBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 说明
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('关于备份',
                              style: textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '备份文件为 JSON，包含全部项目与卡片的文字信息（名称、评级、价格、日期等），'
                        '可用于换机迁移或留底。\n\n'
                        '注意：备份不含卡片图片文件，恢复到新设备后需重新设置图片。',
                        style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _actionTile(
                icon: Icons.ios_share,
                title: '导出备份',
                subtitle: '生成 JSON 并通过系统分享保存',
                onTap: _export,
                tileKey: _exportTileKey,
              ),
              _actionTile(
                icon: Icons.restore,
                title: '导入恢复',
                subtitle: '选择备份文件，整体替换当前数据',
                onTap: _import,
                danger: true,
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
    Key? tileKey,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = danger ? colorScheme.error : colorScheme.primary;
    return Card(
      key: tileKey,
      child: ListTile(
        leading: Icon(icon, color: accent),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: _busy ? null : onTap,
      ),
    );
  }
}
