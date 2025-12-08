import 'dart:async';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'screen_utils.dart';
import 'utils.dart';

const dialogMaxWidth = 350.0;

Future<void> showConfirmDialog({
  required BuildContext context,
  String? title,
  required String message,
  String? yesMsg,
  String? noMsg,
  required VoidCallback onConfirm,
  VoidCallback? onDismiss,
  bool autoDismiss = true,
  bool barrierDismissable = true,
}) {
  final styles = context.textStyles;

  return SmartDialog.show(
    clickMaskDismiss: barrierDismissable,
    builder: (_) {
      return AlertDialog(
        title: Text(title ?? "Are you sure?", style: styles.titleLarge),
        content: Text(message, style: styles.bodyLarge),
        actions: [
          TextButton(
            onPressed: () {
              SmartDialog.dismiss();
              onDismiss?.call();
            },
            child: Text(noMsg ?? "No"),
          ),
          TextButton(
            onPressed: () async {
              if (autoDismiss) {
                await SmartDialog.dismiss();
              }

              onConfirm();
            },
            child: Text(yesMsg ?? "Yes"),
          ),
        ],
      );
    },
  );
}

Future<void> showInfoDialog({
  required BuildContext context,
  String? title,
  required String message,
  String? closeMsg,
}) {
  final styles = context.textStyles;

  return SmartDialog.show(
    builder: (_) {
      return CustomDialog(
        title: Text(title ?? "Info", style: styles.titleLarge),
        content: Text(message, style: styles.bodyLarge),
        actions: [
          TextButton(
            onPressed: SmartDialog.dismiss,
            child: Text(closeMsg ?? "Close"),
          ),
        ],
      );
    },
  );
}

void showSuccessToast(String msg) {
  SmartDialog.showToast(
    '', // The message is provided in the builder, so this can be empty.
    alignment: Alignment.center,
    displayTime: const Duration(seconds: 3),
    builder: (context) => Container(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 350),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(msg, style: const TextStyle(color: Colors.white)),
    ),
  );
}

void showErrorToast(String msg) {
  SmartDialog.showToast(
    '', // The message is provided in the builder, so this can be empty.
    alignment: Alignment.center,
    displayTime: const Duration(seconds: 3),
    builder: (context) {
      final theme = Theme.of(context);

      return Container(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 350),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(msg, style: TextStyle(color: theme.colorScheme.onError)),
      );
    },
  );
}

class StringInputDialog extends StatefulWidget {
  static const defaultMaxLength = 80;

  final String? initialValue;
  final String title;
  final String label;
  final String submitLabel;
  final ValueChanged<String> onInput;
  final RegExp? allowedCharacters;
  final TextCapitalization textCapitalization;
  final int maxLength;

  const StringInputDialog({
    super.key,
    this.initialValue,
    required this.title,
    required this.label,
    required this.submitLabel,
    required this.onInput,
    this.allowedCharacters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength = defaultMaxLength,
  });

  @override
  State<StringInputDialog> createState() => _StringInputDialogState();

  static void show({
    required String title,
    required String label,
    String submitLabel = "Submit",
    String? initialValue,
    RegExp? allowedCharacters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    required ValueChanged<String> onInput,
    int maxLength = StringInputDialog.defaultMaxLength,
  }) {
    SmartDialog.show(
      builder: (_) {
        return StringInputDialog(
          initialValue: initialValue,
          title: title,
          label: label,
          submitLabel: submitLabel,
          onInput: onInput,
          allowedCharacters: allowedCharacters,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
        );
      },
    );
  }
}

class _StringInputDialogState extends State<StringInputDialog> {
  final ctrl = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() {
      focusNode.requestFocus();

      if (widget.initialValue != null) {
        ctrl.text = widget.initialValue!;
      }

      ctrl.selectAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: dialogMaxWidth),
        child: TextFormField(
          controller: ctrl,
          autofocus: true,
          focusNode: focusNode,
          keyboardType: TextInputType.name,
          enableSuggestions: false,
          inputFormatters: [
            if (widget.allowedCharacters != null) FilteringTextInputFormatter.allow(widget.allowedCharacters!),
          ],
          autocorrect: false,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            labelText: widget.label,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: widget.textCapitalization,
          onChanged: (value) {
            setState(() {});
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        const TextButton(
          onPressed: SmartDialog.dismiss,
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: ctrl.text.trim().isNotEmpty ? _submit : null,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }

  void _submit() {
    final input = ctrl.text.trim();

    if (input.isNotEmpty) {
      widget.onInput(input);
    }

    SmartDialog.dismiss();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }
}

class CustomDialog extends StatelessWidget {
  static const maxWidth = 350.0;

  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final Color borderColor;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.borderColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: paddingAllXXL,
      constraints: const BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: Colors.black,
        // image: const DecorationImage(
        //   image: AssetImage('assets/images/boards.jpg'),
        //   fit: BoxFit.cover,
        // ),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          boxXXL,
          content,
          boxXXL,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
          ),
        ],
      ),
    );
  }
}
