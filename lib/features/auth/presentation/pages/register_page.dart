import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imovato_app/app/theme/Space.dart';
import 'package:provider/provider.dart';
import '../controllers/register_controller.dart';
import '../../../../../app/router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _idCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _obscure = true;
  final String _type = 'ROLE_GUEST'; // 'ROLE_HOST' | 'ROLE_GUEST'

  @override
  void dispose() {
    _idCtrl.dispose();
    _userNameCtrl.dispose();
    _passwordCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe seu e-mail';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
    return ok ? null : 'E-mail inválido';
  }

  String? _validateCPF(String? v) {
    final txt = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (txt.isEmpty) return 'Informe o CPF';
    if (txt.length != 11) return 'CPF deve ter 11 dígitos';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<RegisterController>();
    final ok = await controller.signUp(
      id: _idCtrl.text.trim().isEmpty ? null : _idCtrl.text.trim(),
      userName: _userNameCtrl.text.trim(),
      password: _passwordCtrl.text,
      cpf: _cpfCtrl.text.replaceAll(RegExp(r'\D'), ''),
      email: _emailCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      type: _type,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
      Navigator.pop(context); // volta para a tela de login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar conta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
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
                      'Bem-vindo!',
                      style: theme.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ImovatoSpacing.sm),
                    Text(
                      'Crie sua conta para começar a utilizar o Imovato.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ImovatoSpacing.xl),
                    AutofillGroup(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            autofillHints: const [
                              AutofillHints.name,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Nome completo',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Informe seu nome'
                                : null,
                          ),
                          const SizedBox(height: ImovatoSpacing.md),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [
                              AutofillHints.email,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              hintText: 'voce@email.com',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: ImovatoSpacing.md),
                          TextFormField(
                            controller: _cpfCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'CPF',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: _validateCPF,
                          ),
                          const SizedBox(height: ImovatoSpacing.md),
                          TextFormField(
                            controller: _userNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Usuário',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                          ),
                          const SizedBox(height: ImovatoSpacing.md),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            autofillHints: const [
                              AutofillHints.newPassword,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Informe a senha';
                              if (v.length < 6) return 'Mínimo de 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: ImovatoSpacing.xl),
                          Consumer<RegisterController>(
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
                                    : const Icon(Icons.person_add),
                                label: Text(
                                  controller.loading
                                      ? 'Criando conta...'
                                      : 'Cadastrar',
                                ),
                              );
                            },
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
