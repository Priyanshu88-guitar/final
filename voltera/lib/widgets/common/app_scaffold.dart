import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import 'loading_indicator.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool isLoading;
  final String? loadingMessage;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final Widget? bottomNavigationBar;

  const AppScaffold({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.isLoading = false,
    this.loadingMessage,
    this.scrollable = true,
    this.padding,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (scrollable) {
      content = SingleChildScrollView(
        padding: padding ?? const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
        child: content,
      );
    } else if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            content,
            if (isLoading)
              Container(
                color: Colors.black26,
                child: LoadingIndicator(message: loadingMessage),
              ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
