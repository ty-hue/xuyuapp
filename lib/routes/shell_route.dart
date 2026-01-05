import 'package:bilbili_project/layout/shell_page.dart';
import 'package:bilbili_project/routes/create_route.dart';
import 'package:bilbili_project/routes/friend_route.dart';
import 'package:bilbili_project/routes/message_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_route.dart';
import 'mine_route.dart';

part 'shell_route.g.dart';

@TypedStatefulShellRoute<ShellRouteData>(
  branches: [
    TypedStatefulShellBranch<HomeBranchData>(
      routes: [TypedGoRoute<HomeRoute>(path: '/')],
    ),
    TypedStatefulShellBranch<FriendBranchData>(
      routes: [TypedGoRoute<FriendRoute>(path: '/friend')],
    ),
    TypedStatefulShellBranch<CreateBranchData>(
      routes: [TypedGoRoute<CreateRoute>(path: '/create')],
    ),
    TypedStatefulShellBranch<MessageBranchData>(
      routes: [TypedGoRoute<MessageRoute>(path: '/message')],
    ),
    TypedStatefulShellBranch<MineBranchData>(
      routes: [TypedGoRoute<MineRoute>(path: '/mine')],
    ),
  ],
)
class ShellRouteData extends StatefulShellRouteData {
  const ShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return ShellPage(navigationShell: navigationShell);
  }
}

class HomeBranchData extends StatefulShellBranchData {
  const HomeBranchData();
}

class MineBranchData extends StatefulShellBranchData {
  const MineBranchData();
}

class MessageBranchData extends StatefulShellBranchData {
  const MessageBranchData();
}

class FriendBranchData extends StatefulShellBranchData {
  const FriendBranchData();
}

class CreateBranchData extends StatefulShellBranchData {
  const CreateBranchData();
}
