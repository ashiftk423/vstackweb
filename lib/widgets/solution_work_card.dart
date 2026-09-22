import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:vstackweb/models/solution.dart';
import 'package:vstackweb/theme/responsive.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class SolutionWorkCard extends StatelessWidget {
  const SolutionWorkCard({
    super.key,
    required this.work,
    required this.works,
    required this.index,
  });

  final SolutionWork work;
  final List<SolutionWork> works;
  final int index;

  void _openMoreInfo(BuildContext context) {
    if (!work.hasMoreInfo) return;
    final isMobile = AppLayout.isMobile(context);
    final body = _MoreInfoBody(work: work);

    if (isMobile) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: VStackColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(VStackRadius.lg)),
        ),
        builder: (ctx) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: VStackColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        work.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: body,
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: VStackColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(VStackRadius.lg)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        work.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        pageBuilder: (context, animation, secondaryAnimation) => _WorkMediaViewer(
          works: works,
          initialIndex: index,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (AppLayout.isMobile(context)) {
      return _IgGridCell(
        work: work,
        onOpen: () => _openViewer(context),
      );
    }

    return VStackCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(VStackRadius.lg)),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: work.isVideo
                  ? _WorkVideoThumb(
                      assetPath: work.media,
                      onOpen: () => _openViewer(context),
                      compact: false,
                    )
                  : _WorkImageThumb(
                      assetPath: work.media,
                      onOpen: () => _openViewer(context),
                      compact: false,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(VStackSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  work.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                if (work.hasMoreInfo) ...[
                  const SizedBox(height: VStackSpacing.sm),
                  TextButton(
                    onPressed: () => _openMoreInfo(context),
                    style: TextButton.styleFrom(
                      foregroundColor: VStackColors.accent,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('More info'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dense Instagram-style grid cell (mobile): thumb only + long-press peek.
class _IgGridCell extends StatefulWidget {
  const _IgGridCell({
    required this.work,
    required this.onOpen,
  });

  final SolutionWork work;
  final VoidCallback onOpen;

  @override
  State<_IgGridCell> createState() => _IgGridCellState();
}

class _IgGridCellState extends State<_IgGridCell> {
  OverlayEntry? _peekEntry;

  void _showPeek() {
    if (_peekEntry != null) return;
    HapticFeedback.mediumImpact();
    final overlay = Overlay.of(context);
    _peekEntry = OverlayEntry(
      builder: (ctx) => _WorkPeekOverlay(
        work: widget.work,
        onDismiss: _hidePeek,
      ),
    );
    overlay.insert(_peekEntry!);
  }

  void _hidePeek() {
    _peekEntry?.remove();
    _peekEntry = null;
  }

  @override
  void dispose() {
    _hidePeek();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: widget.work.isVideo
          ? _WorkVideoThumb(
              assetPath: widget.work.media,
              onOpen: widget.onOpen,
              compact: true,
              onPeekStart: _showPeek,
              onPeekEnd: _hidePeek,
            )
          : _WorkImageThumb(
              assetPath: widget.work.media,
              onOpen: widget.onOpen,
              compact: true,
              onPeekStart: _showPeek,
              onPeekEnd: _hidePeek,
            ),
    );
  }
}

class _WorkPeekOverlay extends StatefulWidget {
  const _WorkPeekOverlay({
    required this.work,
    required this.onDismiss,
  });

  final SolutionWork work;
  final VoidCallback onDismiss;

  @override
  State<_WorkPeekOverlay> createState() => _WorkPeekOverlayState();
}

class _WorkPeekOverlayState extends State<_WorkPeekOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  VideoPlayerController? _video;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..forward();
    if (widget.work.isVideo) _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final c = VideoPlayerController.asset(widget.work.media);
      _video = c;
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      await c.play();
      if (!mounted) return;
      setState(() => _videoReady = true);
    } catch (_) {
      // Fall back to static frame / image path failure handled below.
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardW = size.width * 0.82;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onDismiss,
        behavior: HitTestBehavior.opaque,
        child: FadeTransition(
          opacity: _anim,
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.55),
            child: Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1).animate(
                  CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
                ),
                child: GestureDetector(
                  onTap: () {}, // absorb taps on card
                  child: Material(
                    elevation: 24,
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: cardW,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AspectRatio(
                            aspectRatio: 4 / 5,
                            child: _buildMedia(),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                            child: Text(
                              widget.work.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.work.isVideo) {
      if (_videoReady && _video != null) {
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _video!.value.size.width,
            height: _video!.value.size.height,
            child: VideoPlayer(_video!),
          ),
        );
      }
      return const ColoredBox(
        color: Colors.black87,
        child: Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)),
      );
    }
    return Image.asset(
      widget.work.media,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stackTrace) => const _MediaFallback(isVideo: false),
    );
  }
}

