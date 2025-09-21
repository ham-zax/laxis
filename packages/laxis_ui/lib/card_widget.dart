import 'package:flutter/material.dart';
import 'conjugation_widget.dart';
import 'theme/app_theme.dart';

class CardWidget extends StatefulWidget {
  const CardWidget({
    super.key,
    required this.text,
    this.isUsed = false,
    this.elevation,
    this.onTap,
    this.hasConjugation = false,
  });

  final String text;
  final bool isUsed;
  final double? elevation;
  final VoidCallback? onTap;
  final bool hasConjugation; // Language module determines this

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.hasConjugation
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        if (!widget.isUsed) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap ??
                  () {
                    // Only show conjugation if explicitly marked by language module
                    if (widget.hasConjugation) {
                      showDialog(
                        context: context,
                        builder: (context) => const ConjugationWidget(),
                      );
                    }
                  },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isUsed
                      ? Colors.grey[200]
                      : (_isHovered
                          ? AppTheme.primaryBlue.withOpacity(0.05)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isUsed
                        ? Colors.grey[300]!
                        : (_isHovered
                            ? AppTheme.primaryBlue
                            : AppTheme.borderLight),
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: widget.isUsed
                      ? null
                      : [
                          BoxShadow(
                            color: _isHovered
                                ? AppTheme.primaryBlue.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: _isHovered ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.isUsed
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.hasConjugation && !widget.isUsed) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DraggableCardWidget extends StatefulWidget {
  const DraggableCardWidget({
    super.key,
    required this.cardId,
    required this.text,
    this.isUsed = false,
    this.hasConjugation = false,
    this.onDragStarted,
    this.onDragEnd,
  });

  final String cardId;
  final String text;
  final bool isUsed;
  final bool hasConjugation;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  State<DraggableCardWidget> createState() => _DraggableCardWidgetState();
}

class _DraggableCardWidgetState extends State<DraggableCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isUsed) {
      return CardWidget(
        text: widget.text,
        isUsed: true,
        hasConjugation: widget.hasConjugation,
      );
    }

    return MouseRegion(
      cursor:
          _isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Draggable<Map<String, String>>(
            data: {'id': widget.cardId, 'text': widget.text},
            onDragStarted: () {
              setState(() => _isDragging = true);
              _pulseController.stop();
              widget.onDragStarted?.call();
            },
            onDragEnd: (_) {
              setState(() => _isDragging = false);
              widget.onDragEnd?.call();
            },
            feedback: Material(
              elevation: 12.0,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            childWhenDragging: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderMedium,
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: AppTheme.textHint,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child: CardWidget(
              text: widget.text,
              hasConjugation: widget.hasConjugation,
            ),
          );
        },
      ),
    );
  }
}
