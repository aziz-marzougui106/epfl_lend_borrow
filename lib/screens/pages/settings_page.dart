// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key,required this.title,});
//   final String title;
 
//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   TextEditingController controller=TextEditingController(text: '');
//   TextEditingController slideController=TextEditingController(text: '');
//   bool? isChecked=false;
//   bool isSwitched=false;
//   double slide=0.0;
//   String? menu='e1';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         automaticallyImplyLeading: false,
//         leading:BackButton(onPressed: (){
//               Navigator.pop(context);
//             }, )
        
//         ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child:Column(
//             children: [
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.max,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ElevatedButton(
//                     onPressed: (){ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior:SnackBarBehavior.floating ,duration:Duration(seconds:5),content: Text("hello loser")));},
//                     style:ElevatedButton.styleFrom(backgroundColor: Colors.teal,foregroundColor: Colors.white),
//                     child: Text('Open SnackBar')
//                   ),
//                   Divider( color: Colors.teal,thickness: 5.0,endIndent: 50.0,),
//                   Container(height:20.0,child: VerticalDivider(),),
//                   FilledButton(
//                       onPressed: (){showDialog(context: context, builder: (context){return AlertDialog(title: Text('AlertDialog'),content: Text('AlertContent'),actions: [FilledButton(onPressed: (){Navigator.pop(context);}, child: Text('close'))],);});},
//                       child: Text('Alert')
//                   ),
//                 ]
//               ),
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: DropdownButton(
//                   value:menu,
//                   items: [DropdownMenuItem(value: 'e1', child: Text('Element1'),),DropdownMenuItem(value: 'e2', child: Text('Element2'),),DropdownMenuItem(value: 'e3', child: Text('Element3'),),], 
//                   onChanged: (String? value){ setState(() {menu=value;});},
//                   focusColor: Colors.transparent,//This is a common Flutter issue! The "always selected" highlight you see
//                 ),
//               ),
//               TextField(
//                 controller:controller,
//                 decoration: InputDecoration(border:OutlineInputBorder()),
//                 onEditingComplete: () => setState(() {}),
//                 //onChanged: (value) => setState(() {}), //when the controller changes the state changes
//               ),
//               Text(controller.text),
//               Checkbox.adaptive(tristate: true, value: isChecked, onChanged: (value) {controller.clear(); setState(() => isChecked=value);}),
//               CheckboxListTile.adaptive(tristate: true,title:Text('click me PLZ'), value: isChecked, onChanged:(value)  {controller.clear();setState(()=> isChecked=value);}),
//               Switch.adaptive( value: isSwitched, onChanged: (value) {controller.clear(); setState(() => isSwitched=value);}),
//               SwitchListTile.adaptive(title:Text('Switch me PLZ'), value: isSwitched, onChanged:(value)  {controller.clear();setState(()=> isSwitched=value);}),
//               Slider.adaptive(min:-5.0,max:10.0 , divisions:20, value:slide, onChanged: (double value){slideController.text= value.toString();setState(() => slide=value);}),//divisions on how much parts the range is divided
//               Text(slideController.text),
//               Text(slide.toStringAsFixed(2)),//2 is the fraction digits
//               GestureDetector(
//                 onTap: () => setState(() {slide=5.0;}),
//                 child: Image.asset('assets/images/alps.png',fit: BoxFit.contain)
//               ),
//               InkWell(
//                 onTap: () {
//                   setState(() {
//                     slide=5.0;
//                   });
//                 },
//                 onDoubleTap: () {
//                   setState(() {
//                     slide=10.0;
//                   });
//                 },
//                 splashColor: Colors.white38,
//                 child:Container(
//                   width:double.infinity,
//                   height: 200,
//                   color: Colors.white24,
//                 )
//               ),
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
                    
                    
//                     TextButton(
//                       onPressed: (){},
//                       child: Text('click me DD')
//                     ),
//                     OutlinedButton(
//                       onPressed: (){},
//                       child: Text('click me DD')
//                     ),
//                     CloseButton(),
//                     BackButton(),
//                   ],
//                 ),
//               ),
      
              
//             ],
//           )
//         ),
//       ),
//     );
//   }
// }


// settings_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import '../../data/notifiers.dart';
import '../../data/constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _matchNotifications = true;
  bool _messageNotifications = true;

  // ── Section header ─────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // ── Settings card ──────────────────────────────────────────
  Widget _settingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ── Settings tile ──────────────────────────────────────────
  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                )
              : null,
          trailing: trailing ??
              (onTap != null
                  ? Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 20,
                    )
                  : null),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: Colors.grey..withValues(alpha: 0.12),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [

          // ── Account ──────────────────────────────────────
          _sectionHeader('Account'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.15),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Stack(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFE2001A),
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2001A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              ),
              title: const Text(
                'EPFL Student',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text(
                'firstname.lastname@epfl.ch',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
              onTap: () {
                // TODO: navigate to edit profile
              },
            ),
          ),

          // ── Appearance ───────────────────────────────────
          _sectionHeader('Appearance'),
          _settingsCard([
            ValueListenableBuilder<bool>(
              valueListenable: isDarkMode,
              builder: (context, isDark, child) {
                return _settingsTile(
                  icon: isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                  iconColor: const Color(0xFFE2001A),
                  title: 'Dark mode',
                  subtitle: isDark ? 'Currently dark' : 'Currently light',
                  showDivider: false,
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeColor: const Color(0xFFE2001A),
                    onChanged: (value) async {
                      isDarkMode.value = value;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(KConstants.themeModeKey, value);
                    },
                  ),
                );
              },
            ),
          ]),

          // ── Notifications ─────────────────────────────────
          _sectionHeader('Notifications'),
          _settingsCard([
            _settingsTile(
              icon: Icons.notifications_outlined,
              iconColor: Colors.orange,
              title: 'Enable notifications',
              subtitle: 'Receive all app notifications',
              trailing: Switch.adaptive(
                value: _notificationsEnabled,
                activeColor: const Color(0xFFE2001A),
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                    if (!value) {
                      _matchNotifications = false;
                      _messageNotifications = false;
                    }
                  });
                },
              ),
            ),
            _settingsTile(
              icon: Icons.auto_awesome_outlined,
              iconColor: Colors.purple,
              title: 'AI match alerts',
              subtitle: 'Notified when AI finds a match',
              trailing: Switch.adaptive(
                value: _matchNotifications && _notificationsEnabled,
                activeColor: const Color(0xFFE2001A),
                onChanged: _notificationsEnabled
                    ? (value) => setState(() => _matchNotifications = value)
                    : null,
              ),
            ),
            _settingsTile(
              icon: Icons.chat_bubble_outline,
              iconColor: Colors.blue,
              title: 'Message alerts',
              subtitle: 'Notified when you get a message',
              showDivider: false,
              trailing: Switch.adaptive(
                value: _messageNotifications && _notificationsEnabled,
                activeColor: const Color(0xFFE2001A),
                onChanged: _notificationsEnabled
                    ? (value) =>
                        setState(() => _messageNotifications = value)
                    : null,
              ),
            ),
          ]),

          // ── About ─────────────────────────────────────────
          _sectionHeader('About'),
          _settingsCard([
            _settingsTile(
              icon: Icons.info_outline,
              iconColor: Colors.teal,
              title: 'Version',
              subtitle: 'LendNBorrow v1.0.0',
              onTap: null,
              trailing: Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
              ),
            ),
            _settingsTile(
              icon: Icons.description_outlined,
              iconColor: Colors.indigo,
              title: 'Terms of service',
              onTap: () {},
            ),
            _settingsTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: Colors.green,
              title: 'Privacy policy',
              onTap: () {},
              showDivider: false,
            ),
          ]),

          // ── Danger zone ───────────────────────────────────
          _sectionHeader('Account actions'),
          _settingsCard([
            _settingsTile(
              icon: Icons.logout,
              iconColor: const Color(0xFFE2001A),
              title: 'Log out',
              showDivider: false,
              trailing: const SizedBox.shrink(),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}