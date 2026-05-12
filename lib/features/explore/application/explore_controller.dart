import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show utf8;

import '../../search/domain/property.dart';

/// Classe para armazenar os filtros de busca
class SearchFilters {
  final double? priceMin;
  final double? priceMax;
  final String? city;
  final String? state;
  final String? neighborhood;
  final String? accommodationType; // "APARTMENT", "HOUSE", etc
  final int? maxOccupancy;
  final bool? allowsPets;
  final bool? allowsChildren;
  final bool? isSharedHosting;

  const SearchFilters({
    this.priceMin,
    this.priceMax,
    this.city,
    this.state,
    this.neighborhood,
    this.accommodationType,
    this.maxOccupancy,
    this.allowsPets,
    this.allowsChildren,
    this.isSharedHosting,
  });

  /// Converte os filtros para query parameters da URL
  Map<String, String> toQueryParameters() {
    final params = <String, String>{};

    if (priceMin != null) params['priceMin'] = priceMin!.toStringAsFixed(2);
    if (priceMax != null) params['price'] = priceMax!.toStringAsFixed(2);
    if (city != null && city!.isNotEmpty) params['city'] = city!;
    if (state != null && state!.isNotEmpty) params['state'] = state!;
    if (neighborhood != null && neighborhood!.isNotEmpty) params['neighborhood'] = neighborhood!;
    if (accommodationType != null && accommodationType!.isNotEmpty) params['accommodationType'] = accommodationType!;
    if (maxOccupancy != null) params['maxOccupancy'] = maxOccupancy!.toString();
    if (allowsPets != null) params['allowsPets'] = allowsPets!.toString();
    if (allowsChildren != null) params['allowsChildren'] = allowsChildren!.toString();
    if (isSharedHosting != null) params['isSharedHosting'] = isSharedHosting!.toString();

    return params;
  }

  /// Cria uma cópia com valores atualizados
  /// Usa um padrão que permite passar null explicitamente
  SearchFilters copyWith({
    Object? priceMin = const _Undefined(),
    Object? priceMax = const _Undefined(),
    Object? city = const _Undefined(),
    Object? state = const _Undefined(),
    Object? neighborhood = const _Undefined(),
    Object? accommodationType = const _Undefined(),
    Object? maxOccupancy = const _Undefined(),
    Object? allowsPets = const _Undefined(),
    Object? allowsChildren = const _Undefined(),
    Object? isSharedHosting = const _Undefined(),
  }) {
    return SearchFilters(
      priceMin: priceMin is _Undefined ? this.priceMin : priceMin as double?,
      priceMax: priceMax is _Undefined ? this.priceMax : priceMax as double?,
      city: city is _Undefined ? this.city : city as String?,
      state: state is _Undefined ? this.state : state as String?,
      neighborhood: neighborhood is _Undefined ? this.neighborhood : neighborhood as String?,
      accommodationType: accommodationType is _Undefined ? this.accommodationType : accommodationType as String?,
      maxOccupancy: maxOccupancy is _Undefined ? this.maxOccupancy : maxOccupancy as int?,
      allowsPets: allowsPets is _Undefined ? this.allowsPets : allowsPets as bool?,
      allowsChildren: allowsChildren is _Undefined ? this.allowsChildren : allowsChildren as bool?,
      isSharedHosting: isSharedHosting is _Undefined ? this.isSharedHosting : isSharedHosting as bool?,
    );
  }
}

// Classe auxiliar para detectar quando um parâmetro não foi fornecido
class _Undefined {
  const _Undefined();
}

class ExploreController extends ChangeNotifier {
  ExploreController({double initialValor = 500, String initialCidade = 'Alegrete, RS' })
      : _valorSelecionado = initialValor,
        _cidade = initialCidade,
        _filters = SearchFilters();

  // existing state
  double _valorSelecionado;
  double get valorSelecionado => _valorSelecionado;

  String _cidade;
  String get cidade => _cidade;

  String? _tipoMoradia;
  String? get tipoMoradia => _tipoMoradia;

  String get tipoMoradiaLabel => _tipoMoradia ?? 'Escolha uma opção';

  // new state for search results
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Property> _results = [];
  List<Property> get results => List.unmodifiable(_results);

  // Filtros de busca
  late SearchFilters _filters;
  SearchFilters get filters => _filters;

  static const _baseUrl = 'https://cadastral-imovato-35ca7e6548df.herokuapp.com';

  void setValor(double v) {
    _valorSelecionado = v;
    notifyListeners();
  }

  void setCidade(String value) {
    if (value == _cidade) return;
    _cidade = value;

    // Atualiza também o filtro de city
    _filters = _filters.copyWith(city: value);

    notifyListeners();

    // Dispara a busca automaticamente
    searchAccommodations();
  }

  void setTipoMoradia(String? value) {
    _tipoMoradia = value;
    notifyListeners();
  }

  /// Atualiza os filtros de busca
  void setFilters(SearchFilters filters) {
    _filters = filters;
    notifyListeners();
  }

  /// Atualiza um filtro específico
  void updateFilter({
    double? priceMin,
    double? priceMax,
    String? city,
    String? state,
    String? neighborhood,
    String? accommodationType,
    int? maxOccupancy,
    bool? allowsPets,
    bool? allowsChildren,
    bool? isSharedHosting,
  }) {
    _filters = _filters.copyWith(
      priceMin: priceMin,
      priceMax: priceMax,
      city: city,
      state: state,
      neighborhood: neighborhood,
      accommodationType: accommodationType,
      maxOccupancy: maxOccupancy,
      allowsPets: allowsPets,
      allowsChildren: allowsChildren,
      isSharedHosting: isSharedHosting,
    );
    notifyListeners();
  }

