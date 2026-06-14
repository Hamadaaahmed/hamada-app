import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/chat_socket_service.dart';
import '../../data/client_chat_service.dart';

class ClientChatScreen extends StatefulWidget {
  const ClientChatScreen({super.key});

  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends State<ClientChatScreen> {
  final _service = ClientChatService();
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  bool _loading = true;
  bool _sending = false;
  int _conversationId = 0;
  List<Map<String, dynamic>> _messages = [];
  StreamSubscription<Map<String, dynamic>>? _socketSub;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    ChatSocketService.I.disconnect();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _connectSocket() async {
    final token = await ChatSocketService.I.getTokenForRole('client');
    if (token == null || token.isEmpty || _conversationId <= 0) return;

    await _socketSub?.cancel();
    _socketSub = ChatSocketService.I
        .connectAndJoin(
          token: token,
          role: 'client',
          conversationId: _conversationId,
        )
        .listen(_handleSocketEvent);
  }

  void _handleSocketEvent(Map<String, dynamic> data) {
    final event = (data['_event'] ?? 'message').toString();

    if (event == 'seen') {
      final conversationId =
          int.tryParse('${data['conversationId'] ?? data['conversation_id']}') ??
              0;
      if (conversationId != _conversationId) return;

      final readerRole =
          (data['reader_role'] ?? '').toString().trim().toLowerCase();
      if (readerRole != 'admin') return;

      final seenAt = (data['seen_at'] ?? '').toString();
      if (!mounted) return;

      setState(() {
        _messages = _messages.map((m) {
          if (_isClientSideRole((m['sender_role'] ?? '').toString())) {
            return {
              ...m,
              'read_at':
                  seenAt.isNotEmpty ? seenAt : (m['read_at'] ?? '').toString(),
              'seen_at':
                  seenAt.isNotEmpty ? seenAt : (m['seen_at'] ?? '').toString(),
              'is_read': true,
            };
          }
          return m;
        }).toList();
      });
      return;
    }

    if (event != 'message') return;

    final msg = _normalizeMessage(data);
    if ((int.tryParse('${msg['conversation_id']}') ?? 0) != _conversationId) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _messages = _mergeMessages(_messages, [msg]);
    });

    _markSeenSilently();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _markSeenSilently() async {
    try {
      await _service.markSeen();
    } catch (_) {}
  }

