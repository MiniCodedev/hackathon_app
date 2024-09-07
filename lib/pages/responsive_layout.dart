import 'package:flutter/material.dart';
import 'package:hackathon_app/pages/home_page.dart';
import 'package:hackathon_app/pages/home_window_page.dart';

import 'package:hackathon_app/widgets/message_tile.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return const HomePage();
      } else {
        return const HomeWindowPage();
      }
    });
  }
}

// class TestHome extends StatelessWidget {
//   const TestHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('TestHome'),
//       ),
//       body: Center(
//         child: MessageTile(
//           isUser: true,
//           message: "HelloWolrd",
//         ),
//       ),
//     );
//   }
// }