  /// Reseta todos os filtros mas mantém a localização
  void resetFilters() {
    _filters = SearchFilters(
      city: _filters.city,
      state: _filters.state,
      neighborhood: _filters.neighborhood,
    );
    notifyListeners();
  }

  /// Fetch accommodations from remote API com filtros aplicados
  Future<void> searchAccommodations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Construir URL com query parameters baseado nos filtros
      final queryParams = _filters.toQueryParameters();
      final url = Uri.parse('$_baseUrl/accommodations/search')
          .replace(queryParameters: queryParams);

      debugPrint('========== BUSCA DE IMÓVEIS ==========');
      debugPrint('URL: $url');
      debugPrint('Filtros aplicados:');
      queryParams.forEach((key, value) {
        debugPrint('  $key: $value');
      });
      debugPrint('======================================');

      final res = await http.get(url);
      if (res.statusCode != 200) {
        _error = 'Erro ao buscar imóveis (${res.statusCode})';
        _results = [];
        return;
      }

      final String decodedBody = utf8.decode(res.bodyBytes);

      print('\n🔍🔍🔍 === DEBUGGING RESPOSTA DA API === 🔍🔍🔍');
      print('Body completo (primeiros 500 chars): ${decodedBody.substring(0, decodedBody.length > 500 ? 500 : decodedBody.length)}');

      final List<dynamic> data = json.decode(decodedBody) as List<dynamic>;

      print('📦 Total de imóveis: ${data.length}');

      if (data.isNotEmpty) {
        print('\n📋 === PRIMEIRO IMÓVEL COMPLETO ===');
        final first = data[0];
        print('Tipo: ${first.runtimeType}');
        if (first is Map) {
          print('Keys disponíveis: ${first.keys.toList()}');
          print('\nValores:');
          first.forEach((key, value) {
            if (key.toString().toLowerCase().contains('id')) {
              print('  ⭐ $key: $value (${value.runtimeType})');
            } else {
              print('  $key: ${value.toString().length > 50 ? value.toString().substring(0, 50) + "..." : value}');
            }
          });
        }
        print('=================================\n');
      }

      _results = data.map<Property>((e) {
        // Extrair ID - tentar TODAS as possibilidades
        String? realId;

        // Verificar cada campo possível
        if (e['_id'] != null) {
          realId = e['_id'].toString();
          print('✅ Usando _id: $realId');
        } else if (e['id'] != null) {
          realId = e['id'].toString();
          print('✅ Usando id: $realId');
        } else if (e['accommodationId'] != null) {
          realId = e['accommodationId'].toString();
          print('✅ Usando accommodationId: $realId');
        } else {
          // NENHUM ID ENCONTRADO - usar timestamp e avisar
          realId = DateTime.now().millisecondsSinceEpoch.toString();
          print('⚠️⚠️⚠️ AVISO: Nenhum ID encontrado! Usando timestamp: $realId');
          print('⚠️ Keys disponíveis: ${(e as Map).keys.toList()}');
        }

        final id = realId;
        final title = e['title']?.toString() ?? '';
        final address = e['address']?.toString() ?? '';
        final streetNumber = e['streetNumber']?.toString() ?? '0';
        final neighborhood = e['neighborhood']?.toString() ?? '';
        final city = e['city']?.toString() ?? '';
        final state = e['state']?.toString() ?? '';
        final description = e['description']?.toString() ?? '';
        final price = (e['price'] is num) ? (e['price'] as num).toDouble() : 0.0;
        final maxOccupancy = (e['maxOccupancy'] is num) ? (e['maxOccupancy'] as num).toInt() : 1;
        final bedrooms = (e['roomCount'] is num) ? (e['roomCount'] as num).toInt() : 0;
        final bathrooms = (e['bathroomCount'] is num) ? (e['bathroomCount'] as num).toInt() : 0;
        final petFriendly = (e['allowsPets'] is bool) ? (e['allowsPets'] as bool) : false;
        final isSharedHosting = (e['isSharedHosting'] is bool) ? (e['isSharedHosting'] as bool) : false;
        final accommodationType = isSharedHosting ? 'coliving' : 'moradia individual';
        final images = <String>[];
        if (e['imagesUrls'] is List) {
          images.addAll(List<String>.from(e['imagesUrls']));
        }

        return Property(
          id: id,
          title: title,
          address: address,
          streetNumber: streetNumber,
          neighborhood: neighborhood,
          city: city,
          state: state,
          description: description,
          price: price,
          imagesUrls: images,
          maxOccupancy: maxOccupancy,
          bedrooms: bedrooms,
          bathrooms: bathrooms,
          accommodationType: accommodationType,
          petFriendly: petFriendly,
        );
      }).toList(growable: false);
    } catch (ex) {
      _error = 'Erro: ${ex.toString()}';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle favorite by property id
  void toggleFavoriteById(String id, bool fav) {
    final idx = _results.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    final updated = _results[idx].copyWith(favorito: fav);
    _results = List<Property>.from(_results)
      ..[idx] = updated;
    notifyListeners();
  }
}
