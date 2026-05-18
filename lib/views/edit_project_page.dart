import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/models/ptcg_project.dart';
import 'package:tpcg_collection_record/viewmodels/project_viewmodel.dart';

class EditProjectPage extends StatefulWidget {
  final TCGProject? project;

  const EditProjectPage({super.key, this.project});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑项目' : '添加项目'),
        actions: [
          TextButton(
            onPressed: _saveProject,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '项目信息',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '项目名称',
                      border: OutlineInputBorder(),
                      helperText: '为您的收藏项目起一个名字',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入项目名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '项目描述',
                      border: OutlineInputBorder(),
                      helperText: '描述这个项目的特点或收藏主题',
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入项目描述';
                      }
                      return null;
                    },
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 24),
                    Builder(
                      builder: (context) {
                        final colorScheme = Theme.of(context).colorScheme;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: colorScheme.primary),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: colorScheme.onPrimaryContainer),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '项目统计',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '当前包含 ${widget.project!.cards.length} 张卡片',
                                      style: TextStyle(color: colorScheme.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final projectViewModel = context.read<ProjectViewModel>();

    final project = TCGProject(
      id: isEditing ? widget.project!.id : null,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      cards: isEditing ? widget.project!.cards : [],
    );

    bool success;
    if (isEditing) {
      success = await projectViewModel.updateProject(project);
    } else {
      success = await projectViewModel.addProject(project);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? '项目更新成功' : '项目创建成功')),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? '更新失败，请重试' : '创建失败，请重试')),
      );
    }
  }
}
