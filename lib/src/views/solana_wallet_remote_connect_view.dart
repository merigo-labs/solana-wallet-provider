/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'solana_wallet_list_view.dart';
import '../layouts/solana_wallet_grid.dart';
import '../themes/solana_wallet_qr_code_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../widgets/solana_wallet_copy_text.dart';
import '../../src/widgets/solana_wallet_countdown.dart';


/// Solana Wallet Remote Connect View
/// ------------------------------------------------------------------------------------------------

/// A view that presents a QR code to connect to [hostAuthority].
class SolanaWalletRemoteConnectView extends StatelessWidget {
  
  /// Creates a view that presents a QR code to connect to [hostAuthority].
  const SolanaWalletRemoteConnectView({
    super.key,
    required this.hostAuthority,
    required this.timeout,
  });

  /// The address of a publicly routable web socket server that implements the reflector protocol.
  final String hostAuthority;

  /// The connection's time out duration.
  final Duration timeout;

  @override
  Widget build(BuildContext context) {
    final SolanaWalletQrCodeTheme? qrTheme = SolanaWalletThemeExtension.of(context)?.qrCodeTheme;
    return SolanaWalletListView(
      children: [
        SolanaWalletListView(
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
                text: hostAuthority, 
                child: QrImage(
                  data: hostAuthority,
                  foregroundColor: qrTheme?.foregroundColor,
                  backgroundColor: qrTheme?.backgroundColor ?? Colors.transparent,
                  padding: qrTheme?.padding ?? const EdgeInsets.all(SolanaWalletGrid.x2),
                  size: qrTheme?.size ?? SolanaWalletGrid.x1 * 24,
                ),
              ),
            ),
            SolanaWalletCountdown(
              duration: timeout,
            ),
          ],
        ),
        const Text(
          'Open your mobile wallet and scan the QR code to connect.',
        ),
      ],
    );
  }
}