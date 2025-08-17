import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/HomePage.dart';
import 'pages/UserPage.dart';
import 'pages/SearchPage.dart';
import 'pages/MusicPage.dart';
import 'services/MusicService.dart';
import "pages/MusicPlayerPage.dart";
import 'pages/LearnHistoryPage.dart';
import 'pages/CollectionPage.dart';
import 'pages/AboutPage.dart';
import 'pages/SettingPage.dart';
import 'pages/CalenderPage.dart';
import "services/NotificationService.dart";
import 'services/CheckInReminderService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化通知服务
  await NotificationService().init();
  
  // 初始化签到提醒服务
  await CheckInReminderService().initialize();
  
  // 检查是否需要发送签到提醒
  await CheckInReminderService().showCheckInReminder();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => MusicPlayerService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '英语词典',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
      routes: {
        HomePage.routeName: (context) => const HomePage(),
        SearchPage.routeName: (context) {
          final word = ModalRoute.of(context)?.settings.arguments as String?;
          return SearchPage(word: word);
        },
        MusicPage.routeName: (context) {
          final musicName =
              ModalRoute.of(context)?.settings.arguments as String?;
          return MusicPage(musicName: musicName);
        },
        UserPage.routeName: (context) => const UserPage(),
        Learnhistorypage.routeName: (context) => const Learnhistorypage(),
        CalenderPage.routeName: (context) => const CalenderPage(),
        CollectionPage.routeName: (context) => const CollectionPage(),
        AboutPage.routeName: (context) => const AboutPage(),
        SettingPage.routeName: (context) => const SettingPage(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _rotationController;

  static const List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    MusicPage(),
    UserPage(),
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  bool _shouldShowMiniPlayer(
    MusicPlayerService playerService,
    BuildContext context,
  ) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    return currentRoute != '/musicPlayer' &&
        playerService.currentAudioUrl != null;
  }

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<MusicPlayerService>(context);

    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_shouldShowMiniPlayer(playerService, context))
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: MiniPlayer(
                playerService: playerService,
                rotationController: _rotationController,
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '主页'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索'),
        BottomNavigationBarItem(icon: Icon(Icons.music_note), label: '音乐'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '用户'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.lightBlue,
      unselectedItemColor: Colors.black,
      onTap: _onItemTapped,
    );
  }
}

class MiniPlayer extends StatelessWidget {
  final MusicPlayerService playerService;
  final AnimationController rotationController;

  const MiniPlayer({
    super.key,
    required this.playerService,
    required this.rotationController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToPlayer(context),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildAlbumCover(),
              const SizedBox(width: 8),
              _buildSongInfo(),
              _buildControlButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumCover() {
    return StreamBuilder<bool>(
      stream: playerService.isPlayingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        if (isPlaying) {
          rotationController.repeat();
        } else {
          rotationController.stop();
        }

        return RotationTransition(
          turns: rotationController,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  playerService.currentMusicData?.cover ?? '无封面',
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            playerService.currentMusicData?.song ?? '未知歌曲',
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            playerService.currentMusicData?.singer ?? '未知歌手',
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<bool>(
          stream: playerService.isPlayingStream,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data ?? false;
            return IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () =>
                  playerService.togglePlay(),
            );
          },
        ),
      ],
    );
  }

  void _navigateToPlayer(BuildContext context) {
    if (playerService.currentMusicData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MusicPlayerPage(musicData: playerService.currentMusicData!),
        ),
      );
    }
  }
}
