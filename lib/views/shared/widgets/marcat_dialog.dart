// lib/presentation/shared/widgets/marcat_dialog.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'marcat_button.dart';

class MarcatDialog extends StatelessWidget {
  const MarcatDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.showCancel = true,
  });

  final String title;
  final String? content;
  final Widget? contentWidget;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool showCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTextStyles.headlineSmall),
      content: contentWidget ??
          (content != null
              ? Text(content!, style: AppTextStyles.bodyMedium)
              : null),
      contentPadding: const EdgeInsets.fromLTRB(
        AppDimensions.space24,
        AppDimensions.space16,
        AppDimensions.space24,
        0,
      ),
      actionsPadding: const EdgeInsets.all(AppDimensions.space16),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        if (showCancel)
          MarcatButton(
            label: cancelLabel,
            onPressed: onCancel ?? () => Navigator.of(context).pop(false),
            variant: MarcatButtonVariant.ghost,
            fullWidth: false,
            height: AppDimensions.buttonHeightSmall,
          ),
        const SizedBox(width: AppDimensions.space8),
        MarcatButton(
          label: confirmLabel,
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          variant: isDestructive
              ? MarcatButtonVariant.danger
              : MarcatButtonVariant.primary,
          fullWidth: false,
          height: AppDimensions.buttonHeightSmall,
        ),
      ],
    );
  }
}