class _MoreInfoBody extends StatelessWidget {
  const _MoreInfoBody({required this.work});

  final SolutionWork work;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (work.hasDescription) ...[
          const Text(
            'About this work',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: VStackColors.muted),
          ),
          const SizedBox(height: 8),
          Text(work.description!, style: const TextStyle(height: 1.5, fontSize: 14)),
        ],
        if (work.hasDescription && work.hasInsightImage) const SizedBox(height: VStackSpacing.lg),
        if (work.hasInsightImage) ...[
          const Text(
            'Instagram insights',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: VStackColors.muted),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(VStackRadius.sm),
            child: Image.asset(
              work.insightImage!,
              fit: BoxFit.contain,
              errorBuilder: (_, error, stackTrace) => Container(
                height: 120,
                alignment: Alignment.center,
                color: VStackColors.surfaceLight,
                child: const Text('Insight image not found', style: TextStyle(color: VStackColors.muted)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback({required this.isVideo});

  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: VStackColors.surfaceLight,
      child: Center(
        child: Icon(
          isVideo ? Icons.videocam_outlined : Icons.image_outlined,
          size: 40,
          color: VStackColors.muted,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

/// Soft shimmer placeholder while media loads.
class _MediaLoadingSkeleton extends StatefulWidget {
  const _MediaLoadingSkeleton({required this.isVideo});

  final bool isVideo;

  @override
  State<_MediaLoadingSkeleton> createState() => _MediaLoadingSkeletonState();
}

class _MediaLoadingSkeletonState extends State<_MediaLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.2 + 2.4 * t, -0.4),
                  end: Alignment(-0.2 + 2.4 * t, 0.6),
                  colors: [
                    VStackColors.surfaceLight,
                    VStackColors.accent.withValues(alpha: 0.18),
                    VStackColors.surfaceLight,
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isVideo ? Icons.play_circle_outline : Icons.image_outlined,
                    size: 36,
                    color: VStackColors.accent.withValues(alpha: 0.85),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.isVideo ? 'Loading video…' : 'Loading photo…',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WorkImageThumb extends StatefulWidget {
  const _WorkImageThumb({
    required this.assetPath,
    required this.onOpen,
    this.compact = false,
    this.onPeekStart,
    this.onPeekEnd,
  });

  final String assetPath;
  final VoidCallback onOpen;
  final bool compact;
  final VoidCallback? onPeekStart;
  final VoidCallback? onPeekEnd;

  @override
  State<_WorkImageThumb> createState() => _WorkImageThumbState();
}

class _WorkImageThumbState extends State<_WorkImageThumb> {
  bool _holding = false;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _precache());
  }

  Future<void> _precache() async {
    if (!mounted) return;
    try {
      await precacheImage(AssetImage(widget.assetPath), context);
      if (!mounted) return;
      setState(() => _loaded = true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return widget.compact
          ? ColoredBox(color: VStackColors.surfaceLight)
          : const _MediaLoadingSkeleton(isVideo: false);
    }
    if (_failed) return const _MediaFallback(isVideo: false);

    final useOverlayPeek = widget.onPeekStart != null;

    return GestureDetector(
      onTap: widget.onOpen,
      onLongPressStart: (_) {
        if (useOverlayPeek) {
          widget.onPeekStart!();
          return;
        }
        HapticFeedback.selectionClick();
        setState(() => _holding = true);
      },
      onLongPressEnd: (_) {
        if (useOverlayPeek) {
          widget.onPeekEnd?.call();
          return;
        }
        setState(() => _holding = false);
      },
      onLongPressCancel: () {
        if (useOverlayPeek) {
          widget.onPeekEnd?.call();
          return;
        }
        setState(() => _holding = false);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedScale(
            scale: (!useOverlayPeek && _holding) ? 1.04 : 1,
            duration: const Duration(milliseconds: 180),
            child: Image.asset(widget.assetPath, fit: BoxFit.cover),
          ),
          if (!widget.compact)
            const Positioned(
              left: 10,
              top: 10,
              child: _TypeBadge(label: 'PHOTO', icon: Icons.image_outlined),
            ),
        ],
      ),
    );
  }
}

/// Lazy-loads video only when the card is on screen.
class _WorkVideoThumb extends StatefulWidget {
  const _WorkVideoThumb({
    required this.assetPath,
    required this.onOpen,
    this.compact = false,
    this.onPeekStart,
    this.onPeekEnd,
  });

  final String assetPath;
  final VoidCallback onOpen;
  final bool compact;
  final VoidCallback? onPeekStart;
  final VoidCallback? onPeekEnd;

  @override
  State<_WorkVideoThumb> createState() => _WorkVideoThumbState();
}

class _WorkVideoThumbState extends State<_WorkVideoThumb> {
  VideoPlayerController? _controller;
  bool _visible = false;
  bool _ready = false;
  bool _failed = false;
  bool _holding = false;
  bool _loading = false;

  Future<void> _ensureLoaded() async {
    if (_controller != null || _loading || _failed) return;
    _loading = true;
    if (mounted) setState(() {});
    try {
      final controller = VideoPlayerController.asset(widget.assetPath);
      _controller = controller;
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.pause();
      await controller.seekTo(Duration.zero);
      if (!mounted) return;
      setState(() {
        _ready = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _onVisibility(VisibilityInfo info) {
    final nowVisible = info.visibleFraction >= 0.15;
    if (nowVisible && !_visible) {
      _visible = true;
      _ensureLoaded();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startHoldPreview() async {
    if (widget.onPeekStart != null) {
      widget.onPeekStart!();
      return;
    }
    final c = _controller;
    if (c == null || !_ready) return;
    HapticFeedback.selectionClick();
    setState(() => _holding = true);
    await c.setVolume(0);
    await c.play();
    if (mounted) setState(() {});
  }

  Future<void> _endHoldPreview() async {
    if (widget.onPeekEnd != null) {
      widget.onPeekEnd!();
      return;
    }
    final c = _controller;
    if (c == null) return;
    await c.pause();
    await c.seekTo(Duration.zero);
    if (!mounted) return;
    setState(() => _holding = false);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('work-video-${widget.assetPath}'),
      onVisibilityChanged: _onVisibility,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_failed) return const _MediaFallback(isVideo: true);
    if (!_ready || _controller == null) {
      return widget.compact
          ? ColoredBox(color: VStackColors.surfaceLight)
          : const _MediaLoadingSkeleton(isVideo: true);
    }

    return GestureDetector(
      onTap: widget.onOpen,
      onLongPressStart: (_) => _startHoldPreview(),
      onLongPressEnd: (_) => _endHoldPreview(),
      onLongPressCancel: () => _endHoldPreview(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
          if (!_holding && widget.onPeekStart == null)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.28),
              child: Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: widget.compact ? 28 : 56,
                  color: Colors.white,
                ),
              ),
            ),
          if (widget.compact)
            Positioned(
              right: 6,
              top: 6,
              child: Icon(
                Icons.play_arrow_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.95),
                shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            )
          else ...[
            const Positioned(
              left: 10,
              top: 10,
              child: _TypeBadge(label: 'VIDEO', icon: Icons.play_arrow_rounded),
            ),
            if (_holding)
              const Positioned(
                right: 10,
                bottom: 10,
                child: _TypeBadge(label: 'PREVIEW', icon: Icons.visibility_outlined),
              ),
          ],
        ],
      ),
    );
  }
}

class _WorkMediaViewer extends StatefulWidget {
  const _WorkMediaViewer({
    required this.works,
    required this.initialIndex,
  });

  final List<SolutionWork> works;
  final int initialIndex;

  @override
  State<_WorkMediaViewer> createState() => _WorkMediaViewerState();
}

class _WorkMediaViewerState extends State<_WorkMediaViewer> {
  late final PageController _pageController;
  late int _index;
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;
  bool _loading = false;
  bool _muted = true;
  bool _showControls = true;

  SolutionWork get _work => widget.works[_index];
  bool get _hasPrev => _index > 0;
  bool get _hasNext => _index < widget.works.length - 1;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.works.length - 1);
    _pageController = PageController(initialPage: _index);
    _loadCurrent();
  }

  Future<void> _disposePlayer() async {
    final c = _controller;
    _controller = null;
    _ready = false;
    _failed = false;
    if (c != null) {
      c.removeListener(_onTick);
      await c.dispose();
    }
  }

  Future<void> _loadCurrent() async {
    await _disposePlayer();
    if (!mounted) return;
    setState(() {
      _loading = true;
      _failed = false;
      _ready = false;
    });

    if (!_work.isVideo) {
      setState(() => _loading = false);
      return;
    }

    try {
      final controller = VideoPlayerController.asset(_work.media);
      _controller = controller;
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(_muted ? 0 : 1);
      await controller.play();
      controller.addListener(_onTick);
      if (!mounted) return;
      setState(() {
        _ready = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  Future<void> _goTo(int next) async {
    if (next < 0 || next >= widget.works.length || next == _index) return;
    setState(() => _index = next);
    await _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    await _loadCurrent();
  }

  void _onPageChanged(int page) {
    if (page == _index) return;
    setState(() => _index = page);
    _loadCurrent();
  }

  @override
  void dispose() {
    _pageController.dispose();
    final c = _controller;
    c?.removeListener(_onTick);
    c?.dispose();
    super.dispose();
  }

  Future<void> _toggleMute() async {
    final c = _controller;
    if (c == null) return;
    _muted = !_muted;
    await c.setVolume(_muted ? 0 : 1);
    setState(() {});
  }

  Future<void> _togglePlay() async {
    final c = _controller;
    if (c == null || !_ready) return;
    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
    setState(() {});
  }

  Future<void> _seekBy(Duration delta) async {
    final c = _controller;
    if (c == null || !_ready) return;
    final next = c.value.position + delta;
    final clamped = next < Duration.zero
        ? Duration.zero
        : (next > c.value.duration ? c.value.duration : next);
    await c.seekTo(clamped);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppLayout.isMobile(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _goTo(_index - 1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _goTo(_index + 1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _goTo(_index - 1),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _goTo(_index + 1),
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.pop(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    scrollDirection: isMobile ? Axis.vertical : Axis.horizontal,
                    controller: _pageController,
                    itemCount: widget.works.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, i) {
                      final item = widget.works[i];
                      final active = i == _index;
                      return GestureDetector(
                        onTap: () {
                          if (item.isVideo) {
                            setState(() => _showControls = !_showControls);
                          }
                        },
                        // Desktop: optional vertical fling; mobile uses vertical PageView.
                        onVerticalDragEnd: isMobile
                            ? null
                            : (details) {
                                final v = details.primaryVelocity ?? 0;
                                if (v < -400) {
                                  _goTo(_index + 1);
                                } else if (v > 400) {
                                  _goTo(_index - 1);
                                }
                              },
                        child: Center(
                          child: active
                              ? _buildActiveMedia(item, fullBleed: isMobile)
                              : _buildInactivePlaceholder(item, fullBleed: isMobile),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          _work.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${_index + 1}/${widget.works.length}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  if (_hasPrev)
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _NavCircleButton(
                          icon: Icons.chevron_left,
                          tooltip: 'Previous',
                          onPressed: () => _goTo(_index - 1),
                        ),
                      ),
                    ),
                  if (_hasNext)
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _NavCircleButton(
                          icon: Icons.chevron_right,
                          tooltip: 'Next',
                          onPressed: () => _goTo(_index + 1),
                        ),
                      ),
                    ),
                ],
                if (_work.isVideo && _ready && _showControls && _controller != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _VideoControls(
                      controller: _controller!,
                      muted: _muted,
                      onMute: _toggleMute,
                      onPlayPause: _togglePlay,
                      onBack: () => _seekBy(const Duration(seconds: -5)),
                      onForward: () => _seekBy(const Duration(seconds: 5)),
                      format: _fmt,
                    ),
                  ),
                if (isMobile)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: _work.isVideo && _ready && _showControls ? 130 : 18,
                    child: const Text(
                      'Swipe up for next · down for previous',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInactivePlaceholder(SolutionWork item, {required bool fullBleed}) {
    if (fullBleed) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Icon(
            item.isVideo ? Icons.play_circle_outline : Icons.image_outlined,
            color: Colors.white38,
            size: 48,
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            item.isVideo ? Icons.play_circle_outline : Icons.image_outlined,
            color: Colors.white38,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveMedia(SolutionWork item, {required bool fullBleed}) {
    if (!item.isVideo) {
      final image = Image.asset(
        item.media,
        fit: fullBleed ? BoxFit.contain : BoxFit.contain,
        errorBuilder: (_, error, stackTrace) => const _MediaFallback(isVideo: false),
      );
      if (fullBleed) {
        return SizedBox.expand(child: InteractiveViewer(child: image));
      }
      return InteractiveViewer(child: image);
    }
    if (_loading) {
      return fullBleed
          ? const Center(child: SizedBox(width: 220, height: 320, child: _MediaLoadingSkeleton(isVideo: true)))
          : const SizedBox(
              width: 220,
              height: 320,
              child: _MediaLoadingSkeleton(isVideo: true),
            );
    }
    if (_failed) return const _MediaFallback(isVideo: true);
    if (!_ready || _controller == null) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    final player = AspectRatio(
      aspectRatio: _controller!.value.aspectRatio == 0 ? 9 / 16 : _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
    if (fullBleed) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }
    return player;
  }
}

class _NavCircleButton extends StatelessWidget {
  const _NavCircleButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.controller,
    required this.muted,
    required this.onMute,
    required this.onPlayPause,
    required this.onBack,
    required this.onForward,
    required this.format,
  });

  final VideoPlayerController controller;
  final bool muted;
  final VoidCallback onMute;
  final VoidCallback onPlayPause;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final String Function(Duration) format;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final duration = value.duration.inMilliseconds == 0 ? 1 : value.duration.inMilliseconds;
    final position = value.position.inMilliseconds.clamp(0, duration);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(format(value.position), style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: position.toDouble(),
                    max: duration.toDouble(),
                    activeColor: VStackColors.accent,
                    inactiveColor: Colors.white24,
                    onChanged: (v) => controller.seekTo(Duration(milliseconds: v.round())),
                  ),
                ),
              ),
              Text(format(value.duration), style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: onBack,
                tooltip: 'Back 5s',
                icon: const Icon(Icons.replay_5, color: Colors.white),
              ),
              IconButton(
                onPressed: onPlayPause,
                tooltip: value.isPlaying ? 'Pause' : 'Play',
                icon: Icon(
                  value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              IconButton(
                onPressed: onForward,
                tooltip: 'Forward 5s',
                icon: const Icon(Icons.forward_5, color: Colors.white),
              ),
              IconButton(
                onPressed: onMute,
                tooltip: muted ? 'Unmute' : 'Mute',
                icon: Icon(muted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
