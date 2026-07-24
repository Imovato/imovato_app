import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/Space.dart';
import 'package:provider/provider.dart';
import '../../../../../app/router.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    // Usar o LoginController do Provider
    final controller = context.read<LoginController>();
    final loginOk = await controller.signIn(email, password);
    if (!mounted) return;

    if (loginOk) {
      final returnRoute = ModalRoute.of(context)?.settings.arguments as String?;
      Navigator.pushReplacementNamed(context, returnRoute ?? Routes.alugar);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(controller.errorMessage ?? 'Credenciais inválidas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(ImovatoSpacing.sm),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Icon(
                      Icons.home_work_rounded,
                      size: 56,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: ImovatoSpacing.md),
                    Text(
                      'Bem-vindo de volta!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: ImovatoSpacing.sm),
                    Text(
                      'Entre na sua conta para continuar.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                    const SizedBox(height: ImovatoSpacing.xl),
                    AutofillGroup(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              hintText: 'voce@email.com',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe seu e-mail';
                              }

                              final ok = RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(v.trim());

                              if (!ok) {
                                return 'E-mail inválido';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: ImovatoSpacing.md),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [
                              AutofillHints.password,
                            ],
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Informe sua senha';
                              }

                              if (v.length < 6) {
                                return 'Mínimo de 6 caracteres';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: ImovatoSpacing.xl),
                          Consumer<LoginController>(
                            builder: (_, controller, __) {
                              return FilledButton.icon(
                                onPressed: controller.loading ? null : _submit,
                                icon: controller.loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(
                                  controller.loading ? 'Entrando...' : 'Entrar',
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: ImovatoSpacing.md),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.cadastro,
                              );
                            },
                            child: const Text(
                              'Ainda não possui uma conta? Cadastre-se',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
