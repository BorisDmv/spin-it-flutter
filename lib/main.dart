import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spin It',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Spin It'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _bottleAngle = 0.0;
  double _velocity = 0.0;
  bool _isSpinning = false;
  String? _result;
  String? _question;
  bool _showQuestion = false;
  double _bottleScale = 1.0;
  int _player1Score = 0;
  int _player2Score = 0;
  String _bottleAsset = 'assets/bottle1.png';
  List<String> _questions = [];
  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String data = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> jsonResult = json.decode(data);
    setState(() {
      _questions = jsonResult.cast<String>();
    });
  }

  double? _dragStartY;
  double _bottleImageHeight = 250.0;
  double? _screenHeight;
  void _onPanStart(DragStartDetails details) {
    if (_isSpinning) return;
    _velocity = 0.0;
    // Record the Y position where drag started, relative to screen
    final box = context.findRenderObject() as RenderBox?;
    _screenHeight = box?.size.height ?? MediaQuery.of(context).size.height;
    _dragStartY = details.globalPosition.dy;
  }

  // If your bottle image tip points right, this matches natural swipe direction:
  // right swipe = clockwise, left swipe = counterclockwise
  void _onPanUpdate(DragUpdateDetails details) {
    if (_isSpinning) return;
    if (details.delta.dx.abs() > 5) {
      setState(() {
        final screenHeight =
            _screenHeight ?? MediaQuery.of(context).size.height;
        final dragInTopHalf =
            (_dragStartY ?? screenHeight / 2) < screenHeight / 2;
        final direction = dragInTopHalf ? 1 : -1;
        _bottleAngle += direction * details.delta.dx * 0.01;
      });
    }
  }

  // If your bottle image tip points right, this matches natural swipe direction:
  // right swipe = clockwise, left swipe = counterclockwise
  void _onPanEnd(DragEndDetails details) {
    if (_isSpinning) return;
    final screenHeight = _screenHeight ?? MediaQuery.of(context).size.height;
    final dragInTopHalf = (_dragStartY ?? screenHeight / 2) < screenHeight / 2;
    final direction = dragInTopHalf ? 1 : -1;
    double velocity = direction * details.velocity.pixelsPerSecond.dx * 0.0005;
    if (velocity.abs() > 0.01) {
      _startSpin(velocity);
    }
    _dragStartY = null;
    _screenHeight = null;
  }

  void _startSpin(double velocity) async {
    setState(() {
      _isSpinning = true;
      _result = null;
      _question = null;
    });
    double angle = _bottleAngle;
    double v = velocity.abs();
    double friction = 0.98;
    while (v > 0.01) {
      await Future.delayed(const Duration(milliseconds: 16));
      angle += velocity;
      velocity *= friction;
      v = velocity.abs();
      setState(() {
        _bottleAngle = angle;
      });
    }
    _velocity = 0.0; // Reset velocity after spin
    // Animate bottle zoom-in
    setState(() {
      _bottleScale = 1.0;
      _showQuestion = false;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    // Smooth zoom-in animation
    for (double s = 1.0; s < 1.15; s += 0.005) {
      await Future.delayed(const Duration(milliseconds: 6));
      setState(() {
        _bottleScale = s;
      });
    }
    await Future.delayed(const Duration(milliseconds: 400));
    for (double s = 1.15; s > 1.0; s -= 0.005) {
      await Future.delayed(const Duration(milliseconds: 6));
      setState(() {
        _bottleScale = s;
      });
    }
    setState(() {
      _bottleScale = 1.0;
    });
    await Future.delayed(const Duration(milliseconds: 150));
    _onSpinEnd(angle);
  }

  void _onSpinEnd(double angle) {
    // Adjust so angle=0 (tip up) points to Player 2 (top), angle=pi (tip down) points to Player 1 (bottom)
    double normalized = (angle + pi / 2) % (2 * pi);
    String player = (normalized >= 0 && normalized < pi)
        ? 'Player 2'
        : 'Player 1';
    setState(() {
      _isSpinning = false;
      _result = player;
      if (_questions.isNotEmpty) {
        _question = (_questions..shuffle()).first;
      } else {
        _question = "No questions loaded.";
      }
      _showQuestion = true;
    });
  }

  // ...existing code...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0b0214),
      body: SafeArea(
        child: Stack(
          children: [
            // Settings button in top right
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 32),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Choose Bottle Design',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1c0631),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _bottleAsset = 'assets/bottle1.png';
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border:
                                                _bottleAsset ==
                                                    'assets/bottle1.png'
                                                ? Border.all(
                                                    color: Colors.deepPurple,
                                                    width: 3,
                                                  )
                                                : null,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/bottle1.png',
                                            width: 64,
                                            height: 64,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Bottle 1',
                                          style: TextStyle(
                                            color: Color(0xFF1c0631),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _bottleAsset = 'assets/bottle3.png';
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border:
                                                _bottleAsset ==
                                                    'assets/bottle3.png'
                                                ? Border.all(
                                                    color: Colors.deepPurple,
                                                    width: 3,
                                                  )
                                                : null,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/bottle3.png',
                                            width: 64,
                                            height: 64,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Bottle 3',
                                          style: TextStyle(
                                            color: Color(0xFF1c0631),
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
                    },
                  );
                },
              ),
            ),
            Column(
              children: [
                // Player 2 at the top with dark bg and score
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0b0214),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Player 2',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_player2Score',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1c0631),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottle in the center
                Expanded(
                  child: Container(
                    color: const Color(0xFF0b0214),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Spin the Bottle!',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  blurRadius: 16,
                                  color: Color.fromARGB(
                                    (0.7 * 255).round(),
                                    93,
                                    40,
                                    255,
                                  ),
                                  offset: const Offset(0, 0),
                                ),
                                Shadow(
                                  blurRadius: 32,
                                  color: Color.fromARGB(
                                    (0.3 * 255).round(),
                                    255,
                                    255,
                                    255,
                                  ),
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: Transform.scale(
                              scale: _bottleScale,
                              child: Transform.rotate(
                                angle: _bottleAngle,
                                child: Image.asset(
                                  _bottleAsset,
                                  width: _bottleImageHeight,
                                  height: _bottleImageHeight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                // Player 1 at the bottom with dark bg and score
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0b0214),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Player 1',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_player1Score',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1c0631),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Question modal overlay
            if (_result != null && _question != null && _showQuestion)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 16),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_result',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1c0631),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Truth:',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_question',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF1c0631),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Check button
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _result = null;
                                      _question = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(32),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                // Cross button
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      // Give point to the other player
                                      if (_result == 'Player 1') {
                                        _player2Score++;
                                      } else if (_result == 'Player 2') {
                                        _player1Score++;
                                      }
                                      _result = null;
                                      _question = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(32),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
