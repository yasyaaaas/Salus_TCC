class AppAvatars {
  AppAvatars._();

  static const List<String> all = [
    'Chaengvely.png',
    'Davely.png',
    'Jeongvely.png',
    'Jively.png',
    'Mively.png',
    'Movely.png',
    'Navely.png',
    'Savely.png',
    'Tzuvely.png',
  ];

  static String path(String fileName) => 'assets/avatars/$fileName';
}