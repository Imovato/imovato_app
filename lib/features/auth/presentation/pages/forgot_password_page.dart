import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/tokens/imovato_radius.dart';
import 'package:imovato_app/app/theme/tokens/imovato_spacing.dart';
import 'package:provider/provider.dart';
import '../../../../../app/router.dart';
import '../controllers/password_reset_controller.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _tokenRequested = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe seu e-mail';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
    return ok ? null : 'E-mail inválido';
  }

  Future<void> _requestToken() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<PasswordResetController>();
    final ok = await controller.requestReset(_emailCtrl.text.trim());
    if (!mounted) return;

    if (ok) {
      setState(() {
        _tokenRequested = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.infoMessage ?? 'Token gerado.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Falha ao solicitar token.')),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não conferem.')),
      );
      return;
    }

    final controller = context.read<PasswordResetController>();
    final ok = await controller.resetPassword(
      email: _emailCtrl.text.trim(),
      resetToken: _tokenCtrl.text.trim(),
      newPassword: _newPasswordCtrl.text,
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.infoMessage ?? 'Senha atualizada.')),
      );
      Navigator.pushReplacementNamed(context, Routes.loginMorador);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Falha ao redefinir senha.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar senha'),
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
                    ClipRRect(
                      borderRadius: ImovatoBorderRadius.circular(
                        ImovatoBorderRadius.xl,
                      ),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary.withValues(alpha: 0.9),
                              scheme.tertiary.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              right: -30,
                              top: -30,
                              child: Icon(
                                Icons.lock_reset_rounded,
                                size: 170,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(ImovatoSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Esqueceu a senha?',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: ImovatoSpacing.xs),
                                  Text(
                                    'Peça um token de recuperação e defina uma nova senha.',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: ImovatoSpacing.xl),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'voce@email.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: ImovatoSpacing.md),
                    if (_tokenRequested) ...[
                      TextFormField(
                        controller: _tokenCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Token de recuperação',
                          prefixIcon: Icon(Icons.verified_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Informe o token';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: ImovatoSpacing.md),
                      TextFormField(
                        controller: _newPasswordCtrl,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: 'Nova senha',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Informe a nova senha';
                          }
                          if (v.length < 6) {
                            return 'Mínimo de 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: ImovatoSpacing.md),
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar nova senha',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Confirme a senha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: ImovatoSpacing.lg),
                    ],
                    Consumer<PasswordResetController>(
                      builder: (_, controller, __) {
                        return FilledButton.icon(
                          onPressed: controller.loading
                              ? null
                              : (_tokenRequested ? _resetPassword : _requestToken),
                          icon: controller.loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _tokenRequested
                                      ? Icons.lock_reset_rounded
                                      : Icons.send_rounded,
                                ),
                          label: Text(
                            controller.loading
                                ? 'Processando...'
                                : (_tokenRequested
                                    ? 'Redefinir senha'
                                    : 'Solicitar token'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: ImovatoSpacing.sm),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        Routes.loginMorador,
                      ),
                      child: const Text('Voltar para o login'),
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
