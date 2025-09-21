import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'gamification_widgets.dart';

class GameHeader extends StatelessWidget {
  final String userName;
  final int currentStreak;
  final int xp;
  final int targetXP;
  final int level;
  final String levelTitle;
  final double levelProgress;
  final int hearts;
  final VoidCallback? onProfileTap;
  final VoidCallback? onShopTap;

  const GameHeader({
    super.key,
    required this.userName,
    this.currentStreak = 0,
    this.xp = 0,
    this.targetXP = 100,
    this.level = 1,
    this.levelTitle = 'Beginner',
    this.levelProgress = 0.0,
    this.hearts = 5,
    this.onProfileTap,
    this.onShopTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryGreen,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Row - User Info and Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User Profile Section
                Expanded(
                  child: GestureDetector(
                    onTap: onProfileTap,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $userName!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Keep up the great work!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats Row
                Row(
                  children: [
                    // Hearts
                    HeartCounter(hearts: hearts),
                    const SizedBox(width: 16),
                    // Streak
                    StreakCounter(
                      streak: currentStreak,
                      isActive: currentStreak > 0,
                    ),
                    const SizedBox(width: 12),
                    // Shop Button
                    GestureDetector(
                      onTap: onShopTap,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.diamond_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Level Progress Section
            Row(
              children: [
                // Level Badge
                LevelBadge(
                  level: level,
                  title: levelTitle,
                  progress: levelProgress,
                ),

                const SizedBox(width: 16),

                // XP Progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level $level Progress',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          XPBadge(
                            xp: xp,
                            targetXP: targetXP,
                            showProgress: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (xp / targetXP).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${targetXP - xp} XP to next level',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LessonProgressHeader extends StatelessWidget {
  final String lessonTitle;
  final int currentQuestion;
  final int totalQuestions;
  final VoidCallback? onBack;
  final VoidCallback? onPause;

  const LessonProgressHeader({
    super.key,
    required this.lessonTitle,
    required this.currentQuestion,
    required this.totalQuestions,
    this.onBack,
    this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalQuestions > 0 ? currentQuestion / totalQuestions : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Row - Back button and lesson info
            Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lessonTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        'Question $currentQuestion of $totalQuestions',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onPause,
                  icon: const Icon(Icons.pause),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress Bar
            ProgressBar(
              progress: progress,
              height: 6,
              color: AppTheme.primaryGreen,
              showAnimation: false,
            ),
          ],
        ),
      ),
    );
  }
}