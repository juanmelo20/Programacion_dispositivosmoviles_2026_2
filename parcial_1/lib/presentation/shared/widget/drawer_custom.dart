import 'package:parcial_1/presentation/presentacion.dart';

class DrawerCustom extends StatelessWidget {
  const DrawerCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Midterm exam',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'teaching',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            ListTile(
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Main screens',
                style: TextStyle(color: Colors.white54),
              ),
              onTap: () => Navigator.pop(context), // ya estamos en Home
            ),
            ListTile(
              title: const Text('User', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'User screen with general personal information',
                style: TextStyle(color: Colors.white54),
              ),
              onTap: () {
                Navigator.pop(context); // cierra el Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}