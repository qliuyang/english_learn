import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  static const String routeName = '/about';
  final String githubUrl = 'https://github.com/your-repo/english_learn_flutter';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '关于',
          style: TextStyle(fontSize: 22), // 缩小标题
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // 缩小内边距
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 缩小图片尺寸
              Image.asset(
                'assets/icon/main.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),
              const Text(
                '英语词典',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), // 缩小标题
              ),
              const SizedBox(height: 16),
              const Text(
                '版本: 1.0.0',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text(
                '作者: LiuYang',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '使用框架:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => launchUrl(Uri.parse('https://flutter.dev')),
                    child: const Text(
                      'Flutter',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '项目地址:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => launchUrl(Uri.parse(githubUrl)),
                    child: const Text(
                      'Github',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
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