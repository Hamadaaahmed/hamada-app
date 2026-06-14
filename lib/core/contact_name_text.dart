import 'package:flutter/material.dart';
import 'phone_contact_helper.dart';

class ContactNameText extends StatefulWidget {
  final String phone;
  final TextStyle? style;
  final String? fallbackPrefix;

  const ContactNameText({
    super.key,
    required this.phone,
    this.style,
    this.fallbackPrefix,
  });

  @override
  State<ContactNameText> createState() => _ContactNameTextState();
}

class _ContactNameTextState extends State<ContactNameText> {
  String? _name;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final name = await PhoneContactHelper.findNameByPhone(widget.phone);
      if (!mounted) return;
      setState(() {
        _name = name;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallback = widget.fallbackPrefix == null
        ? widget.phone
        : '${widget.fallbackPrefix!} ${widget.phone}';

    return Text(
      _loading
          ? fallback
          : (_name?.trim().isNotEmpty == true ? _name! : fallback),
      style: widget.style,
    );
  }
}
