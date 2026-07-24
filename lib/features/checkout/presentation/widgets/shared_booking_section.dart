import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/Space.dart';
import 'package:provider/provider.dart';
import '../../application/shared_booking_controller.dart';
import '../../domain/booking_invite.dart';
import '../../../../../app/utils/br_currency.dart';

/// Widget que exibe a seção de "Reserva Compartilhada" dentro do checkout.
///
/// Só é exibido quando o imóvel é do tipo coliving.
class SharedBookingSection extends StatefulWidget {
  final double totalPrice;
  final int maxGuests; // maxOccupancy - 1

  const SharedBookingSection({
    super.key,
    required this.totalPrice,
    required this.maxGuests,
  });

  @override
  State<SharedBookingSection> createState() => _SharedBookingSectionState();
}

class _SharedBookingSectionState extends State<SharedBookingSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Consumer<SharedBookingController>(
      builder: (context, ctrl, _) {
        // Expande automaticamente quando há convidados
        if (ctrl.guests.isNotEmpty && !_expanded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _expanded = true);
          });
        }
        return Card(
          elevation: 0,
          color: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          child: Column(
            children: [
              // ── Header toggle ──────────────────────────────────────────
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.people_alt_outlined, color: scheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dividir hospedagem',
                              style: text.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              ctrl.guests.isEmpty
                                  ? 'Convide usuários para dividir o custo'
                                  : '${ctrl.guests.length} convidado${ctrl.guests.length > 1 ? 's' : ''} adicionado${ctrl.guests.length > 1 ? 's' : ''}',
                              style: text.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    ],
                  ),
                ),
              ),

              // ── Body expandido ─────────────────────────────────────────
              if (_expanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Divisão do valor
                      _DivisionSummary(
                        totalPrice: widget.totalPrice,
                        ctrl: ctrl,
                        scheme: scheme,
                        text: text,
                      ),

                      const SizedBox(height: 16),

                      // Lista de convidados
                      if (ctrl.guests.isNotEmpty) ...[
                        Text('Convidados', style: text.labelLarge),
                        const SizedBox(height: 8),
                        ...ctrl.guests.map(
                          (g) => _GuestTile(
                            invite: g,
                            perPersonAmount:
                                ctrl.perPersonAmount(widget.totalPrice),
                            onRemove: () => ctrl.removeGuest(g.guestEmail),
                            scheme: scheme,
                            text: text,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Mensagem de erro
                      if (ctrl.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                scheme.errorContainer.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: scheme.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ctrl.error!,
                                  style: text.bodySmall?.copyWith(
                                      color: scheme.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Botão adicionar convidado
                      if (ctrl.guests.length < widget.maxGuests)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: ctrl.isLoading
                                ? null
                                : () => _showAddGuestSheet(context, ctrl),
                            icon: ctrl.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.person_add_alt_1_outlined),
                            label: Text(
                              ctrl.isLoading
                                  ? 'Validando...'
                                  : 'Adicionar convidado',
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.tertiaryContainer
                                .withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: scheme.tertiary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Limite máximo de ${widget.maxGuests} convidado${widget.maxGuests > 1 ? 's' : ''} atingido.',
                                  style: text.bodySmall?.copyWith(
                                      color: scheme.onTertiaryContainer),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Aviso de cancelamento automático
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.schedule,
                                color: scheme.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Os convidados têm 3 dias para aceitar e pagar. '
                                'Caso contrário, a reserva será cancelada automaticamente.',
                                style: text.bodySmall?.copyWith(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAddGuestSheet(BuildContext context, SharedBookingController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: ctrl,
        child: const _AddGuestSheet(),
      ),
    );
  }
}

// ── Resumo de divisão ────────────────────────────────────────────────────────

class _DivisionSummary extends StatelessWidget {
  final double totalPrice;
  final SharedBookingController ctrl;
  final ColorScheme scheme;
  final TextTheme text;

  const _DivisionSummary({
    required this.totalPrice,
    required this.ctrl,
    required this.scheme,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final total = ctrl.totalParticipants;
    final perPerson = ctrl.perPersonAmount(totalPrice);
    final ownerAmount = ctrl.ownerAmount(totalPrice);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total da reserva', style: text.bodyMedium),
              Text(formatBRL0(totalPrice),
                  style:
                      text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          if (total > 1) ...[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Você paga', style: text.bodyMedium),
                Text(
                  formatBRL0(ownerAmount),
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cada convidado paga',
                  style: text.bodySmall?.copyWith(color: Colors.black54),
                ),
                Text(
                  formatBRL0(perPerson),
                  style: text.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people_alt_outlined,
                    size: 14, color: scheme.primary),
                const SizedBox(width: 4),
                Text(
                  '$total participante${total > 1 ? 's' : ''} no total',
                  style: text.bodySmall?.copyWith(color: scheme.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Tile de convidado ────────────────────────────────────────────────────────

class _GuestTile extends StatelessWidget {
  final BookingInvite invite;
  final double perPersonAmount;
  final VoidCallback onRemove;
  final ColorScheme scheme;
  final TextTheme text;

  const _GuestTile({
    required this.invite,
    required this.perPersonAmount,
    required this.onRemove,
    required this.scheme,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              invite.guestName?.isNotEmpty == true
                  ? invite.guestName![0].toUpperCase()
                  : invite.guestEmail[0].toUpperCase(),
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.guestName ?? invite.guestEmail,
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (invite.guestName != null)
                  Text(
                    invite.guestEmail,
                    style: text.bodySmall?.copyWith(color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  formatBRL0(perPersonAmount),
                  style: text.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(status: invite.status),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onRemove,
            tooltip: 'Remover convidado',
            color: Colors.red.shade400,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ── Chip de status ───────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final InviteStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    switch (status) {
      case InviteStatus.accepted:
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
        break;
      case InviteStatus.declined:
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
        break;
      case InviteStatus.expired:
        bg = scheme.outlineVariant;
        fg = scheme.onSurfaceVariant;
        break;
      default:
        bg = scheme.tertiaryContainer;
        fg = scheme.onTertiaryContainer;
    }

    final invite = BookingInvite(guestEmail: '', status: status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        invite.statusLabel,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Bottom sheet adicionar convidado ─────────────────────────────────────────

class _AddGuestSheet extends StatefulWidget {
  const _AddGuestSheet();

  @override
  State<_AddGuestSheet> createState() => _AddGuestSheetState();
}

class _AddGuestSheetState extends State<_AddGuestSheet> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Consumer<SharedBookingController>(
      builder: (context, ctrl, _) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(Space.md),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Adicionar convidado',
                    style:
                        text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Informe o e-mail de um usuário cadastrado na plataforma.',
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'E-mail do convidado',
                      hintText: 'exemplo@email.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe o e-mail';
                      }
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(v.trim())) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: ctrl.isLoading
                          ? null
                          : () => _onConfirm(context, ctrl),
                      icon: ctrl.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label:
                          Text(ctrl.isLoading ? 'Validando...' : 'Adicionar'),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(46)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onConfirm(
      BuildContext context, SharedBookingController ctrl) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final result = await ctrl.addGuestByEmail(email);

    if (!mounted) return;

    final scheme = Theme.of(context).colorScheme;

    switch (result) {
      case AddGuestResult.success:
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Convidado adicionado: $email'),
            backgroundColor: scheme.primary,
          ),
        );
        break;
      case AddGuestResult.userNotFound:
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Usuário não encontrado nesta plataforma.'),
            backgroundColor: scheme.error,
          ),
        );
        break;
      case AddGuestResult.limitReached:
        if (!context.mounted) return;
        Navigator.of(context).pop();
        break;
      case AddGuestResult.alreadyAdded:
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Este e-mail já foi adicionado.'),
            backgroundColor: scheme.tertiary,
          ),
        );
        break;
      case AddGuestResult.selfInvite:
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Você não pode convidar a si mesmo.'),
            backgroundColor: scheme.error,
          ),
        );
        break;
      case AddGuestResult.error:
        final errorMsg = ctrl.error ?? 'Erro ao adicionar convidado.';
        final isSessionExpired = errorMsg.contains('sessão expirou') ||
            errorMsg.contains('login novamente') ||
            errorMsg.contains('Sessão expirada');

        if (isSessionExpired) {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sessão Expirada'),
              content: const Text(
                  'Sua sessão expirou. Faça logout e login novamente para continuar.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Fechar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                  child: const Text('Ir para Login'),
                ),
              ],
            ),
          );
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: scheme.error,
            ),
          );
        }
        break;
    }
  }
}
