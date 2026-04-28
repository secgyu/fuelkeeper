import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  static const Color background = AppColors.brandPrimary;

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 스플래시 최소 노출 시간을 보장하면서 위치 권한을 함께 처리한다.
    await Future.wait<void>([
      Future.delayed(const Duration(milliseconds: 1100)),
      _ensureLocationPermission(),
    ]);
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  Future<void> _ensureLocationPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    } catch (_) {
      // 권한 거부/오류는 무시한다. 홈에서 위치를 사용할 때 다시 안내한다.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final imageSize = width * 0.55;

    return Scaffold(
      backgroundColor: SplashPage.background,
      body: Stack(
        children: [
          Center(
            child: ClipOval(
              child: Image.asset(
                'assets/icon/splash_logo.png',
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.5),
            child: FadeTransition(
              opacity: _textFade,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FuelKeeper',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '1원도 놓치지 마세요',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color(0xE6FFFFFF),
                    ),
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
