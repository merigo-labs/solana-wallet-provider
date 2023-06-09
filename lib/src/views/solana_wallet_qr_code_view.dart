/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show AppInfo;
import '../layouts/solana_wallet_grid.dart';
import '../themes/solana_wallet_qr_code_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../views/solana_wallet_modal_view.dart';
import '../widgets/solana_wallet_copy_text.dart';
import '../widgets/solana_wallet_countdown.dart';
import 'solana_wallet_column_view.dart';


/// Solana Wallet QR Code View
/// ------------------------------------------------------------------------------------------------

/// A view that presents a QR code to connect a dApp to a wallet application via [hostAuthority].
class SolanaWalletQrCodeView extends StatefulWidget {
  
  /// Creates a view that presents a QR code to connect to a wallet application via [hostAuthority].
  const SolanaWalletQrCodeView({
    super.key,
    this.app,
    required this.hostAuthority,
    required this.timeLimit,
    required this.onPressedDownload,
    this.onTimeout,
  });

  /// The application being connected to.
  final AppInfo? app;

  /// The address of a publicly routable web socket server that implements the reflector protocol.
  final String hostAuthority;

  /// The on tap dowload link handler.
  final void Function(AppInfo? app) onPressedDownload;

  /// The connection's time out duration.
  final Duration timeLimit;

  /// Called when [timeLimit] elapses.
  final void Function()? onTimeout;

  @override
  State<SolanaWalletQrCodeView> createState() => _SolanaWalletQrCodeViewState();
}


/// Solana Wallet QR Code View State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletQrCodeViewState extends State<SolanaWalletQrCodeView> {
  
  /// The download link text's tap gesture recognizer.
  final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer.onTap = () => widget.onPressedDownload(widget.app);
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final SolanaWalletQrCodeTheme? qrTheme = SolanaWalletThemeExtension.of(context)?.qrCodeTheme;
    final Color accentColor = Theme.of(context).colorScheme.primary;
    final TextStyle textStyle = DefaultTextStyle.of(context).style;
    final String? name = widget.app?.name;
    final Color foregroundColor = qrTheme?.foregroundColor ?? Colors.black;
    final EdgeInsets padding = qrTheme?.padding ?? const EdgeInsets.all(SolanaWalletGrid.x1);
    final BorderRadius borderRadius = qrTheme?.borderRadius ?? BorderRadius.circular(
      padding.collapsedSize.shortestSide,
    );
    return SolanaWalletModalView(
      title: Text('Connect ${name ?? "Wallet"}'),
      message: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "Open your mobile wallet and scan the QR code. Don't have a wallet? ",
          children: [
            TextSpan(
              text: 'Download ${name ?? "App"}', 
              recognizer: _tapGestureRecognizer,
              style: TextStyle(fontWeight: FontWeight.w500, color: accentColor),
            ),
            const TextSpan(text: '.'),
          ],
          style: textStyle,
        ),
      ),
      body: SolanaWalletColumnView(
        spacing: SolanaWalletGrid.x1,
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                border: qrTheme?.border ?? Border.all(
                  color: foregroundColor,
                ),
                borderRadius: borderRadius,
              ),
              child: SolanaWalletCopyText(
                text: widget.hostAuthority, 
                child: QrImageView(
                  data: widget.hostAuthority,
                  embeddedImage: widget.app?.icon,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: foregroundColor,
                  ),
                  backgroundColor: qrTheme?.backgroundColor ?? Colors.white,
                  padding: qrTheme?.padding ?? const EdgeInsets.all(SolanaWalletGrid.x2),
                  size: qrTheme?.size ?? SolanaWalletGrid.x1 * 24,
                ),
              ),
            ),
          ),
          SolanaWalletCountdown(
            duration: widget.timeLimit,
            onTimeout: widget.onTimeout,
          ),
        ],
      ),
    );
  }
}