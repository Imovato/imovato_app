import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/tokens/imovato_radius.dart';
import 'package:imovato_app/app/theme/tokens/imovato_spacing.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../auth/presentation/controllers/login_controller.dart';
import '../../../../shared/widgets/appBar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final login = context.watch<LoginController>();

    if (!login.isLoggedIn) {
      return Scaffold(
        appBar: const ImovatoAppBar(title: 'Perfil', showBack: false),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_circle_outlined,
                    size: 80, color: scheme.primary),
                const SizedBox(height: 20),
                Text('Entre para acompanhar suas reservas',
                    style: textTheme.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: ImovatoSpacing.xs),
                Text(
                  'Sua conta também mantém suas informações de locação organizadas.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ImovatoSpacing.md),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    Routes.loginMorador,
                    arguments: Routes.profile,
                  ),
                  child: const Text('Fazer login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final name = login.userName ?? 'Usuário';
    return Scaffold(
      appBar: const ImovatoAppBar(title: 'Perfil', showBack: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius:
                  ImovatoBorderRadius.circular(ImovatoBorderRadius.xl),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.primary,
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: textTheme.titleLarge),
                      const SizedBox(height: ImovatoSpacing.xxs),
                      Text(login.userEmail ?? '',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _ProfileAction(
            icon: Icons.calendar_month_outlined,
            title: 'Minhas reservas',
            subtitle: 'Acompanhe seus contratos e pagamentos',
            onTap: () => Navigator.pushNamed(context, Routes.myReservations),
          ),
          _ProfileAction(
            icon: Icons.group_outlined,
            title: 'Convites pendentes',
            subtitle: 'Veja convites para reservas compartilhadas',
            onTap: () => Navigator.pushNamed(context, Routes.pendingInvites),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              login.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.welcome,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: scheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
