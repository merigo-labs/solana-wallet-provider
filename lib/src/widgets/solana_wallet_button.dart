/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
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
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    this.hostAuthority,
    this.onConnect,
    this.onConnectError,
    this.onDisconnect,
    this.onDisconnectError,
    this.builder,
    this.child,
  }): assert(
    builder == null || child == null,
    '[SolanaWalletButton] can define [builder] or [child], but not both.'
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

  /// Customizes this button's appearance.
  final ButtonStyle? style;

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

  /// Called when the application disconnects from a wallet.
  final void Function(DeauthorizeResult result)? onDisconnect;

  /// Called when the application attempts to disconnect from a wallet and fails.
  final void Function(Object error, [StackTrace? stackTrace])? onDisconnectError;

  /// Builds the button's child.
  /// 
  /// If [builder] is provided [child] must be null.
  final Widget Function(Account? account)? builder;

  /// The button's content.
  /// 
  /// If [child] is provided [builder] must be null.
  final Widget? child;

  @override
  State<SolanaWalletButton> createState() => _SolanaWalletButtonState();
}


/// Solana Wallet Button State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletButtonState extends State<SolanaWalletButton> {

  /// Creates a callback function that resolves [completer] with the provided value.
  void Function(T?) _onCompleteHandler<T>(
    final Completer<T?> completer,
    final void Function(T value)? onComplete,
  ) {
    return (final T? value) {
      if (!completer.isCompleted) {
        completer.complete(value);
        if (value != null) {
          onComplete?.call(value);
        }
      }
    };
  }

  /// Creates a callback function that resolves [completer] with the provided error.
  void Function(Object, [StackTrace?]) _onCompleteErrorHandler<T>(
    final Completer<T> completer,
    final void Function(Object error, [StackTrace? stackTrace])? onCompleteError,
  ) {
    return (final Object error, [final StackTrace? stackTrace]) {
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
        onCompleteError?.call(error, stackTrace);
      }
    };
  }

  /// Connects the application to a Solana wallet.
  Future <AuthorizeResult> _onConnect(final SolanaWalletProvider provider) {
    return provider.open(
      context: context, 
      builder: (
        final BuildContext context, 
        final Completer<AuthorizeResult> completer,
      ) => SolanaWalletConnectCard(
        apps: [
          SolanaWalletAppInfo.phantom,
          SolanaWalletAppInfo.solflare,
        ], 
        adapter: provider.adapter,
        onComplete: _onCompleteHandler(completer, widget.onConnect),
        onCompleteError: _onCompleteErrorHandler(completer, widget.onConnectError),
        hostAuthority: widget.hostAuthority,
      ),
    );
  }
  
  /// Disconnects the application from a Solana wallet.
  Future<DeauthorizeResult> _onDisconnect(final SolanaWalletProvider provider) {
    return provider.open(
      context: context, 
      builder: (
        final BuildContext context, 
        final Completer<DeauthorizeResult> completer,
      ) => SolanaWalletDisconnectCard(
        accounts: provider.walletAccounts,
        selectedAccount: provider.connectedAccount,
        onComplete: _onCompleteHandler(completer, widget.onDisconnect),
        onCompleteError: _onCompleteErrorHandler(completer, widget.onDisconnectError),
      ),
    );
  }

  /// Creates an `onPressed` callback function for [account].
  VoidCallback _onPressed(final Account? account, final SolanaWalletProvider provider) {
    return account != null
      ? () => _onDisconnect(provider)
      : () => _onConnect(provider);
  }

  /// Builds the button's child widget for [account].
  Widget _buildChild(final Account? account) {
    return account != null 
      ? SolanaWalletTextOverflow(text: account.addressBase58)
      : const Text('Connect');
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
      style: widget.style,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      statesController: widget.statesController,
      child: widget.child 
        ?? widget.builder?.call(connectedAccount) 
        ?? _buildChild(connectedAccount),
    );
  }
}