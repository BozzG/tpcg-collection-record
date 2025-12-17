import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpcg_collection_record/viewmodels/project_viewmodel.dart';
import 'package:tpcg_collection_record/views/project_detail_page.dart';
import 'package:tpcg_collection_record/views/edit_project_page.dart';
import 'package:tpcg_collection_record/views/add_project_page.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().loadAllProjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目列表'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ProjectViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // 搜索栏
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索项目名称...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: viewModel.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    viewModel.searchProjects(value);
                  },
                ),
              ),
              
              // 项目列表
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '加载项目时出错',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    viewModel.errorMessage!,
                                    style: TextStyle(color: Colors.red[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          viewModel.loadAllProjects();
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('重试'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          // 显示详细错误信息
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('错误详情'),
                                              content: SingleChildScrollView(
                                                child: Text(viewModel.errorMessage!),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('关闭'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.info_outline),
                                        label: const Text('详情'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : viewModel.projects.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      viewModel.searchQuery.isEmpty
                                          ? '还没有创建任何项目'
                                          : '没有找到匹配的项目',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: viewModel.projects.length,
                                itemBuilder: (context, index) {
                                  final project = viewModel.projects[index];
                                  
                                  // 安全地计算总价值
                                  double totalValue = 0.0;
                                  try {
                                    totalValue = viewModel.getProjectTotalValue(project);
                                  } catch (e) {
                                    // 如果计算失败，使用默认值
                                    totalValue = 0.0;
                                  }
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green[100],
                                        child: Icon(
                                          Icons.folder,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                      title: Text(
                                        project.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            project.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text('卡片数: ${project.cards.length}'),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '¥${totalValue.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) async {
                                              if (value == 'edit') {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EditProjectPage(project: project),
                                                  ),
                                                );
                                                if (result == true && context.mounted) {
                                                  viewModel.loadAllProjects();
                                                }
                                              } else if (value == 'delete') {
                                                _showDeleteDialog(context, project.id!, viewModel);
                                              }
                                            },
                                            itemBuilder: (BuildContext context) => [
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 20),
                                                    SizedBox(width: 8),
                                                    Text('编辑'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('删除', style: TextStyle(color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            child: const Icon(Icons.more_vert),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        try {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProjectDetailPage(projectId: project.id!),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('打开项目详情失败: ${e.toString()}')),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProjectPage()),
          );
          if (result == true && context.mounted) {
            context.read<ProjectViewModel>().loadAllProjects();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showDeleteDialog(BuildContext context, int projectId, ProjectViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这个项目吗？项目中的所有卡片也会被删除，此操作无法撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await viewModel.deleteProject(projectId);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('项目删除成功')),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除失败，请重试')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}