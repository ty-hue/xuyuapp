import 'package:go_router/go_router.dart';
import 'app_router.dart'; // 只要引入“有注解的文件”即可
final router = GoRouter(
  initialLocation: '/',
  routes: $appRoutes,
);