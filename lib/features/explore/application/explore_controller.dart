import 'package:flutter/material.dart';

class ExploreController extends ChangeNotifier {
  ExploreController({double initialValor = 1000, String initialCidade = 'Alegrete, RS' })
      : _valorSelecionado = initialValor,
        _cidade = initialCidade;


  double _valorSelecionado;
  double get valorSelecionado => _valorSelecionado;

  String _cidade;
  String get cidade => _cidade;

  String? _tipoMoradia;
  String? get tipoMoradia => _tipoMoradia;

  String get tipoMoradiaLabel => _tipoMoradia ?? 'Escolha uma opção';


  void setValor(double v) {
    _valorSelecionado = v;
    notifyListeners();
  }

  void setCidade(String value) {
    if (value == _cidade) return;
    _cidade = value;
    notifyListeners();
  }

  void setTipoMoradia(String? value) {
    _tipoMoradia = value;
    notifyListeners();
  }
}
