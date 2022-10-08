/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../layouts/solana_wallet_layout_grid.dart';
import '../solana_wallet_icons.dart';
import '../themes/solana_wallet_qr_code_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../widgets/solana_wallet_card.dart';
import '../widgets/solana_wallet_column.dart';
import '../widgets/solana_wallet_copy_text.dart';


/// Solana Wallet Connect Remotely View
/// ------------------------------------------------------------------------------------------------

class SolanaWalletConnectRemotelyView extends StatelessWidget {

  /// Creates a view that displays [hostAuthority] as a QR code that can be scanned by a remote 
  /// wallet application to establish a secure connection.
  const SolanaWalletConnectRemotelyView({
    super.key,
    required this.hostAuthority,
  });

  /// The connection uri.
  final String hostAuthority;

  @override
  Widget build(BuildContext context) {
    final SolanaWalletThemeExtension? extension = SolanaWalletThemeExtension.of(context);
    final SolanaWalletQrCodeTheme? qrCodeTheme = extension?.qrCodeTheme;
    return SolanaWalletCard(
      title: 'Download Wallet',
      child: SolanaWalletColumn(
        spacing: SolanaWalletLayoutGrid.x2,
        children: [
          const Text(
            'Open your Solana wallet app and scan the QR code to connect.',
          ),
          SolanaWalletColumn(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  border: qrCodeTheme?.border,
                  borderRadius: qrCodeTheme?.borderRadius,
                  color: qrCodeTheme?.backgroundColor,
                ),
                child: QrImage(
                  data: hostAuthority,
                  size: qrCodeTheme?.size ?? SolanaWalletLayoutGrid.x1 * 24,
                  foregroundColor: qrCodeTheme?.foregroundColor,
                  padding: qrCodeTheme?.padding ?? const EdgeInsets.all(0),
                ),
              ),
              SolanaWalletCopyText(
                text: hostAuthority, 
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      hostAuthority,
                      maxLines: 2,
                    ),
                    const SizedBox(
                      width: SolanaWalletLayoutGrid.x1,
                    ),
                    const Icon(
                      SolanaWalletIcons.copy,
                      size: SolanaWalletIcons.size,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}