import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/dream/pages/dream_deposit_page.dart';
import 'features/dream/pages/dream_detail_page.dart';
import 'features/dream/pages/dream_home_page.dart';
import 'features/dream/pages/dream_new_page.dart';
import 'features/settings/pages/settings_page.dart';
import 'features/spend/pages/add_spend_page.dart';
import 'features/spend/pages/categories_page.dart';
import 'features/spend/pages/category_detail_page.dart';
import 'features/spend/pages/category_edit_page.dart';
import 'features/spend/pages/pending_page.dart';
import 'features/spend/pages/spend_home_page.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/spend',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/spend',
                builder: (context, state) => const SpendHomePage(),
                routes: [
                  GoRoute(
                    path: 'pending',
                    builder: (context, state) => const PendingPage(),
                  ),
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => AddSpendPage(
                      categoryId: state.uri.queryParameters['categoryId'],
                    ),
                  ),
                  GoRoute(
                    path: 'categories',
                    builder: (context, state) => const CategoriesPage(),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) =>
                            const CategoryEditPage(),
                      ),
                      GoRoute(
                        path: ':id/edit',
                        builder: (context, state) => CategoryEditPage(
                          categoryId: state.pathParameters['id'],
                        ),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final year = int.tryParse(
                                state.uri.queryParameters['year'] ?? '',
                              ) ??
                              DateTime.now().year;
                          return CategoryDetailPage(
                            categoryId: state.pathParameters['id']!,
                            year: year,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dream',
                builder: (context, state) => const DreamHomePage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const DreamNewPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => DreamDetailPage(
                      jarId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'deposit',
                        builder: (context, state) => DreamDepositPage(
                          jarId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: '消费',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: '梦想',
          ),
        ],
      ),
    );
  }
}
