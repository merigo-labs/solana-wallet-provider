/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;


/// Solana Wallet Copy Text
/// ------------------------------------------------------------------------------------------------

/// A widget that copies [text] to the clipboard when pressed.
class SolanaWalletCopyText extends StatefulWidget {

  /// Creates a widget that copies [text] to the clipboard when pressed.
  const SolanaWalletCopyText({
    super.key,
    required this.text,
    required this.child,
    this.onLongPress = false,
  });

  /// The text copied to the clipboard.
  final String text;

  /// The widget to apply the tap gesture to.
  final Widget child;

  /// If true, perform copy on a long press.
  final bool onLongPress;

  @override
  State<SolanaWalletCopyText> createState() => _SolanaWalletCopyTextState();
}


/// Solana Wallet Copy Text State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletCopyTextState extends State<SolanaWalletCopyText> {

  /// True if 'Copied to clipboard.' should be visible.
  bool _showMessage = false;

  /// Copy [widget.text] to the clipboard and overlay a message.
  void _copyText() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.text));
      if (mounted) setState(() => _showMessage = true);
      await Future.delayed(const Duration(seconds: 1));
    } catch (_) {
      // Ignore errors.
    } finally {
      setState(() => _showMessage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback? handler = _showMessage ? null : _copyText;
    return GestureDetector(
      onTap: widget.onLongPress ? null : handler,
      onLongPress: widget.onLongPress ? handler : null,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_showMessage,
              child: AnimatedOpacity(
                opacity: _showMessage ? 1.0 : 0.0,
                duration: const Duration(
                  milliseconds: 100,
                ),
                child: ColoredBox(
                  color: Theme.of(context).cardColor,
                  child: const Center(
                    child: Text(
                      'Copied to clipboard.', 
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