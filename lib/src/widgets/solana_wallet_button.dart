/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_text_overflow.dart';
import '../layouts/solana_wallet_grid.dart';
import '../../solana_wallet_provider.dart';


/// Solana Wallet Button
/// ------------------------------------------------------------------------------------------------

/// A [TextButton] that toggles authorization between the application and a wallet.
class SolanaWalletButton extends StatefulWidget {
  
  /// Creates a button that toggles authorization between the application and a wallet.
  const SolanaWalletButton({
    super.key,
    this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    this.hostAuthority,
    this.onConnect,
    this.onConnectError,
    this.onConnectDismissState,
    this.connectedStyle,
    this.connectedBuilder,
    this.onDisconnect,
    this.onDisconnectError,
    this.onDisconnectDismissState,
    this.disconnectedStyle,
    this.disconnectedBuilder,
  });

  /// Called when the button is tapped or otherwise activated.
  ///
  /// If this callback and [onLongPress] are null, then the button will be disabled.
  final VoidCallback? onPressed;

  /// Called when the button is long-pressed.
  ///
  /// If this callback and [onPressed] are null, then the button will be disabled.
  final VoidCallback? onLongPress;

  /// Called when a pointer enters or exits the button response area.
  ///
  /// The value passed to the callback is true if a pointer has entered this part of the material 
  /// and false if a pointer has exited this part of the material.
  final ValueChanged<bool>? onHover;

  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses focus.
  final ValueChanged<bool>? onFocusChange;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none], and must not be null.
  final Clip clipBehavior;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.material.inkwell.statesController}
  final MaterialStatesController? statesController;

  /// The remote connection server's uri.
  final String? hostAuthority;

  /// Called when the application connects to a wallet.
  final void Function(AuthorizeResult result)? onConnect;

  /// Called when the application attempts to connect to a wallet and fails.
  final void Function(Object error, [StackTrace? stackTrace])? onConnectError;

  /// The auto dismiss state when connecting.
  final DismissState? onConnectDismissState;

  /// The button's style when the application is connected to a wallet.
  final ButtonStyle? connectedStyle;

  /// Builds the button's content when the application is connected to a wallet.
  final Widget Function(BuildContext context, Account account)? connectedBuilder;

  /// Called when the application disconnects from a wallet.
  final void Function(DeauthorizeResult result)? onDisconnect;

  /// Called when the application attempts to disconnect from a wallet and fails.
  final void Function(Object error, [StackTrace? stackTrace])? onDisconnectError;

  /// The auto dismiss state when disconnecting.
  final DismissState? onDisconnectDismissState;

  /// The button's style when the application is not connected to a wallet.
  final ButtonStyle? disconnectedStyle;

  /// Builds the button's content when the application is not connected to a wallet.
  final Widget Function(BuildContext context)? disconnectedBuilder;

  /// Default button style.
  static ButtonStyle defaultStyleOf(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return TextButton.styleFrom(
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      elevation: 0,
      textStyle: theme.textTheme.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: SolanaWalletGrid.x3),
      minimumSize: const Size.square(SolanaWalletGrid.x6),
      maximumSize: Size.infinite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(SolanaWalletGrid.x2)),
      ),
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  }

  @override
  State<SolanaWalletButton> createState() => _SolanaWalletButtonState();
}


/// Solana Wallet Button State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletButtonState extends State<SolanaWalletButton> {

  /// Creates an `onPressed` callback function for [account].
  VoidCallback _onPressed(final Account? account, final SolanaWalletProvider provider) {
    return account != null
      ? () => provider.disconnect(
          context,
          dismissState: widget.onDisconnectDismissState,
        )
      : () => provider.connect(
          context,
          hostAuthority: widget.hostAuthority,
          dismissState: widget.onConnectDismissState,
        );
  }

  /// Builds the button's child widget when the application is connected to [account].
  Widget _connectBuilder(final BuildContext context, final Account account) {
    return SolanaWalletTextOverflow(text: account.toBase58());
  }

  /// Builds the button's child widget when disconnected.
  Widget _disconnectBuilder(final BuildContext context) {
    return const Text('Connect Wallet');
  }

  @override
  Widget build(final BuildContext context) {
    final SolanaWalletProvider provider = SolanaWalletProvider.of(context);
    final Account? connectedAccount = provider.connectedAccount;
    return TextButton(
      onPressed: _onPressed(connectedAccount, provider), 
      onLongPress: widget.onLongPress,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      style: (connectedAccount != null ? widget.connectedStyle : widget.disconnectedStyle) 
        ?? TextButton.styleFrom(textStyle: const TextStyle(inherit: true)),
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      statesController: widget.statesController,
      child: connectedAccount != null
        ? widget.connectedBuilder?.call(context, connectedAccount) 
          ?? _connectBuilder(context, connectedAccount)
        : widget.disconnectedBuilder?.call(context) 
          ?? _disconnectBuilder(context),
    );
  }
}