import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/radii.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/template_service.dart';
import '../../core/data/models/habit_template.dart';
import '../../widgets/app_button.dart';

class TemplateGalleryScreen extends StatelessWidget {
  const TemplateGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templateService = GetIt.I<TemplateService>();
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Templates'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<HabitTemplate>>(
        future: templateService.loadTemplates(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final templates = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.s16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.s16,
              crossAxisSpacing: AppSpacing.s16,
              childAspectRatio: 3 / 4,
            ),
            itemCount: templates.length,
            itemBuilder: (_, i) {
              final tpl = templates[i];
              return GestureDetector(
                onTap: () => Navigator.pop(ctx, tpl),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(AppRadii.r12),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(tpl.color),
                        child: Icon(
                          IconData(tpl.iconData, fontFamily: 'MaterialIcons'),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        tpl.name,
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          tpl.description,
                          style: AppTextStyles.caption,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppButton(
                        label: 'Use',
                        onPressed: () => Navigator.pop(ctx, tpl),
                        primary: true,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
