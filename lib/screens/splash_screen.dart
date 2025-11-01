import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class AppColors {
  static const Color primary = Color(0xFFFF6600); 
}

class Routes {
  static const String HOME = '/home'; 
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  
  double _newneekTop = -200.0;
  double _newneekTargetTop = 0.0; 
  double _hedgehogRight = -400.0;
  double _hedgehogTargetRight = -100.0; 
  
  @override 
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimationSequence();
    });
  }

  Future<void> _startAnimationSequence() async {
    final screenHeight = MediaQuery.of(context).size.height;
    
    _newneekTargetTop = screenHeight / 2 - 120; 

    setState(() {
      _newneekTop = _newneekTargetTop; 
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() { _newneekTop -= 70; });
    await Future.delayed(const Duration(milliseconds: 180)); 
    
    setState(() { _newneekTop = _newneekTargetTop; });
    await Future.delayed(const Duration(milliseconds: 180)); 

    setState(() { _newneekTop -= 35; });
    await Future.delayed(const Duration(milliseconds: 120));

    setState(() { _newneekTop = _newneekTargetTop; });
    await Future.delayed(const Duration(milliseconds: 120));

    setState(() { _newneekTop -= 10; });
    await Future.delayed(const Duration(milliseconds: 70));

    setState(() { _newneekTop = _newneekTargetTop; });
    await Future.delayed(const Duration(milliseconds: 70));

    setState(() { _newneekTop -= 3; });
    await Future.delayed(const Duration(milliseconds: 50));

    setState(() { _newneekTop = _newneekTargetTop; });
    await Future.delayed(const Duration(milliseconds: 50));
 
    setState(() {
      _hedgehogRight = _hedgehogTargetRight; 
    });

    await Future.delayed(const Duration(milliseconds: 800));

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Get.offAllNamed(Routes.HOME);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double staticTextStartTop = screenHeight / 2 - 45; 

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1500), 
            curve: Curves.decelerate, 
            top: _newneekTop, 
            
            child: const Text(
              'NEWNEEK',
              style: TextStyle(
                color: Colors.black,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
              ),
            ),
          ),

          Positioned(
            top: staticTextStartTop, 
            child: const Text(
              'TODAY',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Positioned(
            top: staticTextStartTop + 35, 
            child: const Chip(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              label: Text(
                "Let's check out our latest news!", 
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 800), 
            curve: Curves.easeOutCubic, 
            bottom: -80, 
            right: _hedgehogRight, 
            child: Transform.rotate(
              angle: -5 * pi / 180, 
              child: SizedBox( 
                width: 400, 
                height: 400,
                child: SvgPicture.asset( 
                  'assets/gosum_ori.svg', 
                  fit: BoxFit.contain, 
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}