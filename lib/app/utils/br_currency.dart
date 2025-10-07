String formatBRL0(double v) {
  final x = v.round().toString();
  final withSep = x.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return 'R\$ $withSep,00';
}
