import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../widgets/common/voltera_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'AI-Powered EV Charging\nFor Two-Wheelers',
      'subtitle': 'Smart battery health, range prediction & optimized charging stations.',
      'tag': 'AI Station Finder & Battery Care',
    },
    {
      'title': 'Real-Time Station\nFinder & Booking',
      'subtitle': 'Locate nearby DC/AC chargers and reserve slots instantly.',
      'tag': 'Live Availability & 1-Tap Booking',
    },
    {
      'title': 'Seamless Payments &\nSmart Analytics',
      'subtitle': 'Pay securely with UPI, track energy consumption & manage your wallet.',
      'tag': 'Instant UPI Pay & Usage Reports',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingIllustrationView(
                    pageIndex: index,
                    tagText: _onboardingData[index]['tag']!,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicators
                  Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 2 ? 8.0 : 0.0),
                          height: 5,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primaryDarkGreen
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  // Title
                  Text(
                    _onboardingData[_currentPage]['title']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtitle
                  Text(
                    _onboardingData[_currentPage]['subtitle']!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  VolteraButton(
                    text: _currentPage == 2 ? 'Get Started →' : 'Next Step →',
                    onPressed: _onNextPressed,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingIllustrationView extends StatelessWidget {
  final int pageIndex;
  final String tagText;

  const _OnboardingIllustrationView({
    required this.pageIndex,
    required this.tagText,
  });

  @override
  Widget build(BuildContext context) {
    IconData mainIcon;
    Color badgeColor;
    String featureHighlight;

    switch (pageIndex) {
      case 0:
        mainIcon = Icons.bolt_rounded;
        badgeColor = AppColors.secondaryGreen;
        featureHighlight = '98% Battery Health Optimization';
        break;
      case 1:
        mainIcon = Icons.ev_station_rounded;
        badgeColor = const Color(0xFFE89B38);
        featureHighlight = '120+ Verified Hubs Nearby';
        break;
      case 2:
      default:
        mainIcon = Icons.account_balance_wallet_rounded;
        badgeColor = Colors.blueAccent;
        featureHighlight = 'Instant Cashback & UPI Pay';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontalPadding),
      child: Center(
        child: Container(
          width: double.infinity,
          height: 340,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background glow circle
              Positioned(
                top: 40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarkGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: badgeColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      mainIcon,
                      size: 64,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: AppColors.primaryDarkGreen, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          featureHighlight,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tagText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
