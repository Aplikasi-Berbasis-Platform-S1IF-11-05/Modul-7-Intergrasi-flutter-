import 'package:flutter/material.dart';

enum NotificationType { success, error, info, warning }

class AppNotification {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Tutup notifikasi sebelumnya kalau masih tampil
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    _insertOnOverlay(overlay, title: title, message: message, type: type, duration: duration);
  }

  /// Versi yang menerima OverlayState langsung — aman dipakai setelah async gap
  static void showOnOverlay(
    OverlayState overlay, {
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    _currentEntry?.remove();
    _currentEntry = null;
    _insertOnOverlay(overlay, title: title, message: message, type: type, duration: duration);
  }

  static void _insertOnOverlay(
    OverlayState overlay, {
    required String title,
    required String message,
    required NotificationType type,
    required Duration duration,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _NotificationBanner(
        title: title,
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);
  }

  // ── Shortcut methods ──────────────────────────────────────

  static void success(BuildContext context, String message,
      {String title = 'Berhasil'}) {
    show(context,
        title: title, message: message, type: NotificationType.success);
  }

  static void error(BuildContext context, String message,
      {String title = 'Gagal'}) {
    show(context,
        title: title,
        message: message,
        type: NotificationType.error,
        duration: const Duration(seconds: 4));
  }

  static void info(BuildContext context, String message,
      {String title = 'Info'}) {
    show(context, title: title, message: message, type: NotificationType.info);
  }

  static void warning(BuildContext context, String message,
      {String title = 'Perhatian'}) {
    show(context,
        title: title,
        message: message,
        type: NotificationType.warning,
        duration: const Duration(seconds: 4));
  }
}

// ── Internal Banner Widget ─────────────────────────────────────────────────

class _NotificationBanner extends StatefulWidget {
  final String title;
  final String message;
  final NotificationType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _NotificationStyle get _style => _getStyle(widget.type);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < 0) {
                  _dismiss();
                }
              },
              onTap: _dismiss,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _style.borderColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _style.shadowColor.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar di atas
                      _ProgressBar(
                        duration: widget.duration,
                        color: _style.accentColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon bulat
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _style.accentColor
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _style.icon,
                                color: _style.accentColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _style.accentColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.message,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Close button
                            GestureDetector(
                              onTap: _dismiss,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}

// ── Progress bar yang countdown sampai dismiss ─────────────────────────────

class _ProgressBar extends StatefulWidget {
  final Duration duration;
  final Color color;

  const _ProgressBar({required this.duration, required this.color});

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => LinearProgressIndicator(
        value: 1 - _ctrl.value,
        minHeight: 3,
        backgroundColor: widget.color.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
      ),
    );
  }
}

// ── Style per tipe notifikasi ──────────────────────────────────────────────

class _NotificationStyle {
  final Color accentColor;
  final Color borderColor;
  final Color shadowColor;
  final IconData icon;

  const _NotificationStyle({
    required this.accentColor,
    required this.borderColor,
    required this.shadowColor,
    required this.icon,
  });
}

_NotificationStyle _getStyle(NotificationType type) {
  switch (type) {
    case NotificationType.success:
      return const _NotificationStyle(
        accentColor: Color(0xFF2E7D32),
        borderColor: Color(0xFFA5D6A7),
        shadowColor: Color(0xFF2E7D32),
        icon: Icons.check_circle_rounded,
      );
    case NotificationType.error:
      return const _NotificationStyle(
        accentColor: Color(0xFFC62828),
        borderColor: Color(0xFFEF9A9A),
        shadowColor: Color(0xFFC62828),
        icon: Icons.error_rounded,
      );
    case NotificationType.warning:
      return const _NotificationStyle(
        accentColor: Color(0xFFE65100),
        borderColor: Color(0xFFFFCC80),
        shadowColor: Color(0xFFE65100),
        icon: Icons.warning_rounded,
      );
    case NotificationType.info:
      return const _NotificationStyle(
        accentColor: Color(0xFF1565C0),
        borderColor: Color(0xFFBBDEFB),
        shadowColor: Color(0xFF1565C0),
        icon: Icons.info_rounded,
      );
  }
}
