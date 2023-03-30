/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';


/// Solana Wallet Text Overflow
/// ------------------------------------------------------------------------------------------------

/// A [Text] widget that truncates the middle of [text] when it overflows.
class SolanaWalletTextOverflow extends StatelessWidget {
  
  /// Creates a [Text] widget that truncates the middle of [text] when it overflows.
  const SolanaWalletTextOverflow({
    super.key,
    required this.text,
    this.suffixLength = 4,
    this.style,
  }): assert(suffixLength > 0);

  /// The text to truncate if it overflows.
  final String text;

  /// The fixed number of characters to display at the end of the string.
  final int suffixLength;

  /// Text style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final int prefixLength = text.length > suffixLength ? text.length - suffixLength : text.length;
    final String prefix = text.substring(0, prefixLength);
    final String suffix = text.substring(prefixLength);
    assert(text == (prefix+suffix));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            prefix,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        Text(
          suffix,
          style: style,
        ),
      ],
    );
  }
}