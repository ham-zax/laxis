import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
// import '../widgets/gamification_widgets.dart';
import '../widgets/layout.dart';
import '../screens/game_screen_overhauled.dart';

class LevelSelectionScreenOverhauled extends StatefulWidget {
  const LevelSelectionScreenOverhauled({super.key});

  @override
  State<LevelSelectionScreenOverhauled> createState() =>
      _LevelSelectionScreenOverhauledState();
}

class _LevelSelectionScreenOverhauledState
    extends State<LevelSelectionScreenOverhauled>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Minimal Header Section (solid, no gamification)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'German Courses',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: CenteredContent(
                    maxWidth: 1100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Text(
                          'Choose Your Path',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Select a difficulty level to start learning German',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),

                        const SizedBox(height: 24),

                        // Level Cards
                        SectionCard(
                          child: _buildLevelCard(
                            context,
                            title: 'A1: Foundations',
                            description: 'Perfect for absolute beginners',
                            subtitle: 'Basic words and phrases',
                            progress: 0.8,
                            isRecommended: false,
                            isCompleted: true,
                            color: AppTheme.primaryGreen,
                            icon: Icons.apartment,
                            onTap: () => _navigateToLevel(context, 'a1'),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SectionCard(
                          child: _buildLevelCard(
                            context,
                            title: 'A2: Advancement',
                            description: 'Build on your foundation',
                            subtitle: 'Simple conversations',
                            progress: 0.3,
                            isRecommended: true,
                            isCompleted: false,
                            color: AppTheme.primaryBlue,
                            icon: Icons.trending_up,
                            onTap: () => _navigateToLevel(context, 'a2'),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SectionCard(
                          child: _buildLevelCard(
                            context,
                            title: 'B1: Intermediate',
                            description: 'Express yourself confidently',
                            subtitle: 'Complex grammar & vocabulary',
                            progress: 0.0,
                            isRecommended: false,
                            isCompleted: false,
                            color: Colors.grey[400]!,
                            icon: Icons.psychology,
                            onTap: null, // Locked
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Minimal footer spacing
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required String title,
    required String description,
    required String subtitle,
    required double progress,
    required bool isRecommended,
    required bool isCompleted,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isLocked = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isRecommended
              ? Border.all(color: AppTheme.accentOrange, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon Section
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey[300] : color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: isLocked ? Colors.grey[500] : Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isLocked
                                          ? Colors.grey[500]
                                          : AppTheme.textPrimary,
                                    ),
                              ),
                            ),
                            if (isCompleted)
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.successGreen,
                                size: 20,
                              ),
                            if (isLocked)
                              Icon(
                                Icons.lock,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isLocked
                                        ? Colors.grey[400]
                                        : AppTheme.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        if (!isLocked) ...[
                          // Minimal inline progress bar (no gradients)
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            progress > 0
                                ? '${(progress * 100).round()}% complete'
                                : subtitle,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textHint,
                                    ),
                          ),
                        ] else
                          Text(
                            'Complete previous levels to unlock',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[400],
                                    ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Recommended Badge
            if (isRecommended)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentOrange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Recommended',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToLevel(BuildContext context, String level) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreenOverhauled(level: level),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}