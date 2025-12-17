import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/models/ptcg_card.dart';
import 'package:tpcg_collection_record/models/ptcg_project.dart';
import 'package:tpcg_collection_record/viewmodels/card_viewmodel.dart';
import 'package:tpcg_collection_record/viewmodels/project_viewmodel.dart';
import 'package:tpcg_collection_record/services/image_service.dart';
import 'package:tpcg_collection_record/utils/grade_utils.dart';

class EditCardPage extends StatefulWidget {
  final PTCGCard? card;
  final int? projectId;

  const EditCardPage({super.key, this.card, this.projectId});

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pokedexNumberController = TextEditingController();
  final _issueNumberController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _acquiredDateController = TextEditingController();
  final _acquiredPriceController = TextEditingController();
  final _currentPriceController = TextEditingController();

  String _selectedGrade = GradeUtils.grades.first;
  String? _frontImagePath;
  String? _backImagePath;
  String? _gradeImagePath;

  List<PTCGProject> _availableProjects = [];
  int? _selectedProjectId;
  bool _isLoadingProjects = true;

  bool get isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _initializeWithCard(widget.card!);
    } else if (widget.projectId != null) {
      _selectedProjectId = widget.projectId;
    }

    // 推迟到下一帧执行，避免在构建过程中调用setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects();
    });
  }

  Future<void> _loadProjects() async {
    final projectViewModel = context.read<ProjectViewModel>();
    await projectViewModel.loadAllProjects();
    if (mounted) {
      setState(() {
        _availableProjects = projectViewModel.projects;
        _isLoadingProjects = false;

        // 如果是新建卡片且没有指定项目，选择第一个项目
        if (!isEditing &&
            _selectedProjectId == null &&
            _availableProjects.isNotEmpty) {
          _selectedProjectId = _availableProjects.first.id;
        }
      });
    }
  }

  void _initializeWithCard(PTCGCard card) {
    _nameController.text = card.name;
    _pokedexNumberController.text = card.pokedexNumber.toString();
    _issueNumberController.text = card.issueNumber;
    _issueDateController.text = card.issueDate;
    _acquiredDateController.text = card.acquiredDate;
    _acquiredPriceController.text = card.acquiredPrice.toString();
    _currentPriceController.text = card.currentPrice.toString();
    _selectedGrade = card.grade;
    _selectedProjectId = card.projectId;
    _frontImagePath = card.frontImage;
    _backImagePath = card.backImage;
    _gradeImagePath = card.gradeImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pokedexNumberController.dispose();
    _issueNumberController.dispose();
    _issueDateController.dispose();
    _acquiredDateController.dispose();
    _acquiredPriceController.dispose();
    _currentPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑卡片' : '添加卡片'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saveCard,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本信息
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // 价格信息
              _buildPriceSection(),
              const SizedBox(height: 24),

              // 图片上传
              _buildImageSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '卡片名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入卡片名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pokedexNumberController,
              decoration: const InputDecoration(
                labelText: '图鉴编号',
                border: OutlineInputBorder(),
                hintText: '例如: 25 (皮卡丘)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入宝可梦图鉴编号';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return '请输入有效的图鉴编号';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _issueNumberController,
              decoration: const InputDecoration(
                labelText: '发行编号',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入发行编号';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _issueDateController,
              decoration: const InputDecoration(
                labelText: '发行时间',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _issueDateController),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请选择发行时间';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _isLoadingProjects
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
                    initialValue: _selectedProjectId,
                    decoration: const InputDecoration(
                      labelText: '所属项目',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableProjects.map((PTCGProject project) {
                      return DropdownMenuItem<int>(
                        value: project.id,
                        child: Text(project.name),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedProjectId = newValue;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return '请选择所属项目';
                      }
                      return null;
                    },
                  ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedGrade,
              decoration: const InputDecoration(
                labelText: '评级',
                border: OutlineInputBorder(),
              ),
              items: GradeUtils.grades.map((String grade) {
                return DropdownMenuItem<String>(
                  value: grade,
                  child: Text(grade),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGrade = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _acquiredDateController,
              decoration: const InputDecoration(
                labelText: '入手时间',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _acquiredDateController),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请选择入手时间';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '价格信息',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _acquiredPriceController,
              decoration: const InputDecoration(
                labelText: '入手价格',
                border: OutlineInputBorder(),
                prefixText: '¥ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入入手价格';
                }
                if (double.tryParse(value) == null) {
                  return '请输入有效的价格';
                }
                return null;
              },
              onChanged: (value) {
                // 如果是添加新卡片，自动设置当前成交价为入手价格
                if (!isEditing && _currentPriceController.text.isEmpty) {
                  _currentPriceController.text = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentPriceController,
              decoration: const InputDecoration(
                labelText: '当前成交价',
                border: OutlineInputBorder(),
                prefixText: '¥ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入当前成交价';
                }
                if (double.tryParse(value) == null) {
                  return '请输入有效的价格';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '卡片图片',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildImageUpload('正面图片', _frontImagePath, (path) {
              setState(() {
                _frontImagePath = path;
              });
            }),
            const SizedBox(height: 16),
            _buildImageUpload('背面图片', _backImagePath, (path) {
              setState(() {
                _backImagePath = path;
              });
            }),
            const SizedBox(height: 16),
            _buildImageUpload('评级图片', _gradeImagePath, (path) {
              setState(() {
                _gradeImagePath = path;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload(
      String title, String? imagePath, Function(String?) onImageSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: imagePath != null && imagePath.isNotEmpty
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imagePath),
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image,
                                      size: 32, color: Colors.grey),
                                  SizedBox(height: 4),
                                  Text('图片加载失败',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                          onPressed: () {
                            onImageSelected(null);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: () async {
                    final path = await ImageService.pickAndSaveImage();
                    if (path != null) {
                      onImageSelected(path);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 32, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('点击选择图片', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _selectDate(BuildContext context, TextEditingController controller) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2000, 1, 1),
      maxTime: DateTime.now(),
      onConfirm: (date) {
        controller.text =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      },
      currentTime: DateTime.now(),
      locale: LocaleType.zh,
    );
  }

  void _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择所属项目')),
      );
      return;
    }

    final cardViewModel = context.read<CardViewModel>();

    final card = PTCGCard(
      id: isEditing ? widget.card!.id : null,
      projectId: _selectedProjectId!,
      pokedexNumber: int.parse(_pokedexNumberController.text),
      name: _nameController.text,
      issueNumber: _issueNumberController.text,
      issueDate: _issueDateController.text,
      grade: _selectedGrade,
      acquiredDate: _acquiredDateController.text,
      acquiredPrice: double.parse(_acquiredPriceController.text),
      currentPrice: double.parse(_currentPriceController.text),
      frontImage: _frontImagePath,
      backImage: _backImagePath,
      gradeImage: _gradeImagePath,
    );

    bool success;
    if (isEditing) {
      success = await cardViewModel.updateCard(card);
    } else {
      success = await cardViewModel.addCard(card);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? '卡片更新成功' : '卡片添加成功')),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? '更新失败，请重试' : '添加失败，请重试')),
      );
    }
  }
}
