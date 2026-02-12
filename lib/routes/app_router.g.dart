// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $loginRoute,
  $settingsPageRoute,
  $watchHistoryPageRoute,
  $dataAnalysisPageRoute,
  $allFunctionPageRoute,
  $searchPageRoute,
  $previewRoute,
  $addFriendRoute,
  $relationshipRoute,
  $reportPageRoute,
  $visitorPageRoute,
  $allPhotoRoute,
  $editProfileRoute,
  $createRoute,
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
  routes: [
    GoRouteData.$route(
      path: 'account_safe',

      factory: $AccountSafeRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'change_phone',

          factory: $ChangePhoneRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'change_phone_second',

          factory: $ChangePhoneSecondRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'change_password',

          factory: $ChangePasswordRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'recover_account',

          factory: $RecoverAccountRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'delete_account',

          factory: $DeleteAccountRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'delete_account_second',

          factory: $DeleteAccountSecondRouteExtension._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: 'privacy',

      factory: $PrivacyRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'action',

      factory: $ActionPageRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'permission',

      factory: $PermissionRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'notice',

      factory: $NoticeRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'general',

      factory: $GeneralRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'permission_description',

      factory: $PermissionDescriptionRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'switch_account',

      factory: $SwitchAccountRouteExtension._fromState,
    ),
    GoRouteData.$route(path: 'theme', factory: $ThemeRouteExtension._fromState),
    GoRouteData.$route(
      path: 'privacy_policy',

      factory: $PrivacyPolicyRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: 'declaration',

      factory: $DeclarationRouteExtension._fromState,
    ),
    GoRouteData.$route(path: 'cache', factory: $CacheRouteExtension._fromState),
    GoRouteData.$route(path: 'about', factory: $AboutRouteExtension._fromState),
    GoRouteData.$route(
      path: 'user_agreement',

      factory: $UserAgreementRouteExtension._fromState,
    ),
  ],
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

extension $AccountSafeRouteExtension on AccountSafeRoute {
  static AccountSafeRoute _fromState(GoRouterState state) =>
      const AccountSafeRoute();

