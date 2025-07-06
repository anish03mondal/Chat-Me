import 'package:chat_me/main.dart';
import 'package:chat_me/screens/home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    bool isMobile = mq.width < 600;
    bool isTablet = mq.width >= 600 && mq.width < 1024;
    bool isDesktop = mq.width >= 1024;

    if (isMobile) {
      // ✅ Mobile UI (your current one)
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Welcome to Chat Me'),
        ),
        body: Stack(
          children: [
            AnimatedPositioned(
              // works only with stack widget
              top: mq.height * .15,
              right: _isAnimate
                  ? mq.width * .25
                  : -mq.width *
                        .5, //this will move the image from extreme right to center
              width: mq.width * .5,
              duration: Duration(seconds: 1),
              child: Image.asset('images/meetme.png'),
            ),
            Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .07,
              child: ElevatedButton.icon(
                onPressed: () {
                  signInButton(context);
                },
                icon: Image.asset('images/google.png', height: mq.height * .04),
                label: const Text(
                  'Sign with Google',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // ✅ Tablet/Desktop UI
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Welcome to Chat Me'),
          centerTitle: true,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/meetme.png', width: 250),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        signInButton(context);
                      },
                      icon: Image.asset('images/google.png', height: 24),
                      label: const Text(
                        'Sign with Google',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        //backgroundColor: Colors.blueAccent,
                        //foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void signInButton(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }
}
