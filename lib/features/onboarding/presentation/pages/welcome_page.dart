import 'package:flutter/material.dart';
import '../../../../../app/router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  final String TEXTO_BOAS_VINDAS = 'Olá, Boas Vindas!';
  final String TEXTO_INICIAL =
      'Faça login para o painel administrativo ou alugue a sua nova casa com a Imovato!';
  final String LABEL_LOGIN = 'Fazer Login';
  final String LABEL_ALUGAR = 'Quero Alugar';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header image com canto inferior arredondado
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(40)),
                child: Image.asset(
                  'images/image-onboarding.jpg', // veja pubspec abaixo
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Títulos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                TEXTO_BOAS_VINDAS,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                TEXTO_INICIAL,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 16),

            // CTAs
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: FilledButton(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.loginMorador),
                child: Text(
                  LABEL_LOGIN,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.alugar),
                child: Text(
                  LABEL_ALUGAR,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
