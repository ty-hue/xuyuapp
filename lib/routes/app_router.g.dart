// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $loginRoute,
  $settingsPageRoute,
  $visitorPageRoute,
  $allPhotoRoute,
  $editProfileRoute,
  $shellRouteData,
];

RouteBase get $loginRoute => GoRouteData.$route(
  path: '/login',

  factory: $LoginRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: 'other_phone_login',

      factory: $OtherPhoneLoginRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'fill_code',

          factory: $FillCodeRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'choose_phone_prefix',

          factory: $ChoosePhonePrefixRouteExtension._fromState,
        ),
      ],
    ),
  ],
);

extension $LoginRouteExtension on LoginRoute {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  String get location => GoRouteData.$location('/login');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $OtherPhoneLoginRouteExtension on OtherPhoneLoginRoute {
  static OtherPhoneLoginRoute _fromState(GoRouterState state) =>
      const OtherPhoneLoginRoute();

  String get location => GoRouteData.$location('/login/other_phone_login');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $FillCodeRouteExtension on FillCodeRoute {
  static FillCodeRoute _fromState(GoRouterState state) => const FillCodeRoute();

  String get location =>
      GoRouteData.$location('/login/other_phone_login/fill_code');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChoosePhonePrefixRouteExtension on ChoosePhonePrefixRoute {
  static ChoosePhonePrefixRoute _fromState(GoRouterState state) =>
      const ChoosePhonePrefixRoute();

  String get location =>
      GoRouteData.$location('/login/other_phone_login/choose_phone_prefix');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsPageRoute => GoRouteData.$route(
  path: '/settings',

  factory: $SettingsPageRouteExtension._fromState,
);

extension $SettingsPageRouteExtension on SettingsPageRoute {
  static SettingsPageRoute _fromState(GoRouterState state) =>
      const SettingsPageRoute();

  String get location => GoRouteData.$location('/settings');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $visitorPageRoute => GoRouteData.$route(
  path: '/visitor',

  factory: $VisitorPageRouteExtension._fromState,
);

extension $VisitorPageRouteExtension on VisitorPageRoute {
  static VisitorPageRoute _fromState(GoRouterState state) =>
      const VisitorPageRoute();

  String get location => GoRouteData.$location('/visitor');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $allPhotoRoute => GoRouteData.$route(
  path: '/all_photo',

  factory: $AllPhotoRouteExtension._fromState,
);

extension $AllPhotoRouteExtension on AllPhotoRoute {
  static AllPhotoRoute _fromState(GoRouterState state) => const AllPhotoRoute();

  String get location => GoRouteData.$location('/all_photo');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $editProfileRoute => GoRouteData.$route(
  path: '/mine/edit_profile',

  factory: $EditProfileRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: 'update_user_info_field',

      factory: $UpdateUserInfoFieldRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'select_country',

      factory: $SelectCountryRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'select_province',

          factory: $SelectProvinceRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'select_city',

              factory: $SelectCityRouteExtension._fromState,
            ),
          ],
        ),
      ],
    ),
  ],
);

extension $EditProfileRouteExtension on EditProfileRoute {
  static EditProfileRoute _fromState(GoRouterState state) => EditProfileRoute(
    dontSettingAddress: _$convertMapValue(
      'dont-setting-address',
      state.uri.queryParameters,
      _$boolConverter,
    ),
  );

  String get location => GoRouteData.$location(
    '/mine/edit_profile',
    queryParams: {
      if (dontSettingAddress != null)
        'dont-setting-address': dontSettingAddress!.toString(),
    },
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $UpdateUserInfoFieldRouteExtension on UpdateUserInfoFieldRoute {
  static UpdateUserInfoFieldRoute _fromState(GoRouterState state) =>
      const UpdateUserInfoFieldRoute();

  String get location =>
      GoRouteData.$location('/mine/edit_profile/update_user_info_field');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SelectCountryRouteExtension on SelectCountryRoute {
  static SelectCountryRoute _fromState(GoRouterState state) =>
      const SelectCountryRoute();

  String get location =>
      GoRouteData.$location('/mine/edit_profile/select_country');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SelectProvinceRouteExtension on SelectProvinceRoute {
  static SelectProvinceRoute _fromState(GoRouterState state) =>
      SelectProvinceRoute(
        countryCode: state.uri.queryParameters['country-code']!,
      );

  String get location => GoRouteData.$location(
    '/mine/edit_profile/select_country/select_province',
    queryParams: {'country-code': countryCode},
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SelectCityRouteExtension on SelectCityRoute {
  static SelectCityRoute _fromState(GoRouterState state) => SelectCityRoute(
    countryCode: state.uri.queryParameters['country-code']!,
    provinceCode: state.uri.queryParameters['province-code']!,
  );

  String get location => GoRouteData.$location(
    '/mine/edit_profile/select_country/select_province/select_city',
    queryParams: {'country-code': countryCode, 'province-code': provinceCode},
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}

RouteBase get $shellRouteData => StatefulShellRouteData.$route(
  factory: $ShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(path: '/', factory: $HomeRouteExtension._fromState),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/friend',

          factory: $FriendRouteExtension._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/create',

          factory: $CreateRouteExtension._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/message',

          factory: $MessageRouteExtension._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/mine',

          factory: $MineRouteExtension._fromState,
        ),
      ],
    ),
  ],
);

extension $ShellRouteDataExtension on ShellRouteData {
  static ShellRouteData _fromState(GoRouterState state) =>
      const ShellRouteData();
}

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location('/');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $FriendRouteExtension on FriendRoute {
  static FriendRoute _fromState(GoRouterState state) => const FriendRoute();

  String get location => GoRouteData.$location('/friend');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CreateRouteExtension on CreateRoute {
  static CreateRoute _fromState(GoRouterState state) => const CreateRoute();

  String get location => GoRouteData.$location('/create');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $MessageRouteExtension on MessageRoute {
  static MessageRoute _fromState(GoRouterState state) => const MessageRoute();

  String get location => GoRouteData.$location('/message');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $MineRouteExtension on MineRoute {
  static MineRoute _fromState(GoRouterState state) => const MineRoute();

  String get location => GoRouteData.$location('/mine');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
