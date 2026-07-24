import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/explore/application/explore_controller.dart';
import '../features/explore/presentation/pages/explore_page.dart';
import '../features/favorites/presentation/pages/favorites_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/search/presentation/pages/listings_page.dart';
import '../shared/widgets/imovato_bottom_navigation.dart';

/// Área principal que mantém as quatro abas e seus estados ativos.
class AppShell extends StatefulWidget {
  const AppShell({this.initialIndex = 0, super.key});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
    if (_currentIndex == 1) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _loadSearchIfNeeded());
    }
  }

  void _loadSearchIfNeeded() {
    final controller = context.read<ExploreController>();
    if (!controller.isLoading && controller.results.isEmpty) {
      controller.searchAccommodations();
    }
  }

  void _selectDestination(ImovatoNavigationDestination destination) {
    final index = destination.index;
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (destination == ImovatoNavigationDestination.search) {
      _loadSearchIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      ExplorePage(),
      ListingsPage(),
      FavoritesPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ImovatoBottomNavigation(
          currentDestination:
              ImovatoNavigationDestination.values[_currentIndex],
          onDestinationSelected: _selectDestination,
        ),
      ),
    );
  }
}
