import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/spa_theme.dart';
import '../widgets/spa_photo_carousel.dart';

class MainPageBody extends StatelessWidget {
  /// Callback to switch the active tab in AppScaffold.
  final void Function(int index) onNavigate;

  const MainPageBody({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPc = screenWidth > 800;

    Widget content = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      children: [
        _buildWelcomeSection(),
        const SizedBox(height: 24),
        // --- Alternating left / right spa photos ---
        const SpaPhotoStrip(),
        _buildDivider(),
        _buildNavigationLinks(),
        _buildDivider(),
        const AdsCarousel(),
        const SizedBox(height: 24),
        _buildContactFooter(),
        const SizedBox(height: 16),
      ],
    );

    if (isPc) {
      content = Center(
        child: SizedBox(
          width: 750,
          child: content,
        ),
      );
    }

    return Container(
      color: SpaColors.sand,
      child: content,
    );
  }

  // --- Welcome Section ---
  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Icon(Icons.nature, color: SpaColors.terracotta, size: 40),
        const SizedBox(height: 16),
        Text(
          'Welcome to Oasis Spa, surrounded by palms within Theo Sunset Bay Hotel.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: SpaColors.terracotta,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SpaColors.warmBeige,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Discover a wide variety of treatments created to relax the body '
            'and refresh the mind. Choose from soothing full-body massages, '
            'revitalising body scrubs, and gentle face massages designed to '
            'restore your natural glow. Enhance your experience with our '
            'nourishing jelly face masks for deep hydration and radiance. '
            'Guests can also unwind in our sauna and steam bath, or enjoy '
            'access to our indoor swimming pool—the perfect complement to '
            'your spa journey.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 16,
              color: SpaColors.deepBrown,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- Navigation Links (matches the drawer menu) ---
  Widget _buildNavigationLinks() {
    // These mirror the drawer items in app_scaffold.dart
    final items = [
      _NavItem('Menu', Icons.menu_book, 1),
      _NavItem('Book With Us', Icons.calendar_today, 2),
      _NavItem('Oasis Spa - Policies & Etiquette', Icons.yard, 3),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _CustomNavButton(
            title: items[i].title,
            icon: items[i].icon,
            color: SpaColors.terracotta,
            onTap: () => onNavigate(items[i].pageIndex),
          ),
        ],
      ],
    );
  }

  // --- Contact & Footer ---
  Widget _buildContactFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SpaColors.terracotta.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.access_time_rounded,
              color: SpaColors.terracotta, size: 28),
          const SizedBox(height: 8),
          Text(
            'Hours:10 A.M - 6 P.M',
            style: TextStyle(
                fontSize: 16,
                color: SpaColors.terracotta,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Icon(Icons.email_outlined, color: SpaColors.terracotta, size: 28),
          const SizedBox(height: 8),
          Text(
            'Email: Oasistheospa@gmail.com',
            style: TextStyle(
                fontSize: 16,
                color: SpaColors.terracotta,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final Uri url = Uri.parse(
                'https://www.google.com/maps/place/Oasis+spa/@34.8289465,32.3911101,17z/data=!3m1!4b1!4m6!3m5!1s0x14e7090018c58281:0xe46a76dace31a34a!8m2!3d34.8289465!4d32.3911101!16s%2Fg%2F11z9q_4dgc!18m1!1e1?entry=ttu&g_ep=EgoyMDI2MDUxNy4wIKXMDSoASAFQAw%3D%3D',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            icon: const Icon(Icons.location_on, color: Colors.white),
            label: const Text('View Location on Google Maps',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: SpaColors.terracotta,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco,
              size: 16,
              color: SpaColors.terracotta.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Icon(Icons.eco,
              size: 24,
              color: SpaColors.terracotta.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Icon(Icons.eco,
              size: 16,
              color: SpaColors.terracotta.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

/// Simple data class for a navigation item.
class _NavItem {
  final String title;
  final IconData icon;
  final int pageIndex;
  const _NavItem(this.title, this.icon, this.pageIndex);
}

/// Reusable nav button that triggers a page switch.
class _CustomNavButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CustomNavButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: color,
      ),
    );
  }
}

/// A compact, auto-playing carousel to display ad banners on the main page.
class AdsCarousel extends StatefulWidget {
  const AdsCarousel({super.key});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final Timer _timer;

  final List<String> _adImages = [
    'lib/add_carusel/green.jpg',
    'lib/add_carusel/orange.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _adImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPc = screenWidth > 800;
    final carouselHeight = isPc ? 450.0 : 300.0;
    final carouselWidth = isPc ? 253.0 : 169.0; // 450 * 941 / 1672 ≈ 253.2

    return Center(
      child: Container(
        height: carouselHeight,
        width: carouselWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: SpaColors.terracotta.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _adImages.length,
                itemBuilder: (context, index) {
                  final imagePath = _adImages[index];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(16),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Center(
                                  child: InteractiveViewer(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        imagePath,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain, // ensure the whole image is visible
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_adImages.length, (index) {
                    final isSelected = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: isSelected ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SpaColors.terracotta
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
