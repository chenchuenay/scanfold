import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A "Protect with password" switch that reveals a password field only when
/// turned on. Keeps the option discoverable without cluttering the screen.
class PasswordProtectField extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const PasswordProtectField({
    super.key,
    required this.controller,
    this.label = 'Password',
  });

  @override
  State<PasswordProtectField> createState() => _PasswordProtectFieldState();
}

class _PasswordProtectFieldState extends State<PasswordProtectField> {
  bool _enabled = false;
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeTrackColor: ScanFoldColors.mint,
          title: const Text(
            'Protect with password',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'Only people with the password can open it',
            style: TextStyle(color: ScanFoldColors.secondary, fontSize: 12),
          ),
          value: _enabled,
          onChanged: (value) {
            setState(() {
              _enabled = value;
              if (!value) widget.controller.clear();
            });
          },
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _enabled
              ? Padding(
                  key: const ValueKey('password'),
                  padding: const EdgeInsets.only(top: 4),
                  child: TextField(
                    controller: widget.controller,
                    obscureText: _obscured,
                    decoration: InputDecoration(
                      labelText: widget.label,
                      hintText: 'Enter a password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: ScanFoldColors.muted,
                        ),
                        onPressed: () => setState(() => _obscured = !_obscured),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
