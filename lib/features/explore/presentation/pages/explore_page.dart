import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: const [SizedBox(width: 40)],
        title: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.apartment, color: Colors.black54, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Buscar apartamentos\nSão Paulo, SP',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
              IconButton(
                // color: Color(0xFFD10B58),
                onPressed: () {},
                icon: const Icon(Icons.tune, color: Colors.black54),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: scheme.primary, // nosso rosa
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          children: [
            Text(
              'Aluguel flexível,\ncom tudo pronto para morar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Encontre o apartamento perfeito, escolha quanto tempo quer morar e faça a locação online',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 24),

            // Card de filtros
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  children: [
                    // Tipo de moradia
                    ListTile(
                      leading: Icon(Icons.home_outlined, color: scheme.primary),
                      title: const Text(
                        'TIPO DE MORADIA',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: const Text('Escolha uma opção'),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    // Valor total
                    ListTile(
                      leading: Icon(Icons.attach_money, color: scheme.primary),
                      title: const Text(
                        'VALOR TOTAL',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: const Text('Escolha um limite'),
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),

                    // Botão buscar
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: scheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: scheme.inversePrimary,
        onPressed: () {},
        child: const Icon(
          Icons.chat_bubble_outline,
          color: Color(0xFFD10B58),
        ),
      ),
    );
  }
}
