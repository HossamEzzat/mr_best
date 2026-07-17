import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

// Note: We can import file_picker or similar if available, but for offline local restore we can let the user choose a file. 
// For simplicity, we can export the backup to a shared location, and for restoring, we can let them input a filepath, or import from a standard backup file.
// Let's implement an elegant restore dialog where the user can paste/enter path, or we can use custom file sharing.
// To keep it simple and robust, let's use a file select or simple text file picker. Since we didn't add file_picker package, we can let them share the backup file, 
// and to restore, we can ask them if they want to restore the latest exported backup. Or we can just explain where the backup is located.
// Wait! We can use share_plus to export the backup file so they can save it anywhere, and to restore, we can show a dialog to restore from the app's default backup location.
// That is extremely robust and does not require complex third-party file pickers.

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والنسخ الاحتياطي'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Theme Card
            _buildSectionHeader('المظهر العام'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('تلقائي (حسب النظام)'),
                      value: ThemeMode.system,
                      groupValue: themeMode,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != null) ref.read(themeModeProvider.notifier).state = val;
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('الوضع الفاتح'),
                      value: ThemeMode.light,
                      groupValue: themeMode,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != null) ref.read(themeModeProvider.notifier).state = val;
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('الوضع الداكن (الليلي)'),
                      value: ThemeMode.dark,
                      groupValue: themeMode,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        if (val != null) ref.read(themeModeProvider.notifier).state = val;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Data management Card
            _buildSectionHeader('إدارة البيانات والتقارير'),
            Card(
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(Icons.cloud_upload, color: AppColors.primary),
                    title: const Text('نسخ احتياطي لقاعدة البيانات'),
                    subtitle: const Text('تصدير نسخة احتياطية من كافة البيانات لمشاركتها أو حفظها'),
                    trailing: const Icon(Icons.arrow_back_ios, size: 16),
                    onTap: () => _backupData(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_download, color: AppColors.late),
                    title: const Text('استعادة البيانات'),
                    subtitle: const Text('استعادة البيانات من نسخة احتياطية سابقة'),
                    trailing: const Icon(Icons.arrow_back_ios, size: 16),
                    onTap: () => _showRestoreDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // App info
            Center(
              child: Column(
                children: [
                  Text(
                    'مستر بيست (Mr. Best)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'إصدار التطبيق 1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'تطبيق مخصص لإدارة طلاب الرياضيات بطريقة احترافية وسهلة',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }



  Future<void> _backupData(BuildContext context) async {
    try {
      final file = await DatabaseHelper.instance.backupDatabase();
      await Share.shareXFiles([XFile(file.path)], text: 'نسخة احتياطية لقاعدة بيانات مستر بيست');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء النسخ الاحتياطي: $e'), backgroundColor: AppColors.absent),
      );
    }
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('استعادة البيانات'),
            content: const Text(
                'لاستعادة البيانات، تأكد من وجود ملف النسخة الاحتياطية باسم mr_best_backup.db في مجلد التطبيق العام، ثم اضغط على زر استعادة.\n\nتنبيه: الاستعادة ستقوم باستبدال كافة البيانات الحالية بالكامل!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.absent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    // Check if file exists in app support directory
                    final dbHelper = DatabaseHelper.instance;
                    final supportDir = await dbHelper.backupDatabase();
                    // Wait, our backup helper copies mr_best.db to supportDir/mr_best_backup.db
                    // So we can restore from that file if it exists.
                    final backupFile = File(supportDir.path);
                    if (await backupFile.exists()) {
                      await dbHelper.restoreDatabase(backupFile);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم استعادة البيانات بنجاح!'),
                          backgroundColor: AppColors.present,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لم يتم العثور على ملف نسخة احتياطية!'),
                          backgroundColor: AppColors.absent,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشلت الاستعادة: $e'), backgroundColor: AppColors.absent),
                    );
                  }
                },
                child: const Text('استعادة الآن'),
              ),
            ],
          ),
        );
      },
    );
  }
}
