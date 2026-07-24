import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:imovato_app/app/theme/tokens/imovato_spacing.dart';
import '../../../../../app/router.dart';
import 'package:imovato_app/app/theme/tokens/imovato_radius.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const String textoBoasVindas = 'Olá, boas vindas!';
  static const String textoInicial =
      'Acesse o painel ou alugue sua nova casa de forma simples e rápida com a Imovato.';
  static const String labelLogin = 'Fazer Login';
  static const String labelAlugar = 'Quero Alugar';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ImovatoSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    ImovatoBorderRadius.circular(ImovatoBorderRadius.xl),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 360,
                      width: double.infinity,
                      child: Image.asset(
                        'images/image-onboarding.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.02),
                              Colors.black.withValues(alpha: 0.42),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: ImovatoSpacing.xl,
                      bottom: ImovatoSpacing.xl,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: ImovatoBorderRadius.circular(
                              ImovatoBorderRadius.lg),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'images/imovato.svg',
                          width: 128,
                          height: 128,
                          semanticsLabel: 'Logo da Imovato',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                textoBoasVindas,
                style: textTheme.headlineLarge?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                textoInicial,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: ImovatoSpacing.md),
              FilledButton(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.loginMorador),
                child: Text(labelLogin),
              ),
              const SizedBox(height: ImovatoSpacing.sm),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.alugar),
                child: Text(labelAlugar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
