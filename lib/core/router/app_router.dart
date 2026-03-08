import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:surdotv_app/core/router/route_constants.dart';
import 'package:surdotv_app/features/about/views/about_screen.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/features/catalog/views/categories_screen.dart';
import 'package:surdotv_app/features/contact/views/contact_screen.dart';
import 'package:surdotv_app/features/home/views/home_screen.dart';
import 'package:surdotv_app/features/player/views/video_player_screen.dart';
import 'package:surdotv_app/features/search/views/search_screen.dart';
import 'package:surdotv_app/features/video/views/video_detail_screen.dart';
import 'package:surdotv_app/main_scaffold_with_nav.dart';
import 'package:surdotv_app/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash.path,
    redirect: (context, state) {
      if (state.matchedLocation == '/main' ||
          state.matchedLocation == '/main/') {
        return AppRoutes.mainHome.path;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash.path,
        builder: (_, __) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) {
          return MainScaffoldWithNav(navigationShell: shell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mainHome.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mainAbout.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AboutScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mainCategories.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CategoriesScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    builder: (context, state) {
                      final categoryId = state.pathParameters['id'];
                      if (categoryId == null || categoryId.isEmpty) {
                        return const CategoriesScreen();
                      }
                      return CategoriesScreen(initialCategoryId: categoryId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mainSearch.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SearchScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mainContact.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ContactScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.videoDetail.path}/:id',
        builder: (context, state) {
          final videoId = state.pathParameters['id'] ?? '';
          return VideoDetailScreen(videoId: videoId);
        },
      ),
      GoRoute(
        path: AppRoutes.videoPlayer.path,
        redirect: (context, state) =>
            state.extra is VideoItemModel ? null : AppRoutes.mainHome.path,
        builder: (context, state) {
          return VideoPlayerScreen(video: state.extra! as VideoItemModel);
        },
      ),
    ],
  );
}
