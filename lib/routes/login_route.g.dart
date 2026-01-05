// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_route.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$loginRoute];

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
