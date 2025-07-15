import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'chat_screen.dart';

class Onboard {
  final String title;
  final String subtitle;
  final String lottie;

  Onboard({
    required this.title,
    required this.subtitle,
    required this.lottie,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Onboard> pages = [
    Onboard(
      title: 'Meet BotBuddy 🤖',
      subtitle:
      'Your AI Chat Assistant powered by Gemini API for smart replies.',
      lottie: 'chatbot.json',
    ),
    Onboard(
      title: 'Ask Anything Instantly',
      subtitle:
      'From daily doubts to creative ideas, BotBuddy is always here.',
      lottie: 'chat.json',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (ctx, index) {
          final page = pages[index];
          final isLast = index == pages.length - 1;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? size.width * 0.2 : 20,
              vertical: isWide ? 60 : 30,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/${page.lottie}',
                  height: isWide ? size.height * 0.5 : size.height * 0.35,
                ),
                const SizedBox(height: 20),
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWide ? 32 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isWide ? 18 : 14,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  children: List.generate(
                    pages.length,
                        (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: i == _currentPage ? 14 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                        i == _currentPage ? Colors.red : Colors.grey[600],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (isLast) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(),
                        ),
                      );
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const StadiumBorder(),
                    minimumSize: Size(size.width * 0.4, 48),
                  ),
                  child: Text(
                    isLast ? 'Get Started' : 'Next',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}


