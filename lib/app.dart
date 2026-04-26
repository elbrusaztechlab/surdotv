import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:surdotv_app/core/network/api_client.dart';
import 'package:surdotv_app/core/router/app_router.dart';
import 'package:surdotv_app/core/theme/app_theme.dart';
import 'package:surdotv_app/features/about/services/about_service.dart';
import 'package:surdotv_app/features/about/viewmodels/about_viewmodel.dart';
import 'package:surdotv_app/features/app_update/services/app_update_service.dart';
import 'package:surdotv_app/features/catalog/services/catalog_service.dart';
import 'package:surdotv_app/features/catalog/viewmodels/catalog_viewmodel.dart';
import 'package:surdotv_app/features/contact/services/contact_service.dart';
import 'package:surdotv_app/features/contact/viewmodels/contact_viewmodel.dart';
import 'package:surdotv_app/features/home/services/home_service.dart';
import 'package:surdotv_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:surdotv_app/features/search/services/search_service.dart';
import 'package:surdotv_app/features/search/viewmodels/search_viewmodel.dart';
import 'package:surdotv_app/features/video/viewmodels/video_detail_viewmodel.dart';

class SurdoTvApp extends StatelessWidget {
  const SurdoTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<http.Client>(
          create: (_) => http.Client(),
          dispose: (_, client) => client.close(),
        ),
        Provider<ApiClient>(
          create: (context) => ApiClient(context.read<http.Client>()),
        ),
        Provider<AppUpdateService>(
          create: (context) => AppUpdateService(context.read<ApiClient>()),
        ),
        Provider<HomeService>(
          create: (context) => HomeService(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(context.read<HomeService>()),
        ),
        Provider<CatalogService>(
          create: (context) => CatalogService(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<CatalogViewModel>(
          create: (context) => CatalogViewModel(context.read<CatalogService>()),
        ),
        Provider<SearchService>(
          create: (context) => SearchService(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (context) => SearchViewModel(context.read<SearchService>()),
        ),
        Provider<AboutService>(
          create: (context) => AboutService(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<AboutViewModel>(
          create: (context) => AboutViewModel(context.read<AboutService>()),
        ),
        Provider<ContactService>(
          create: (context) => ContactService(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<ContactViewModel>(
          create: (context) => ContactViewModel(context.read<ContactService>()),
        ),
        ChangeNotifierProvider<VideoDetailViewModel>(
          create: (context) =>
              VideoDetailViewModel(context.read<CatalogService>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Surdo TV',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
