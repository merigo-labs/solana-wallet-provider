/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_text_overflow.dart';
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
    this.connectStyle,
    this.connectBuilder,
    this.connectChild,
    this.onDisconnect,
    this.onDisconnectError,
    this.disconnectStyle,
    this.disconnectBuilder,
    this.disconnectChild,
  }): assert(
    connectBuilder == null || connectChild == null,
    '[SolanaWalletButton] can define [connectBuilder] or [connectChild], but not both.'
  ), assert(
    disconnectBuilder == null || disconnectChild == null,
    '[SolanaWalletButton] can define [disconnectBuilder] or [disconnectChild], but not both.'
  );

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

  /// The button's style when the application is connected to a wallet.
  final ButtonStyle? connectStyle;

  /// Builds the button's content when the application is connected to a wallet.
  /// 
  /// If [connectBuilder] is provided [connectChild] must be null.
  final Widget Function(BuildContext context, Account account)? connectBuilder;

  /// The button's content when the application is connected to a wallet.
  /// 
  /// If [connectChild] is provided [connectBuilder] must be null.
  final Widget? connectChild;

  /// Called when the application disconnects from a wallet.
  final void Function(DeauthorizeResult result)? onDisconnect;

  /// Called when the application attempts to disconnect from a wallet and fails.
  final void Function(Object error, [StackTrace? stackTrace])? onDisconnectError;

  /// The button's style when the application is not connected to a wallet.
  final ButtonStyle? disconnectStyle;

  /// Builds the button's content when the application is not connected to a wallet.
  /// 
  /// If [disconnectBuilder] is provided [disconnectChild] must be null.
  final Widget Function(BuildContext context)? disconnectBuilder;

  /// The button's content when the application is not connected to a wallet.
  /// 
  /// If [disconnectChild] is provided [disconnectBuilder] must be null.
  final Widget? disconnectChild;

  @override
  State<SolanaWalletButton> createState() => _SolanaWalletButtonState();
}


/// Solana Wallet Button State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletButtonState extends State<SolanaWalletButton> {

  /// Creates an `onPressed` callback function for [account].
  VoidCallback _onPressed(final Account? account, final SolanaWalletProvider provider) {
    return account != null
      ? () => provider.disconnect(context)
      : () => provider.connect(context);
  }

  /// Builds the button's child widget when connected to [account].
  Widget _connectBuilder(final BuildContext context, final Account account) {
    return SolanaWalletTextOverflow(text: account.addressBase58);
  }

  /// Builds the button's child widget when disconnected.
  Widget _disconnectBuilder(final BuildContext context) {
    return const Text('Connect Wallet');
  }

  @override
  Widget build(BuildContext context) {
    final SolanaWalletProvider provider = SolanaWalletProvider.of(context);
    final Account? connectedAccount = provider.connectedAccount;
    return TextButton(
      onPressed: _onPressed(connectedAccount, provider), 
      onLongPress: widget.onLongPress,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      style: (connectedAccount != null
        ? widget.connectStyle
        : widget.disconnectStyle) ?? TextButton.styleFrom(),
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      statesController: widget.statesController,
      child: connectedAccount != null
        ? widget.connectBuilder?.call(context, connectedAccount) 
          ?? _connectBuilder(context, connectedAccount)
        : widget.disconnectBuilder?.call(context) 
          ?? _disconnectBuilder(context),
    );
  }
}