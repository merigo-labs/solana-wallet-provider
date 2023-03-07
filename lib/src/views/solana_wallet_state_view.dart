/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_common/exceptions/solana_exception.dart';
import '../themes/solana_wallet_state_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../../src/models/solana_wallet_method_state.dart';
import '../../src/views/solana_wallet_content_view.dart';
import '../../src/widgets/solana_wallet_icon_painter.dart';


/// Types
/// ------------------------------------------------------------------------------------------------

typedef IconBuilder = Widget Function(BuildContext, SolanaWalletStateThemeData);


/// Solana Wallet State View
/// ------------------------------------------------------------------------------------------------

/// A [SolanaWalletContentView] with an icon header.
/// 
/// ```
/// --------
/// | icon |
/// --------
///   ....
/// ```
class SolanaWalletStateView extends StatefulWidget {
  
  /// Creates a view with an icon header.
  const SolanaWalletStateView({
    super.key,
    required this.iconBuilder,
    required this.state,
    this.title,
    this.message,
    this.body,
  });

  /// Builds the icon widget.
  final IconBuilder iconBuilder;

  /// The [iconBuilder]'s theme data state.
  final SolanaWalletMethodState state;

  /// The title describing the state.
  final Widget? title;

  /// The message describing the state.
  final Widget? message;

  /// The main content.
  final Widget? body;

  /// Creates an [image] view of size [dimension].
  static Widget imageBuilder(
    final ImageProvider<Object> image,
    final double dimension,
  ) => Image(image: image, width: dimension, height: dimension);

  /// Creates an icon view for [image].
  factory SolanaWalletStateView.image({
    required ImageProvider<Object> image,
    final Widget? title,
    final Widget? message,
    final Widget? body,
  }) => SolanaWalletStateView(
    iconBuilder: (context, theme) => imageBuilder(image, theme.iconSize),
    state: SolanaWalletMethodState.none,
    title: title,
    message: message,
    body: body,
  );

  /// Creates a [CircularProgressIndicator] view for [SolanaWalletStateTheme.none].
  static Widget noneBuilder(
    final BuildContext context, 
    final SolanaWalletStateThemeData theme,
  ) => theme.iconBuilder?.call(context, theme) ?? SizedBox.square(
    dimension: theme.iconSize,
    child: CircularProgressIndicator(
      color: theme.iconColor,
      strokeWidth: theme.iconStrokeWidth,
    ),
  );

  /// Creates a `not started` view for [SolanaWalletMethodState.none].
  factory SolanaWalletStateView.none({
    required final String title,
    required final String message,
    final Widget? body,
  }) => SolanaWalletStateView(
    iconBuilder: noneBuilder,
    state: SolanaWalletMethodState.none,
    title: Text(title),
    message: Text(message),
    body: body,
  );

  /// Creates a [CircularProgressIndicator] view for [SolanaWalletStateTheme.progress].
  static Widget progressBuilder(
    final BuildContext context, 
    final SolanaWalletStateThemeData theme,
  ) => theme.iconBuilder?.call(context, theme) ?? SizedBox.square(
    dimension: theme.iconSize,
    child: CircularProgressIndicator(
      color: theme.iconColor,
      strokeWidth: theme.iconStrokeWidth,
    ),
  );

  /// Creates a `progress` view for [SolanaWalletMethodState.progress].
  factory SolanaWalletStateView.progress({
    required final String title,
    required final String message,
    final Widget? body,
  }) => SolanaWalletStateView(
    iconBuilder: progressBuilder,
    state: SolanaWalletMethodState.progress,
    title: Text(title),
    message: Text(message),
    body: body,
  );

  /// Creates a tick (✓) icon view for [SolanaWalletStateTheme.success].
  static Widget successBuilder(
    final BuildContext context, 
    final SolanaWalletStateThemeData theme,
  ) => theme.iconBuilder?.call(context, theme) ?? CustomPaint(
    size: Size.square(theme.iconSize),
    painter: SolanaWalletTickIcon(
      color: theme.iconColor ?? Colors.green, 
      strokeWidth: theme.iconStrokeWidth,
    ),
  );

  /// Creates a `success` view for [SolanaWalletMethodState.success].
  factory SolanaWalletStateView.success({
    final String? title,
    final String? message,
    final Widget? body,
  }) => SolanaWalletStateView(
    iconBuilder: successBuilder,
    state: SolanaWalletMethodState.success,
    title: Text(title ?? 'Success'),
    message: message != null ? Text(message) : null,
    body: body,
  );

  /// Creates a bang (!) icon view for [SolanaWalletStateTheme.error].
  static Widget errorBuilder(
    final BuildContext context, 
    final SolanaWalletStateThemeData theme,
  ) => theme.iconBuilder?.call(context, theme) ?? CustomPaint(
    size: Size.square(theme.iconSize),
    painter: SolanaWalletBangIcon(
      color: theme.iconColor ?? Colors.red, 
      strokeWidth: theme.iconStrokeWidth,
    ),
  );

  /// Creates an `error` view for [SolanaWalletMethodState.error].
  /// 
  /// The message is parsed from [error]. Failure to parse [error] will display [message]
  /// or `Something has gone wrong.`.
  factory SolanaWalletStateView.error({
    required final Object? error,
    final String? title,
    final String? message,
    final Widget? body,
  }) {
    String? errorMessage; 
    if (error is SolanaException) {
      errorMessage = error.message;
    } else {
      errorMessage = error?.toString();
      final RegExp regexp = RegExp(r'^[\w:]*Exception:\s+');
      errorMessage = message?.replaceAll(regexp, '');
    }
    return  SolanaWalletStateView(
      iconBuilder: errorBuilder,
      state: SolanaWalletMethodState.error,
      title: Text(title ?? 'Error'),
      message: Text(errorMessage ?? message ?? 'Something has gone wrong.'),
      body: body,
    );
  }

  @override
  State<SolanaWalletStateView> createState() => _SolanaWalletStateViewState();
}


/// Solana Wallet Icon View State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletStateViewState extends State<SolanaWalletStateView> {

  /// Returns the theme data for [SolanaWalletStateView.state].
  SolanaWalletStateThemeData? _resolve(final SolanaWalletStateTheme? theme) {
    switch (widget.state) {
      case SolanaWalletMethodState.none:
        return theme?.none;
      case SolanaWalletMethodState.progress:
        return theme?.progress;
      case SolanaWalletMethodState.success:
        return theme?.success;
      case SolanaWalletMethodState.error:
        return theme?.error;
    }
  }

  @override
  Widget build(final BuildContext context) {
    final SolanaWalletThemeExtension? themeExt = SolanaWalletThemeExtension.of(context);
    final SolanaWalletStateThemeData theme = _resolve(themeExt?.stateTheme) 
      ?? const SolanaWalletStateThemeData();
    return SolanaWalletContentView(
      header: widget.iconBuilder(context, theme),
      title: widget.title,
      message: widget.message,
      body: widget.body,
    );
  }
}