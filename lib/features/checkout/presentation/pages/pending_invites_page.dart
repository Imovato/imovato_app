import 'package:flutter/material.dart';
import 'package:imovato_app/app/theme/tokens/imovato_radius.dart';
import '../../application/invite_service.dart';

class PendingInvitesPage extends StatefulWidget {
  const PendingInvitesPage({super.key});

  @override
  State<PendingInvitesPage> createState() => _PendingInvitesPageState();
}

class _PendingInvitesPageState extends State<PendingInvitesPage> {
  final InviteService _inviteService = InviteService();

  List<Map<String, dynamic>> _invites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final invites = await _inviteService.getPendingInvites();
      setState(() => _invites = invites);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Convites Pendentes'),
        centerTitle: true,
        backgroundColor: scheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvites,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(scheme, text),
    );
  }

  Widget _buildBody(ColorScheme scheme, TextTheme text) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: scheme.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: scheme.error),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadInvites,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_invites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline,
                size: 72, color: scheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Nenhum convite pendente',
              style: text.titleMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quando alguém te convidar para uma reserva,\naparecerá aqui.',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvites,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _invites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _InviteCard(
            invite: _invites[index],
            scheme: scheme,
            text: text,
          );
        },
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  final Map<String, dynamic> invite;
  final ColorScheme scheme;
  final TextTheme text;

  const _InviteCard({
    required this.invite,
    required this.scheme,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final bookingId = invite['bookingId']?.toString() ??
        invite['booking_id']?.toString() ??
        invite['id']?.toString() ??
        '—';
    final guestId =
        invite['guestId']?.toString() ?? invite['guest_id']?.toString() ?? '—';
    final guestName = invite['guestName']?.toString() ??
        invite['guest_name']?.toString() ??
        invite['userName']?.toString();
    final guestEmail = invite['guestEmail']?.toString() ??
        invite['guest_email']?.toString() ??
        invite['email']?.toString();
    final status = invite['status']?.toString() ?? 'PENDING';
    final createdAt = invite['createdAt']?.toString() ??
        invite['created_at']?.toString() ??
        '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: ImovatoBorderRadius.circular(ImovatoBorderRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Reserva + status chip
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius:
                        ImovatoBorderRadius.circular(ImovatoBorderRadius.sm),
                  ),
                  child: Icon(Icons.home_outlined,
                      size: 20, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reserva #$bookingId',
                        style: text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (createdAt.isNotEmpty)
                        Text(
                          _formatDate(createdAt),
                          style: text.bodySmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.5)),
                        ),
                    ],
                  ),
                ),
                _StatusChip(status: status, scheme: scheme, text: text),
              ],
            ),

            const Divider(height: 24),

            // Convidado
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.secondaryContainer,
                  child: Text(
                    (guestName ?? guestEmail ?? guestId)[0].toUpperCase(),
                    style: TextStyle(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (guestName != null)
                        Text(guestName,
                            style: text.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      if (guestEmail != null)
                        Text(guestEmail,
                            style: text.bodySmall?.copyWith(
                                color:
                                    scheme.onSurface.withValues(alpha: 0.6))),
                      if (guestName == null && guestEmail == null)
                        Text('ID: $guestId',
                            style: text.bodySmall?.copyWith(
                                color:
                                    scheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final ColorScheme scheme;
  final TextTheme text;

  const _StatusChip(
      {required this.status, required this.scheme, required this.text});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    switch (status.toUpperCase()) {
      case 'PENDING':
        color = Colors.orange;
        label = 'Pendente';
        break;
      case 'ACCEPTED':
        color = Colors.green;
        label = 'Aceito';
        break;
      case 'REJECTED':
        color = Colors.red;
        label = 'Recusado';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: ImovatoBorderRadius.circular(ImovatoBorderRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: text.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
