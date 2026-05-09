import 'package:epfl_lend_borrow/data/constants.dart';
import 'package:epfl_lend_borrow/data/notifiers.dart';
import 'package:epfl_lend_borrow/screens/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/notifiers.dart';
import '../../data/constants.dart';
import 'main_page.dart';
import 'dashboard_page.dart';
import 'chat_page.dart';
import 'post_item_page.dart';
import 'settings_page.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  // Pages mapped to bottom nav indices
  static const List<Widget> _pages = [
    MainPage(),
    DashboardPage(),
    ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    //final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedIndex, child) {
        return Scaffold(
          //key: scaffoldKey,
          // ── AppBar ────────────────────────────────────────
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leadingWidth: 120,
            leading: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black87),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                Image.asset(
                  'assets/images/epfl.png',
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            title: ValueListenableBuilder<int>(
              valueListenable: selectedPageNotifier,
              builder: (context, index, child) {
                const titles = ['Home', 'Browse', 'Chat'];
                return Text(
                  titles[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                onPressed: () {},
              ),
            ],
          ),
          // ── Body ──────────────────────────────────────────
          body: IndexedStack(
            index: selectedIndex,
            children: _pages,
          ),

          // ── Bottom nav ────────────────────────────────────
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              selectedPageNotifier.value = index;
            },
            indicatorColor: const Color(0xFFE2001A).withValues(alpha: 0.15),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFE2001A),
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFFE2001A),
                ),
                label: 'Browse',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(
                  Icons.chat_bubble,
                  color: Color(0xFFE2001A),
                ),
                label: 'Chat',
              ),
            ],
          ),

          // ── Drawer ────────────────────────────────────────
          drawer: Drawer(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drawer header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: const Color(0xFFE2001A),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'EPFL Student',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'firstname.lastname@epfl.ch',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Post item
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Post an item'),
                    subtitle: const Text('Sell or lend something'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PostItemPage(),
                        ),
                      );
                    },
                  ),

                  const Divider(indent: 16, endIndent: 16),

                  // Settings
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    subtitle: const Text('Preferences, dark mode'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),

                  // Dark mode toggle — quick access
                  ValueListenableBuilder<bool>(
                    valueListenable: isDarkMode,
                    builder: (context, isDark, child) {
                      return ListTile(
                        leading: Icon(
                          isDark
                              ? Icons.dark_mode
                              : Icons.light_mode_outlined,
                        ),
                        title: const Text('Dark mode'),
                        trailing: Switch.adaptive(
                          value: isDark,
                          activeColor: const Color(0xFFE2001A),
                          onChanged: (value) async {
                            isDarkMode.value = value;
                            final prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool(
                              KConstants.themeModeKey,
                              value,
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  const Divider(indent: 16, endIndent: 16),

                  // Logout
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Color(0xFFE2001A),
                    ),
                    title: const Text(
                      'Log out',
                      style: TextStyle(color: Color(0xFFE2001A)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}