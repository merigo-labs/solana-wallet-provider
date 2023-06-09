/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../layouts/solana_wallet_grid.dart';
import '../themes/solana_wallet_modal_view_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../widgets/solana_wallet_default_text_style.dart';
import 'solana_wallet_column_view.dart';


/// Solana Wallet Modal View
/// ------------------------------------------------------------------------------------------------

/// The layout of a modal view.
@immutable
class SolanaWalletModalView extends StatelessWidget {

  /// Creates a modal view.
  const SolanaWalletModalView({
    super.key,
    this.banner,
    required this.title,
    this.message,
    this.body,
    this.footer,
  });

  /// The header section of a modal view.
  final Widget? banner;

  /// The view's title.
  final Widget title;

  /// The view's description.
  final Widget? message;

  /// The view's main content.
  final Widget? body;

  /// The view's footer.
  final Widget? footer;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SolanaWalletModalViewTheme? viewTheme = SolanaWalletThemeExtension.of(context)?.viewTheme;
    return SolanaWalletColumnView<Widget>(
      spacing: SolanaWalletGrid.x3,
      children: [
        if (banner != null)
          banner!,  
        SolanaWalletDefaultTextStyle(
          style: viewTheme?.titleTextStyle ?? theme.textTheme.titleLarge, 
          child: message != null
            ? SolanaWalletColumnView<Widget>(
                spacing: SolanaWalletGrid.x1,
                children: [
                  title,
                  SolanaWalletDefaultTextStyle(
                    style: viewTheme?.bodyTextStyle ?? theme.textTheme.bodyMedium, 
                    child: message!,
                  ),
                ],
              )
            : title,
        ),
        if (body != null)
          body!,
        if (footer != null)
          footer!,
      ],
    );
  }
}