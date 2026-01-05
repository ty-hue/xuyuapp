import 'package:go_router/go_router.dart';
import 'shell_route.dart'; // 只要引入“有注解的文件”即可

final router = GoRouter(
  initialLocation: '/',
  routes: $appRoutes,
);