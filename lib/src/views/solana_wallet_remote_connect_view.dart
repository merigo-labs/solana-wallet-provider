/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';
import '../layouts/solana_wallet_grid.dart';
import '../widgets/solana_wallet_copy_text.dart';
import '../../src/views/solana_wallet_content_view.dart';
import '../../src/widgets/solana_wallet_countdown.dart';


/// Solana Wallet Remote Connect View
/// ------------------------------------------------------------------------------------------------

/// A view that presents a QR code to connect to [hostAuthority].
class SolanaWalletRemoteConnectView extends StatefulWidget {
  
  /// Creates a view that presents a QR code to connect to [hostAuthority].
  const SolanaWalletRemoteConnectView({
    super.key,
    this.app,
    required this.hostAuthority,
    required this.timeout,
    this.onTimeout,
  });

  /// The application being connected to.
  final AppInfo? app;

  /// The address of a publicly routable web socket server that implements the reflector protocol.
  final String hostAuthority;

  /// The connection's time out duration.
  final Duration timeout;

  /// Called when [timeout] elapses.
  final VoidCallback? onTimeout;

  @override
  State<SolanaWalletRemoteConnectView> createState() => _SolanaWalletRemoteConnectViewState();
}


/// Solana Wallet Remote Connect View State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletRemoteConnectViewState extends State<SolanaWalletRemoteConnectView> {
  
  /// Download link tap gesture recognizer.
  final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer.onTap = _onTapInstall;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  /// Opens the [SolanaWalletRemoteConnectView.app] store and closes [SolanaWalletProvider]'s modal.
  void _onTapInstall() {
    SolanaWalletAdapterPlatform.instance.openStore(widget.app ?? AppInfo.phantom);
    SolanaWalletProvider.close(context);
  }
  
  @override
  Widget build(BuildContext context) {
    final SolanaWalletQrCodeTheme? qrTheme = SolanaWalletThemeExtension.of(context)?.qrCodeTheme;
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final TextStyle textStyle = DefaultTextStyle.of(context).style;
    return SolanaWalletContentView(
      title: const Text('Connect Wallet'),
      message: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Open your mobile wallet and scan the QR code or ',
          children: [
            TextSpan(
              text: 'Download', 
              recognizer: _tapGestureRecognizer,
              style: TextStyle(fontWeight: FontWeight.bold, color: accentColor),
            ),
            const TextSpan(text: ' the wallet application.'),
          ],
          style: textStyle,
        ),
      ),
      body: SolanaWalletColumnView(
        spacing: SolanaWalletGrid.x1,
        children: [
          DecoratedBox(
            position: DecorationPosition.background,
            decoration: BoxDecoration(
              border: qrTheme?.border ?? Border.all(),
              borderRadius: qrTheme?.borderRadius 
                ?? BorderRadius.circular(
                  SolanaWalletGrid.x2,
                ),
            ),
            child: SolanaWalletCopyText(
              text: widget.hostAuthority, 
              child: QrImage(
                data: widget.hostAuthority,
                embeddedImage: widget.app?.icon,
                foregroundColor: qrTheme?.foregroundColor,
                backgroundColor: qrTheme?.backgroundColor ?? Colors.white,
                padding: qrTheme?.padding ?? const EdgeInsets.all(SolanaWalletGrid.x2),
                size: qrTheme?.size ?? SolanaWalletGrid.x1 * 24,
              ),
            ),
          ),
          SolanaWalletCountdown(
            duration: widget.timeout,
            onTimeout: widget.onTimeout,
          ),
        ],
      ),
    );
  }
}