  Future<void> _boot() async {
    if (mounted) setState(() => _loading = true);

    try {
      final conv = await _service.getConversation();
      if (!mounted) return;

      if (conv['ok'] == true) {
        final c = conv['conversation'] as Map<String, dynamic>?;
        _conversationId = int.tryParse('${c?['id']}') ?? 0;
      }

      await _loadMessages();
      await _connectSocket();
      await _markSeenSilently();
    } catch (_) {
      if (!mounted) return;
      _snack('تعذر تحميل الشات، حاول مرة أخرى', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _normalizeMessage(
    Map<String, dynamic> raw, {
    String fallbackRole = 'client',
    int? fallbackConversationId,
    String? fallbackText,
  }) {
    return {
      'id': int.tryParse('${raw['id']}') ?? 0,
      'conversation_id': int.tryParse('${raw['conversation_id']}') ??
          int.tryParse('${raw['conversationId']}') ??
          fallbackConversationId ??
          _conversationId,
      'sender_role': (raw['sender_role'] ?? fallbackRole).toString(),
      'sender_id': raw['sender_id'] == null
          ? null
          : int.tryParse('${raw['sender_id']}'),
      'text': (raw['text'] ?? fallbackText ?? '').toString(),
      'created_at': (raw['created_at'] ?? '').toString(),
      'read_at': (raw['read_at'] ?? raw['seen_at'] ?? '').toString(),
      'seen_at': (raw['seen_at'] ?? raw['read_at'] ?? '').toString(),
      'is_read': raw['is_read'] == true ||
          '${raw['is_read']}'.toLowerCase() == 'true' ||
          (raw['seen_at'] ?? '').toString().trim().isNotEmpty ||
          (raw['read_at'] ?? '').toString().trim().isNotEmpty,
      if (raw['_local_echo'] == true) '_local_echo': true,
    };
  }

  DateTime? _tryParseDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  bool _isClientSideRole(String role) {
    final value = role.trim().toLowerCase();
    return value == 'client' || value == 'customer' || value == 'user';
  }

  bool _isLikelySameMessage(Map<String, dynamic> a, Map<String, dynamic> b) {
    final aRole = (a['sender_role'] ?? '').toString();
    final bRole = (b['sender_role'] ?? '').toString();

    final sameSide = _isClientSideRole(aRole) == _isClientSideRole(bRole);
    final sameText =
        (a['text'] ?? '').toString().trim() == (b['text'] ?? '').toString().trim();

    if (!sameSide || !sameText) return false;

    final aId = int.tryParse('${a['id']}') ?? 0;
    final bId = int.tryParse('${b['id']}') ?? 0;
    if (aId > 0 && bId > 0) return aId == bId;

    final aLocal = a['_local_echo'] == true;
    final bLocal = b['_local_echo'] == true;

    // ندمج فقط لو واحدة محلية مؤقتة والثانية من السيرفر
    if (aLocal == bLocal) return false;

    final aDate = _tryParseDate((a['created_at'] ?? '').toString());
    final bDate = _tryParseDate((b['created_at'] ?? '').toString());
    if (aDate == null || bDate == null) return false;

    return aDate.difference(bDate).inSeconds.abs() <= 5;
  }

  List<Map<String, dynamic>> _mergeMessages(
    List<Map<String, dynamic>> current,
    List<Map<String, dynamic>> incoming,
  ) {
    final merged = <Map<String, dynamic>>[];

    for (final msg in [...current, ...incoming]) {
      final normalized = _normalizeMessage(msg);
      final id = int.tryParse('${normalized['id']}') ?? 0;

      final existingIndex = merged.indexWhere((m) {
        final existingId = int.tryParse('${m['id']}') ?? 0;
        if (id > 0 && existingId > 0) return existingId == id;
        return _isLikelySameMessage(m, normalized);
      });

      if (existingIndex >= 0) {
        final existing = merged[existingIndex];
        merged[existingIndex] = {
          ...existing,
          ...normalized,
          '_local_echo': false,
        };
      } else {
        merged.add(normalized);
      }
    }

    merged.sort((a, b) {
      final aDate = _tryParseDate((a['created_at'] ?? '').toString());
      final bDate = _tryParseDate((b['created_at'] ?? '').toString());
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return -1;
      if (bDate == null) return 1;
      return aDate.compareTo(bDate);
    });

    return merged;
  }

  Future<void> _loadMessages() async {
    try {
      final data = await _service.getMessages();
      if (!mounted) return;

      final list =
          List<Map<String, dynamic>>.from(data['messages'] as List? ?? const []);
      setState(() {
        _conversationId =
            int.tryParse('${data['conversation_id']}') ?? _conversationId;
        _messages = _mergeMessages(const [], list);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {
      if (mounted) {
        _snack('تعذر تحميل الرسائل، حاول مرة أخرى', error: true);
      }
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    if (mounted) setState(() => _sending = true);

    try {
      final res = await _service.sendMessage(text);
      if (!mounted) return;

      if (res['ok'] == true) {
        final raw = res['message'] is Map
            ? Map<String, dynamic>.from(res['message'] as Map)
            : <String, dynamic>{};

        final message = _normalizeMessage(
          raw,
          fallbackRole: 'client',
          fallbackConversationId: _conversationId,
          fallbackText: text,
        );

        if ((message['created_at'] ?? '').toString().trim().isEmpty) {
          message['created_at'] = DateTime.now().toUtc().toIso8601String();
        }
        message['_local_echo'] = true;

        _controller.clear();
        setState(() {
          _messages = _mergeMessages(_messages, [message]);
        });

        ChatSocketService.I.sendMessageEvent(message);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        _snack(
          (res['error'] ?? 'تعذر إرسال الرسالة، حاول مرة أخرى').toString(),
          error: true,
        );
      }
    } catch (_) {
      _snack('تعذر إرسال الرسالة، حاول مرة أخرى', error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  String _fmtDate(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h24 = dt.hour;
      final h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
      final period = h24 >= 12 ? 'م' : 'ص';
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$h12:$mm $period';
    } catch (_) {
      return raw;
    }
  }

  String _statusText(Map<String, dynamic> msg) {
    if (!_isClientSideRole((msg['sender_role'] ?? '').toString())) return '';

    final seenAt = (msg['seen_at'] ?? '').toString().trim();
    final readAt = (msg['read_at'] ?? '').toString().trim();
    final isRead = msg['is_read'] == true;

    if (seenAt.isNotEmpty || readAt.isNotEmpty || isRead) {
      return '✓✓';
    }
    return '✓';
  }

  Widget _bubble(Map<String, dynamic> msg) {
    final isMine = _isClientSideRole((msg['sender_role'] ?? '').toString());
    final align = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final status = _statusText(msg);

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isMine
              ? Theme.of(context).colorScheme.primary.withAlpha(35)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg['text'].toString()),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _fmtDate(msg['created_at'].toString()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (isMine) ...[
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشات'),
        actions: [
          IconButton(
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? const Center(child: Text('لا توجد رسائل بعد'))
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(12),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) => _bubble(_messages[i]),
                        ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'اكتب رسالتك...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _sending ? null : _send,
                          icon: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
