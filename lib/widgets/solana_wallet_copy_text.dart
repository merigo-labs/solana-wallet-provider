/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import '../solana_wallet_constants.dart';
import '../themes/solana_wallet_theme_extension.dart';


/// Solana Wallet Copy Text
/// ------------------------------------------------------------------------------------------------

class SolanaWalletCopyText extends StatefulWidget {

  /// Creates a widget that copies [text] to the clipboard when pressed.
  const SolanaWalletCopyText({
    super.key,
    required this.text,
    required this.child,
    this.longPress = false,
  });

  /// The text copied to the clipboard.
  final String text;

  /// The widget to apply the tap gesture to.
  final Widget child;

  /// If true, perform the copy on a long press (default: `false`).
  final bool longPress;

  @override
  State<SolanaWalletCopyText> createState() => _SolanaWalletCopyTextState();
}


/// Solana Wallet Copy Text State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletCopyTextState extends State<SolanaWalletCopyText> {

  /// If true, display the copy message.
  bool _overlay = false;

  /// Copy [widget.text] to the clipboard and overlay a message.
  void _copyText() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.text));
      setState(() => _overlay = true);
      await Future.delayed(const Duration(seconds: 1));
    } catch (_) {
    } finally {
      setState(() => _overlay = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SolanaWalletThemeExtension? extension = SolanaWalletThemeExtension.of(context);
    final Color colour = extension?.cardTheme?.color ?? cardColourOf(Theme.of(context));
    final VoidCallback? handler = _overlay ? null : _copyText;
    return GestureDetector(
      onTap: widget.longPress ? null : handler,
      onLongPress: widget.longPress ? handler : null,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_overlay,
              child: AnimatedOpacity(
                opacity: _overlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 100),
                child: ColoredBox(
                  color: colour,
                  child: const Center(
                    child: Text(
                      'Copied to clipboard', 
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}