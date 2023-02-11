/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_list_view.dart';
import '../layouts/solana_wallet_grid.dart';
import '../../solana_wallet_provider.dart';
import '../../src/widgets/solana_wallet_icon_painter.dart';


/// Types
/// ------------------------------------------------------------------------------------------------

typedef IconBuilder = Widget Function(BuildContext, SolanaWalletMethodViewTheme? theme);


/// Solana Wallet Method View
/// ------------------------------------------------------------------------------------------------

/// A [SolanaWalletListView] that displays an icon followed by a descriptive message.
/// 
/// ```
/// --------
/// | icon |
/// --------
/// message!
/// ```
class SolanaWalletMethodView<T> extends StatefulWidget {
  
  /// Creates a view for a [SolanaWalletMethodState].
  const SolanaWalletMethodView({
    super.key,
    required this.iconBuilder,
    this.iconSize = SolanaWalletGrid.x1 * 8,
    this.message,
  });

  /// Build's the icon widget.
  final IconBuilder iconBuilder;

  /// The icon widget's width and height.
  final double iconSize;

  /// The message describing the state.
  final String? message;

  /// Creates a [Widget] from [theme.iconBuilder] using [builder] as a default.
  static Widget _iconBuilder(
    final BuildContext context, {
    required SolanaWalletMethodViewThemeData? theme,
    required final Widget Function(BuildContext, SolanaWalletMethodViewThemeData) builder,
  }) {
    theme ??= const SolanaWalletMethodViewThemeData();
    return SizedBox.square(
      dimension: theme.iconSize,
      child: theme.iconBuilder?.call(context, theme) 
       ?? builder(context, theme),
    );
  }

  /// Creates a [CircularProgressIndicator] for [theme.none].
  static Widget noneBuilder(
    final BuildContext context, 
    final SolanaWalletMethodViewTheme? theme,
  ) => _iconBuilder(
    context,
    theme: theme?.none,
    builder: (_, theme) => CircularProgressIndicator(
      color: theme.iconColor,
      strokeWidth: theme.iconStrokeWidth,
    ),
  );

  /// Creates a `not started` view for [SolanaWalletMethodState.none].
  factory SolanaWalletMethodView.none([
    final String? message,
  ]) => SolanaWalletMethodView(
    iconBuilder: noneBuilder,
    message: message,
  );

  /// Creates a [CircularProgressIndicator] for [theme.progress].
  static Widget progressBuilder(
    final BuildContext context, 
    final SolanaWalletMethodViewTheme? theme,
  ) => _iconBuilder(
    context,
    theme: theme?.progress,
    builder: (_, theme) => CircularProgressIndicator(
      color: theme.iconColor,
      strokeWidth: theme.iconStrokeWidth,
    ),
  );

  /// Creates a `progress` view for [SolanaWalletMethodState.progress].
  factory SolanaWalletMethodView.progress([
    final String? message,
  ]) => SolanaWalletMethodView(
    iconBuilder: progressBuilder,
    message: message,
  );

  /// Creates a tick (✓) icon for [theme.success].
  static Widget successIconBuilder(
    final BuildContext context, 
    final SolanaWalletMethodViewTheme? theme,
  ) => _iconBuilder(
    context,
    theme: theme?.success,
    builder: (_, theme) => CustomPaint(
      painter: SolanaWalletTickIcon(
        color: theme.iconColor ?? Colors.green, 
        strokeWidth: theme.iconStrokeWidth,
      ),
    ),
  );

  /// Creates a `success` view for [SolanaWalletMethodState.success].
  factory SolanaWalletMethodView.success([
    final String? message,
  ]) => SolanaWalletMethodView(
    iconBuilder: successIconBuilder,
    message: message,
  );

  /// Creates a bang (!) icon for [theme.error].
  static Widget errorIconBuilder(
    final BuildContext context, 
    final SolanaWalletMethodViewTheme? theme,
  ) => _iconBuilder(
    context,
    theme: theme?.error,
    builder: (_, theme) => CustomPaint(
      painter: SolanaWalletBangIcon(
        color: theme.iconColor ?? Colors.red, 
        strokeWidth: theme.iconStrokeWidth,
      ),
    ),
  );

  /// Creates an `error` view for [SolanaWalletMethodState.error].
  /// 
  /// The [message] is parsed from [error]. Failure to parse [error] will display [defaultMessage]
  /// or `Something has gone wrong.`.
  factory SolanaWalletMethodView.error([
    final Object? error,
    final String? defaultMessage,
  ]) {
    String? message; 
    if (error is SolanaException) {
      message = error.message;
    } else {
      message = error?.toString();
      final RegExp regexp = RegExp(r'^\w*Exception: ');
      message = message?.replaceAll(regexp, '');
    }
    return  SolanaWalletMethodView(
      iconBuilder: errorIconBuilder,
      message: message ?? defaultMessage ?? 'Something has gone wrong.',
    );
  }

  @override
  State<SolanaWalletMethodView<T>> createState() => _SolanaWalletMethodViewState<T>();
}


/// Solana Wallet Method View State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletMethodViewState<T> extends State<SolanaWalletMethodView<T>> {

  @override
  Widget build(BuildContext context) {
    final String? message = widget.message;
    final SolanaWalletThemeExtension? themeExt = SolanaWalletThemeExtension.of(context);
    return SolanaWalletListView(
      children: [
        SizedBox.square(
          dimension: widget.iconSize,
          child: widget.iconBuilder(
            context, 
            themeExt?.stateTheme,
          ),
        ),
        if (message != null)
          Text(message),
      ],
    );
  }
}