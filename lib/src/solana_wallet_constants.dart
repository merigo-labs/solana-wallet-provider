/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'layouts/solana_wallet_layout_grid.dart';


/// Constants
/// ------------------------------------------------------------------------------------------------

/// The package name.
const String packageName = 'solana_wallet_provider';

/// The default body text size.
const double fontSize = 16.0;

/// Returns the default card colour.
Color cardColourOf(final ThemeData theme) => theme.cardTheme.color ?? theme.cardColor;

/// Returns the default text colour.
Color? textColourOf(final ThemeData theme) => theme.textTheme.bodyText1?.color;

/// Returns the default subtext colour.
Color? subtextColourOf(final ThemeData theme) => theme.textTheme.bodyText2?.color;

/// Returns the default divider colour.
Color dividerColourOf(final ThemeData theme) => theme.dividerColor;

/// Returns the default primary colour.
Color? primaryColourOf(final ThemeData theme) => theme.primaryColor;

/// Returns the default list tile padding.
EdgeInsets defaultListTilePadding() => const EdgeInsets.symmetric(
  vertical: SolanaWalletLayoutGrid.x2,
  horizontal: SolanaWalletLayoutGrid.x3,
);