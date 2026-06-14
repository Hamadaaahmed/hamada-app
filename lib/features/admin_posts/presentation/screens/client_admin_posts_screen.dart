import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../config/app_config.dart';
import '../../data/admin_posts_service.dart';

class ClientAdminPostsScreen extends StatefulWidget {
  const ClientAdminPostsScreen({super.key});

  @override
  State<ClientAdminPostsScreen> createState() => _ClientAdminPostsScreenState();
}

class _ClientAdminPostsScreenState extends State<ClientAdminPostsScreen> {
  final _service = AdminPostsService();
  final _pageController = PageController(viewportFraction: 0.92);

  bool _loading = true;
  int _index = 0;
  List<Map<String, dynamic>> _posts = const [];

  String _absoluteUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    var baseUrl = AppConfig.apiBaseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    return '$baseUrl$value';
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final posts = await _service.listPublicPosts();
      if (!mounted) return;
      setState(() => _posts = posts);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _openViewer(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PostsViewerScreen(
          posts: _posts,
          initialIndex: initialIndex,
          absoluteUrl: _absoluteUrl,
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> post, int index) {
    final imageUrl = _absoluteUrl(post['image_url']?.toString());
    final message = (post['message'] ?? '').toString().trim();

    return GestureDetector(
      onTap: () => _openViewer(index),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 46),
                ),
              )
            else
              Container(
                color: const Color(0xFF111827),
                child: const Center(
                  child: Icon(Icons.campaign_outlined,
                      size: 54, color: Colors.white70),
                ),
              ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0x55000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),
            if (message.isNotEmpty)
              Positioned(
                right: 14,
                left: 14,
                bottom: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعلانات الإدارة'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد إعلانات حالية',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 14),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _posts.length,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 10),
                          child: _buildCard(_posts[i], i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_posts.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: active
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white24,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
    );
  }
}

class _PostsViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  final int initialIndex;
  final String Function(String?) absoluteUrl;

  const _PostsViewerScreen({
    required this.posts,
    required this.initialIndex,
    required this.absoluteUrl,
  });

  @override
  State<_PostsViewerScreen> createState() => _PostsViewerScreenState();
}

class _PostsViewerScreenState extends State<_PostsViewerScreen> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('إعلان ${_index + 1}/${widget.posts.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.posts.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) {
          final post = widget.posts[i];
          final imageUrl = widget.absoluteUrl(post['image_url']?.toString());
          final message = (post['message'] ?? '').toString().trim();

          return Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white70,
                            size: 48,
                          ),
                        )
                      : const Icon(
                          Icons.campaign_outlined,
                          color: Colors.white70,
                          size: 56,
                        ),
                ),
              ),
              if (message.isNotEmpty)
                Positioned(
                  right: 14,
                  left: 14,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(170),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
