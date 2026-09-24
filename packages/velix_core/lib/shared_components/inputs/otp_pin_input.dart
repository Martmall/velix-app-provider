import 'package:flutter/material.dart';

class OtpPinInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final Color? fillColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? activeBorderColor;

  const OtpPinInput({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.fillColor,
    this.textColor,
    this.borderColor,
    this.activeBorderColor,
  });

  @override
  State<OtpPinInput> createState() => _OtpPinInputState();
}

class _OtpPinInputState extends State<OtpPinInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.fillColor ?? Colors.white;
    final txtColor = widget.textColor ?? const Color(0xFFC84C00);
    final borderCol = widget.borderColor ?? const Color(0xFFE5E7EB);
    final activeBorderCol = widget.activeBorderColor ?? const Color(0xFFC84C00);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => SizedBox(
          width: 48,
          height: 56,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: txtColor,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: bg,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: activeBorderCol, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderCol),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderCol),
              ),
            ),
            onChanged: (val) => _onChanged(index, val),
          ),
        ),
      ),
    );
  }
}
