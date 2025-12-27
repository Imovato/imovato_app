import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/register_controller.dart';

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
  String _type = 'ROLE_GUEST'; // 'ROLE_HOST' | 'ROLE_GUEST'

  final _controller = RegisterController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _userNameCtrl.dispose();
    _passwordCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _controller.dispose();
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

    final ok = await _controller.signUp(
      id: _idCtrl.text.trim().isEmpty ? null : _idCtrl.text.trim(),
      userName: _userNameCtrl.text.trim(),
      password: _passwordCtrl.text,
      cpf: _cpfCtrl.text.replaceAll(RegExp(r'\D'), ''),
      email: _emailCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      type: 'ROLE_GUEST',
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
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'Bem-vindo! 🎉',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Preencha os dados abaixo para criar sua conta.',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),

                // nome
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 16),

                // email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'voce@email.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),

                // CPF
                TextFormField(
                  controller: _cpfCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    hintText: 'Somente números',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateCPF,
                ),
                const SizedBox(height: 16),

                // userName
                TextFormField(
                  controller: _userNameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    hintText: 'seu_usuario',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o usuário' : null,
                ),
                const SizedBox(height: 16),

                // password
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha';
                    if (v.length < 6) return 'Mínimo de 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // // Tipo de usuário (strings, sem enum/DTO)
                // Text('Tipo de usuário',
                //     style: theme.textTheme.titleMedium
                //         ?.copyWith(fontWeight: FontWeight.w700)),
                // const SizedBox(height: 8),
                // Wrap(
                //   spacing: 8,
                //   children: [
                //     ChoiceChip(
                //       label: const Text('Hóspede'),
                //       selected: _type == 'ROLE_GUEST',
                //       onSelected: (sel) =>
                //       sel ? setState(() => _type = 'ROLE_GUEST') : null,
                //       selectedColor: scheme.primary,
                //       labelStyle: TextStyle(
                //         color: _type == 'ROLE_GUEST' ? scheme.onPrimary : null,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //     ChoiceChip(
                //       label: const Text('Anfitrião'),
                //       selected: _type == 'ROLE_HOST',
                //       onSelected: (sel) =>
                //       sel ? setState(() => _type = 'ROLE_HOST') : null,
                //       selectedColor: scheme.primary,
                //       labelStyle: TextStyle(
                //         color: _type == 'ROLE_HOST' ? scheme.onPrimary : null,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ],
                // ),

                const SizedBox(height: 100),

                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    return FilledButton(
                      onPressed: _controller.loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: _controller.loading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Cadastrar'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
