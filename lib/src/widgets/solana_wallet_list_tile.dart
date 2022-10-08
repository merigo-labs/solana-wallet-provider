/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_spacer.dart';
import '../layouts/solana_wallet_layout_grid.dart';
import '../solana_wallet_constants.dart';
import '../solana_wallet_icons.dart';
import '../themes/solana_wallet_list_tile_theme.dart';


/// Solana Wallet List Tile
/// ------------------------------------------------------------------------------------------------

class SolanaWalletListTile extends StatelessWidget {
  
  /// Creates a list tile.
  const SolanaWalletListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.theme,
    this.onTap,
  });

  /// The leading widget.
  final Widget? leading;

  /// The title.
  final Text title;
  
  /// The subtitle.
  final Text? subtitle;

  /// The trailing widget.
  final Widget? trailing;

  /// The style.
  final SolanaWalletListTileTheme? theme;

  /// Called when the list tile is pressed.
  final VoidCallback? onTap;

  /// Returns the default title style.
  TextStyle defaultTitleTextStyle(final ThemeData theme)
    => TextStyle(
      fontSize: fontSize, 
      fontWeight: FontWeight.w600,
      color: textColourOf(theme), 
      overflow: TextOverflow.ellipsis,
    );

  /// Returns the default subtitle style.
  TextStyle defaultSubtitleTextStyle(final ThemeData theme)
    => TextStyle(
      fontSize: fontSize - 2, 
      color: subtextColourOf(theme),
      overflow: TextOverflow.ellipsis,
    );
  
  @override
  Widget build(BuildContext context) {
    
    final ThemeData themeData = Theme.of(context);

    final EdgeInsets padding = theme?.padding ?? defaultListTilePadding();

    Widget child = DefaultTextStyle(
      style: theme?.titleTextStyle ?? defaultTitleTextStyle(themeData), 
      child: title,
    );

    if (subtitle != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          DefaultTextStyle(
            style: theme?.subtitleTextStyle ?? defaultSubtitleTextStyle(themeData), 
            child: subtitle!,
          ),
        ],
      );
    }

    if (leading != null || trailing != null) {
      final Widget spacer = SolanaWalletSpacer.square(theme?.spacing);
      child = Row(
        children: [
          if (leading != null)
            ...[leading!, spacer],
          Expanded(child: child),
          if (trailing != null)
            ...[spacer, trailing!],
        ],
      );
    }

    return Material(
      type: MaterialType.button,
      color: theme?.color ?? Colors.transparent,
      clipBehavior: Clip.hardEdge,
      shape: theme?.shape ?? RoundedRectangleBorder(
        side: BorderSide(
          color: dividerColourOf(themeData),
          width: SolanaWalletIcons.strokeWidth,
        ), 
        borderRadius: const BorderRadius.all(
          Radius.circular(SolanaWalletLayoutGrid.x2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}