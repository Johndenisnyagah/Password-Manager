import 'package:flutter/material.dart';
import '../../../../core/utils/password_validator.dart';

/// A widget that visually displays the strength of a password using a progress bar.
class PasswordStrengthIndicator extends StatelessWidget {
  /// The password strength value between 0.0 and 1.0.
  final double strength;

  /// Creates a [PasswordStrengthIndicator].
  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    final color = PasswordValidator.getStrengthColor(strength);
    final text = PasswordValidator.getStrengthText(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: strength,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
