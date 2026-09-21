import 'package:parcial_1/presentation/presentacion.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: const Color(0xFF1E1E1E),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage(
                      'assets/images/juan_carlos_foto_fondo_blanco.png',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Juan Carlos Melo Perez',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Systems Engineer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(
                              Icons.email_outlined,
                              color: Colors.white54,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'jcmelop@ufpso.edu.co',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(
                              Icons.phone_outlined,
                              color: Colors.white54,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '3224680003',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HobbyWidget(
                  title: 'My Hobbies',
                  icon: Icons.music_note,
                  items: const ['Music', 'Football', 'TV'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HobbyWidget(
                  title: 'My Tastes',
                  icon: Icons.favorite_border,
                  items: const [
                    'I like traveling',
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'My Activities',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24),
          const ActivityWidget(icon: Icons.work_outline, label: 'Working'),
          const ActivityWidget(icon: Icons.sports_esports, label: 'Playing'),
          const ActivityWidget(icon: Icons.restaurant, label: 'Eating'),
          const ActivityWidget(
            icon: Icons.directions_run,
            label: 'Playing sports',
          ),
          const ActivityWidget(icon: Icons.menu_book, label: 'Studying'),
        ],
      ),
    );
  }
}