  String get location => GoRouteData.$location('/settings/account_safe');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChangePhoneRouteExtension on ChangePhoneRoute {
  static ChangePhoneRoute _fromState(GoRouterState state) =>
      const ChangePhoneRoute();

  String get location =>
      GoRouteData.$location('/settings/account_safe/change_phone');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChangePhoneSecondRouteExtension on ChangePhoneSecondRoute {
  static ChangePhoneSecondRoute _fromState(GoRouterState state) =>
      const ChangePhoneSecondRoute();

  String get location =>
      GoRouteData.$location('/settings/account_safe/change_phone_second');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChangePasswordRouteExtension on ChangePasswordRoute {
  static ChangePasswordRoute _fromState(GoRouterState state) =>
      const ChangePasswordRoute();

  String get location =>
      GoRouteData.$location('/settings/account_safe/change_password');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $RecoverAccountRouteExtension on RecoverAccountRoute {
  static RecoverAccountRoute _fromState(GoRouterState state) =>
      const RecoverAccountRoute();

  String get location =>
      GoRouteData.$location('/settings/account_safe/recover_account');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $DeleteAccountRouteExtension on DeleteAccountRoute {
  static DeleteAccountRoute _fromState(GoRouterState state) =>
      const DeleteAccountRoute();

  String get location =>
      GoRouteData.$location('/settings/account_safe/delete_account');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $DeleteAccountSecondRouteExtension on DeleteAccountSecondRoute {
  static DeleteAccountSecondRoute _fromState(GoRouterState state) =>
      const DeleteAccountSecondRoute();

  String get location =>
      GoRouteData.$location('/settings/account_safe/delete_account_second');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PrivacyRouteExtension on PrivacyRoute {
  static PrivacyRoute _fromState(GoRouterState state) => const PrivacyRoute();

  String get location => GoRouteData.$location('/settings/privacy');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ActionPageRouteExtension on ActionPageRoute {
  static ActionPageRoute _fromState(GoRouterState state) =>
      const ActionPageRoute();

  String get location => GoRouteData.$location('/settings/action');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PermissionRouteExtension on PermissionRoute {
  static PermissionRoute _fromState(GoRouterState state) =>
      const PermissionRoute();

  String get location => GoRouteData.$location('/settings/permission');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $NoticeRouteExtension on NoticeRoute {
  static NoticeRoute _fromState(GoRouterState state) => const NoticeRoute();

  String get location => GoRouteData.$location('/settings/notice');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $GeneralRouteExtension on GeneralRoute {
  static GeneralRoute _fromState(GoRouterState state) => const GeneralRoute();

  String get location => GoRouteData.$location('/settings/general');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PermissionDescriptionRouteExtension on PermissionDescriptionRoute {
  static PermissionDescriptionRoute _fromState(GoRouterState state) =>
      const PermissionDescriptionRoute();

  String get location =>
      GoRouteData.$location('/settings/permission_description');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SwitchAccountRouteExtension on SwitchAccountRoute {
  static SwitchAccountRoute _fromState(GoRouterState state) =>
      const SwitchAccountRoute();

  String get location => GoRouteData.$location('/settings/switch_account');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ThemeRouteExtension on ThemeRoute {
  static ThemeRoute _fromState(GoRouterState state) => const ThemeRoute();

  String get location => GoRouteData.$location('/settings/theme');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PrivacyPolicyRouteExtension on PrivacyPolicyRoute {
  static PrivacyPolicyRoute _fromState(GoRouterState state) =>
      const PrivacyPolicyRoute();

  String get location => GoRouteData.$location('/settings/privacy_policy');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $DeclarationRouteExtension on DeclarationRoute {
  static DeclarationRoute _fromState(GoRouterState state) =>
      const DeclarationRoute();

  String get location => GoRouteData.$location('/settings/declaration');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CacheRouteExtension on CacheRoute {
  static CacheRoute _fromState(GoRouterState state) => const CacheRoute();

  String get location => GoRouteData.$location('/settings/cache');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AboutRouteExtension on AboutRoute {
  static AboutRoute _fromState(GoRouterState state) => const AboutRoute();

  String get location => GoRouteData.$location('/settings/about');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $UserAgreementRouteExtension on UserAgreementRoute {
  static UserAgreementRoute _fromState(GoRouterState state) =>
      const UserAgreementRoute();

  String get location => GoRouteData.$location('/settings/user_agreement');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $watchHistoryPageRoute => GoRouteData.$route(
  path: '/watch_history',

  factory: $WatchHistoryPageRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: 'search',

      factory: $HistorySearchRouteExtension._fromState,
    ),
  ],
);

extension $WatchHistoryPageRouteExtension on WatchHistoryPageRoute {
  static WatchHistoryPageRoute _fromState(GoRouterState state) =>
      const WatchHistoryPageRoute();

  String get location => GoRouteData.$location('/watch_history');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $HistorySearchRouteExtension on HistorySearchRoute {
  static HistorySearchRoute _fromState(GoRouterState state) =>
      const HistorySearchRoute();

  String get location => GoRouteData.$location('/watch_history/search');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $dataAnalysisPageRoute => GoRouteData.$route(
  path: '/data_analysis',

  factory: $DataAnalysisPageRouteExtension._fromState,
);

extension $DataAnalysisPageRouteExtension on DataAnalysisPageRoute {
  static DataAnalysisPageRoute _fromState(GoRouterState state) =>
      const DataAnalysisPageRoute();

  String get location => GoRouteData.$location('/data_analysis');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $allFunctionPageRoute => GoRouteData.$route(
  path: '/all_function',

  factory: $AllFunctionPageRouteExtension._fromState,
);

extension $AllFunctionPageRouteExtension on AllFunctionPageRoute {
  static AllFunctionPageRoute _fromState(GoRouterState state) =>
      const AllFunctionPageRoute();

  String get location => GoRouteData.$location('/all_function');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $searchPageRoute => GoRouteData.$route(
  path: '/search_myself',

  factory: $SearchPageRouteExtension._fromState,
);

extension $SearchPageRouteExtension on SearchPageRoute {
  static SearchPageRoute _fromState(GoRouterState state) =>
      const SearchPageRoute();

  String get location => GoRouteData.$location('/search_myself');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $previewRoute => GoRouteData.$route(
  path: '/preview',

  factory: $PreviewRouteExtension._fromState,
);

extension $PreviewRouteExtension on PreviewRoute {
  static PreviewRoute _fromState(GoRouterState state) => PreviewRoute(
    mode: state.uri.queryParameters['mode']!,
    imageUrl: state.uri.queryParameters['image-url']!,
    tag: state.uri.queryParameters['tag']!,
  );

  String get location => GoRouteData.$location(
    '/preview',
    queryParams: {'mode': mode, 'image-url': imageUrl, 'tag': tag},
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $addFriendRoute => GoRouteData.$route(
  path: '/add_friend',

  factory: $AddFriendRouteExtension._fromState,
);

extension $AddFriendRouteExtension on AddFriendRoute {
  static AddFriendRoute _fromState(GoRouterState state) =>
      const AddFriendRoute();

  String get location => GoRouteData.$location('/add_friend');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $relationshipRoute => GoRouteData.$route(
  path: '/relationship',

  factory: $RelationshipRouteExtension._fromState,
);

extension $RelationshipRouteExtension on RelationshipRoute {
  static RelationshipRoute _fromState(GoRouterState state) => RelationshipRoute(
    initialIndex:
        _$convertMapValue(
          'initial-index',
          state.uri.queryParameters,
          int.parse,
        ) ??
        0,
  );

  String get location => GoRouteData.$location(
    '/relationship',
    queryParams: {
      if (initialIndex != 0) 'initial-index': initialIndex.toString(),
    },
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

RouteBase get $reportPageRoute => GoRouteData.$route(
  path: '/report',

  factory: $ReportPageRouteExtension._fromState,
  routes: [
    GoRouteData.$route(
      path: ':firstReportTypeCode',

      factory: $ReportSecondRouteExtension._fromState,
    ),
    GoRouteData.$route(
      path: ':firstReportTypeCode/:secondReportTypeCode',

      factory: $ReportLastRouteExtension._fromState,
    ),
  ],
);

extension $ReportPageRouteExtension on ReportPageRoute {
  static ReportPageRoute _fromState(GoRouterState state) =>
      const ReportPageRoute();

  String get location => GoRouteData.$location('/report');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ReportSecondRouteExtension on ReportSecondRoute {
  static ReportSecondRoute _fromState(GoRouterState state) => ReportSecondRoute(
    firstReportTypeCode: state.pathParameters['firstReportTypeCode']!,
  );

  String get location => GoRouteData.$location(
    '/report/${Uri.encodeComponent(firstReportTypeCode)}',
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ReportLastRouteExtension on ReportLastRoute {
  static ReportLastRoute _fromState(GoRouterState state) => ReportLastRoute(
    firstReportTypeCode: state.pathParameters['firstReportTypeCode']!,
    secondReportTypeCode: state.pathParameters['secondReportTypeCode']!,
  );

  String get location => GoRouteData.$location(
    '/report/${Uri.encodeComponent(firstReportTypeCode)}/${Uri.encodeComponent(secondReportTypeCode)}',
  );

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
  routes: [
    GoRouteData.$route(
      path: 'single_image_preview',

      factory: $SingleImagePreviewRouteExtension._fromState,
    ),
  ],
);

extension $AllPhotoRouteExtension on AllPhotoRoute {
  static AllPhotoRoute _fromState(GoRouterState state) => AllPhotoRoute(
    isMultiple: _$convertMapValue(
      'is-multiple',
      state.uri.queryParameters,
      _$boolConverter,
    ),
    maxSelectCount: _$convertMapValue(
      'max-select-count',
      state.uri.queryParameters,
      int.tryParse,
    ),
    featureCode: _$convertMapValue(
      'feature-code',
      state.uri.queryParameters,
      int.tryParse,
    ),
  );

  String get location => GoRouteData.$location(
    '/all_photo',
    queryParams: {
      if (isMultiple != null) 'is-multiple': isMultiple!.toString(),
      if (maxSelectCount != null)
        'max-select-count': maxSelectCount!.toString(),
      if (featureCode != null) 'feature-code': featureCode!.toString(),
    },
  );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SingleImagePreviewRouteExtension on SingleImagePreviewRoute {
  static SingleImagePreviewRoute _fromState(GoRouterState state) =>
      const SingleImagePreviewRoute();

  String get location =>
      GoRouteData.$location('/all_photo/single_image_preview');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
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

RouteBase get $createRoute => GoRouteData.$route(
  path: '/create',

  factory: $CreateRouteExtension._fromState,
);

extension $CreateRouteExtension on CreateRoute {
  static CreateRoute _fromState(GoRouterState state) => const CreateRoute();

  String get location => GoRouteData.$location('/create');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
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
