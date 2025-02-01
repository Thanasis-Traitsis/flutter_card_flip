import 'package:card_rotation/card/back_card.dart';
import 'package:card_rotation/card/front_card.dart';
import 'package:flutter/material.dart';
import 'dart:math' show pi;

class CardContainer extends StatefulWidget {
  const CardContainer({super.key});

  @override
  State<CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends State<CardContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardFlipController;
  late Animation<double> _cardFlipAnimation;
  bool isFront = true;

  @override
  void initState() {
    super.initState();

    _cardFlipController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _cardFlipAnimation = Tween(
      begin: 0.0,
      end: pi,
    ).animate(_cardFlipController);

    _cardFlipController.addListener(() {
      if (_cardFlipController.value >= 0.5 && isFront) {
        setState(() {
          isFront = false;
        });
      } else if (_cardFlipController.value < 0.5 && !isFront) {
        setState(() {
          isFront = true;
        });
      }
    });

    // Measure the heights after the first layout phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      measureHeights();
    });
  }

  final GlobalKey _frontCardKey = GlobalKey(); // GlobalKey for FrontCard
  final GlobalKey _backCardKey = GlobalKey(); // GlobalKey for BackCard

  late double frontCardHeight;
  late double backCardHeight;
  double? maxHeight;

  @override
  void dispose() {
    _cardFlipController.dispose();
    super.dispose();
  }

  // Function to measure heights of FrontCard and BackCard
  void measureHeights() {
    final frontRenderBox =
        _frontCardKey.currentContext?.findRenderObject() as RenderBox?;
    final backRenderBox =
        _backCardKey.currentContext?.findRenderObject() as RenderBox?;

    if (frontRenderBox != null && backRenderBox != null) {
      setState(() {
        frontCardHeight = frontRenderBox.size.height;
        backCardHeight = backRenderBox.size.height;
        maxHeight =
            frontCardHeight > backCardHeight ? frontCardHeight : backCardHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Offstage(
          child: FrontCard(
            key: _frontCardKey, // Attach the GlobalKey here
          ),
        ),
        Offstage(
          child: BackCard(
            key: _backCardKey, // Attach the GlobalKey here
          ),
        ),
        SizedBox(
          height: maxHeight,
          child: GestureDetector(
            onTap: () {
              if (isFront) {
                _cardFlipController.forward();
              } else {
                _cardFlipController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: _cardFlipAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateY(
                      _cardFlipAnimation.value,
                    ),
                  child: child,
                );
              },
              child: isFront
                  ? FrontCard()
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(pi),
                      child: BackCard(),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
