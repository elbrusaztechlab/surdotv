enum AppRoutes {
  splash('/'),
  mainHome('/main/home'),
  mainAbout('/main/about'),
  mainCategories('/main/categories'),
  mainSearch('/main/search'),
  mainContact('/main/contact'),
  categoryDetail('/main/categories/detail'),
  videoDetail('/video-detail'),
  videoPlayer('/video-player');

  const AppRoutes(this.path);

  final String path;

  static int indexFromPath(String path) {
    if (path.startsWith('/main/home')) return 0;
    if (path.startsWith('/main/about')) return 1;
    if (path.startsWith('/main/categories')) return 2;
    if (path.startsWith('/main/search')) return 3;
    if (path.startsWith('/main/contact')) return 4;
    return 0;
  }
}
