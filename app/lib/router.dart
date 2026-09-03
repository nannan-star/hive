import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/dream/pages/dream_deposit_page.dart';
import 'features/dream/pages/fund_detail_page.dart';
import 'features/dream/pages/dream_home_page.dart';
import 'features/dream/pages/dream_new_page.dart';
import 'features/settings/pages/settings_page.dart';
import 'features/spend/pages/add_spend_page.dart';
import 'features/spend/pages/categories_page.dart';
import 'features/spend/pages/category_detail_page.dart';
import 'features/spend/pages/category_edit_page.dart';
import 'features/spend/pages/pending_page.dart';
import 'features/spend/pages/spend_home_page.dart';
import 'shared/theme/hive_colors.dart';
import 'shared/widgets/hive_widgets.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/spend',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final path = state.uri.path;
          final showNav = path == '/spend' || path == '/dream';
          return Scaffold(
            backgroundColor: HiveColors.page,
            body: navigationShell,
            bottomNavigationBar: showNav
                ? HiveTabBar(
                    index: navigationShell.currentIndex,
                    onSelect: navigationShell.goBranch,
                  )
                : null,
          );
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
                    builder: (context, state) => const DreamTypePickPage(),
                    routes: [
                      GoRoute(
                        path: 'goal',
                        builder: (context, state) => const DreamGoalNewPage(),
                      ),
                      GoRoute(
                        path: 'fund',
                        builder: (context, state) => const DreamFundNewPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => DreamJarDetailPage(
                      jarId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'deposit',
                        builder: (context, state) => DreamDepositPage(
                          jarId: state.pathParameters['id']!,
                          mode: DreamDepositMode.deposit,
                        ),
                      ),
                      GoRoute(
                        path: 'withdraw',
                        builder: (context, state) => DreamDepositPage(
                          jarId: state.pathParameters['id']!,
                          mode: DreamDepositMode.withdraw,
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
