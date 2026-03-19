import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/router.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      builder: (context, loginCtrl, _) {
        // Se não está logado, não mostra nada
        if (!loginCtrl.isLoggedIn) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              loginCtrl.logout();
              // Redirecionar para a tela inicial
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.welcome,
                (route) => false,
              );
            } else if (value == 'profile') {
              // TODO: Navegar para página de perfil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil (em construção)')),
              );
            } else if (value == 'reservas') {
              Navigator.of(context).pushNamed(Routes.myReservations);
            } else if (value == 'convites') {
              Navigator.of(context).pushNamed(Routes.pendingInvites);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 12),
                  Text(loginCtrl.userName ?? 'Perfil'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'reservas',
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 12),
                  const Text('Minhas reservas'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'convites',
              child: Row(
                children: [
                  const Icon(Icons.mail_outline, size: 20),
                  const SizedBox(width: 12),
                  const Text('Convites pendentes'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout, size: 20, color: Colors.red),
                  const SizedBox(width: 12),
                  const Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    (loginCtrl.userName?.isNotEmpty ?? false)
                        ? loginCtrl.userName!.substring(0, 1).toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

