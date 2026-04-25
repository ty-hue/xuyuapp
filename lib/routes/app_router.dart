import 'package:bilbili_project/layout/shell_page.dart';
import 'package:bilbili_project/pages/AllPhoto/index.dart';
import 'package:bilbili_project/pages/Create/index.dart';
import 'package:bilbili_project/pages/GlobalSearch/index.dart';
import 'package:bilbili_project/pages/Login/index.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/chat_history_search_page.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/chat_info_page.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/index.dart';
import 'package:bilbili_project/pages/Message/sub/InteractiveMessages/interactive_messages_page.dart';
import 'package:bilbili_project/pages/Message/sub/Chat/select_mutual_followers_page.dart';
import 'package:bilbili_project/pages/Mine/sub/AddFriend/index.dart';
import 'package:bilbili_project/pages/Mine/sub/AllFunction/index.dart';
import 'package:bilbili_project/pages/Mine/sub/DataAnalysis/index.dart';
import 'package:bilbili_project/pages/Mine/sub/EditProfile/index.dart';
import 'package:bilbili_project/pages/Mine/sub/Preview/index.dart';
import 'package:bilbili_project/pages/Mine/sub/Relationship/index.dart';
import 'package:bilbili_project/pages/Mine/sub/Search/index.dart';
import 'package:bilbili_project/pages/Mine/sub/Visitor/index.dart';
import 'package:bilbili_project/pages/Mine/sub/WatchHistory/index.dart';
import 'package:bilbili_project/pages/MusicDetail/index.dart';
import 'package:bilbili_project/pages/OtherHome/index.dart';
import 'package:bilbili_project/pages/Report/index.dart';
import 'package:bilbili_project/pages/Settings/index.dart';
import 'package:bilbili_project/routes/create_routes/network_single_image_preview_route.dart';
import 'package:bilbili_project/routes/create_routes/release_preparation_route.dart';
import 'package:bilbili_project/routes/create_routes/text_template_preview_route.dart';
import 'package:bilbili_project/routes/friend_routes/friend_route.dart';
import 'package:bilbili_project/routes/login_routes/choose_phone_prefix_route.dart';
import 'package:bilbili_project/routes/login_routes/fill_code_route.dart';
import 'package:bilbili_project/routes/login_routes/other_phone_login_route.dart';
import 'package:bilbili_project/routes/message_routes/message_route.dart';
import 'package:bilbili_project/routes/mine_routes/mine_route.dart';
import 'package:bilbili_project/routes/mine_routes/select_city_route.dart';
import 'package:bilbili_project/routes/mine_routes/select_country_route.dart';
import 'package:bilbili_project/routes/mine_routes/select_province_route.dart';
import 'package:bilbili_project/routes/mine_routes/update_user_info_field_route.dart';
import 'package:bilbili_project/routes/report_routes/report_last_route.dart';
import 'package:bilbili_project/routes/report_routes/report_second_route.dart';
import 'package:bilbili_project/routes/all_photo_routes/single_image_preview_route.dart';
import 'package:bilbili_project/routes/settings_routes/about_route.dart';
import 'package:bilbili_project/routes/settings_routes/account_safe_route.dart';
import 'package:bilbili_project/routes/settings_routes/action_page_route.dart';
import 'package:bilbili_project/routes/settings_routes/cache_route.dart';
import 'package:bilbili_project/routes/settings_routes/change_password_route.dart';
import 'package:bilbili_project/routes/settings_routes/change_phone_route.dart';
import 'package:bilbili_project/routes/settings_routes/change_phone_second_route.dart';
import 'package:bilbili_project/routes/settings_routes/declaration_route.dart';
import 'package:bilbili_project/routes/settings_routes/delete_account_route.dart';
import 'package:bilbili_project/routes/settings_routes/delete_account_second_route.dart';
import 'package:bilbili_project/routes/settings_routes/general_route.dart';
import 'package:bilbili_project/routes/settings_routes/notice_route.dart';
import 'package:bilbili_project/routes/settings_routes/permission_description_route.dart';
import 'package:bilbili_project/routes/settings_routes/permission_route.dart';
import 'package:bilbili_project/routes/settings_routes/privacy_policy_route.dart';
import 'package:bilbili_project/routes/settings_routes/privacy_route.dart';
import 'package:bilbili_project/routes/settings_routes/recover_account_route.dart';
import 'package:bilbili_project/routes/settings_routes/switch_account_route.dart';
import 'package:bilbili_project/routes/settings_routes/theme_route.dart';
import 'package:bilbili_project/routes/settings_routes/user_agreement_route.dart';
import 'package:bilbili_project/routes/watch_history_routes/history_search_route.dart';
import 'package:bilbili_project/viewmodels/EditProfile/index.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_routes/home_route.dart';

part 'app_router.g.dart';

// 登录路由
@TypedGoRoute<LoginRoute>(
  path: '/login',
  routes: [
    // Add sub-routes
    TypedGoRoute<OtherPhoneLoginRoute>(
      path: 'other_phone_login',
      routes: [
        TypedGoRoute<FillCodeRoute>(path: 'fill_code'),
        TypedGoRoute<ChoosePhonePrefixRoute>(path: 'choose_phone_prefix'),
      ],
    ),
  ],
)
class LoginRoute extends GoRouteData {
  const LoginRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return LoginPage();
  }
}

// 设置页 路由
@TypedGoRoute<SettingsPageRoute>(
  path: '/settings',
  routes: [
    TypedGoRoute<AccountSafeRoute>(
      path: 'account_safe',
      routes: [
        TypedGoRoute<ChangePhoneRoute>(path: 'change_phone'),
        TypedGoRoute<ChangePhoneSecondRoute>(path: 'change_phone_second'),
        TypedGoRoute<ChangePasswordRoute>(path: 'change_password'),
        TypedGoRoute<RecoverAccountRoute>(path: 'recover_account'),
        TypedGoRoute<DeleteAccountRoute>(path: 'delete_account'),
        TypedGoRoute<DeleteAccountSecondRoute>(path: 'delete_account_second'),
      ],
    ),
    TypedGoRoute<PrivacyRoute>(path: 'privacy'),
    TypedGoRoute<ActionPageRoute>(path: 'action'),
    TypedGoRoute<PermissionRoute>(path: 'permission'),
    TypedGoRoute<NoticeRoute>(path: 'notice'),
    TypedGoRoute<GeneralRoute>(path: 'general'),
    TypedGoRoute<PermissionDescriptionRoute>(path: 'permission_description'),
    TypedGoRoute<SwitchAccountRoute>(path: 'switch_account'),
    TypedGoRoute<ThemeRoute>(path: 'theme'),
    TypedGoRoute<PrivacyPolicyRoute>(path: 'privacy_policy'),
    TypedGoRoute<DeclarationRoute>(path: 'declaration'),
    TypedGoRoute<CacheRoute>(path: 'cache'),
    TypedGoRoute<AboutRoute>(path: 'about'),
    TypedGoRoute<UserAgreementRoute>(path: 'user_agreement'),
  ],
)
class SettingsPageRoute extends GoRouteData {
  const SettingsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SettingsPage();
  }
}

// 观看历史
@TypedGoRoute<WatchHistoryPageRoute>(
  path: '/watch_history',
  routes: [TypedGoRoute<HistorySearchRoute>(path: 'search')],
)
class WatchHistoryPageRoute extends GoRouteData {
  const WatchHistoryPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WatchHistoryPage();
  }
}

// 数据分析
@TypedGoRoute<DataAnalysisPageRoute>(path: '/data_analysis')
class DataAnalysisPageRoute extends GoRouteData {
  const DataAnalysisPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return DataAnalysisPage();
  }
}

// 全部功能
@TypedGoRoute<AllFunctionPageRoute>(path: '/all_function')
class AllFunctionPageRoute extends GoRouteData {
  const AllFunctionPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AllFunctionPage();
  }
}

// 个人搜索页 路由
@TypedGoRoute<SearchPageRoute>(path: '/search_myself')
class SearchPageRoute extends GoRouteData {
  const SearchPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SearchPage();
  }
}

// 预览页 路由
@TypedGoRoute<PreviewRoute>(path: '/preview')
class PreviewRoute extends GoRouteData {
  final String mode;
  final String imageUrl;
  final String tag;
  PreviewRoute({required this.mode, required this.imageUrl, required this.tag});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PreviewPage(mode: mode, imageUrl: imageUrl, tag: tag);
  }
}

// 添加朋友页 路由
@TypedGoRoute<AddFriendRoute>(path: '/add_friend')
class AddFriendRoute extends GoRouteData {
  const AddFriendRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AddFriendPage();
  }
}

// 关系页 路由
@TypedGoRoute<RelationshipRoute>(path: '/relationship')
class RelationshipRoute extends GoRouteData {
  final int initialIndex; // 👈 外部传进来的初始 tab
  RelationshipRoute({this.initialIndex = 0});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RelationshipPage(initialIndex: initialIndex);
  }
}

// 举报页 路由
@TypedGoRoute<ReportPageRoute>(
  path: '/report',
  routes: [
    // 二级举报类型路由
    TypedGoRoute<ReportSecondRoute>(path: ':firstReportTypeCode'),
    // 三级举报类型路由
    TypedGoRoute<ReportLastRoute>(
      path: ':firstReportTypeCode/:secondReportTypeCode',
    ),
  ],
)
class ReportPageRoute extends GoRouteData {
  const ReportPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ReportPage();
  }
}

// 主页访问 路由
@TypedGoRoute<VisitorPageRoute>(path: '/visitor')
class VisitorPageRoute extends GoRouteData {
  const VisitorPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return VisitorPage();
  }
}

// 所有照片路由
@TypedGoRoute<AllPhotoRoute>(
  path: '/all_photo',
  routes: [
    // 单张图片预览路由
    TypedGoRoute<SingleImagePreviewRoute>(path: 'single_image_preview'),
  ],
)
class AllPhotoRoute extends GoRouteData {
  final bool? isMultiple; // 是否多选
  final int? maxSelectCount; // 最大选择数量
  final int?
  featureCode; // 功能码： 用于下一步按钮具体要做什么 -1：（没有下一步按钮）什么都不做 1：带参数跳转到reportLast页

  const AllPhotoRoute({this.isMultiple, this.maxSelectCount, this.featureCode});

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final isMultiple = this.isMultiple ?? false;
    final maxSelectCount = this.maxSelectCount ?? 4;
    final featureCode = this.featureCode ?? -1;

    final editorConfig =
        state.extra as EditorConfig? ??
        EditorConfig(
          maxScale: 8.0,
          cropRectPadding: const EdgeInsets.all(0),
          hitTestSize: 20,

          // 🔽 裁剪形状（你可以切换）
          cropAspectRatio: 1.0, // 正方形
          initCropRectType: InitCropRectType.imageRect,
          // CropRectType.rect,
          cornerColor: Colors.white,
          lineColor: Colors.white,
        );
    return CustomTransitionPage(
      key: state.pageKey,
      child: AllPhotoPage(
        editorConfig: editorConfig,
        isMultiple: isMultiple,
        maxSelectCount: maxSelectCount,
        featureCode: featureCode,
      ),

      transitionDuration: const Duration(milliseconds: 300),

      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0, 1), // 👈 从底部
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}


// 这两个路由本身是在mine路由下的子路由，但是由于它们不能显示底部导航栏，所以把它们提示为顶级路由
@TypedGoRoute<EditProfileRoute>(
  path: '/mine/edit_profile',
  routes: [
    // 修改普通文本类型字段
    TypedGoRoute<UpdateUserInfoFieldRoute>(path: 'update_user_info_field'),
    // 选择地址
    TypedGoRoute<SelectCountryRoute>(
      path: 'select_country',
      routes: [
        TypedGoRoute<SelectProvinceRoute>(
          path: 'select_province',
          routes: [TypedGoRoute<SelectCityRoute>(path: 'select_city')],
        ),
      ],
    ),
  ],
)
class EditProfileRoute extends GoRouteData {
  final bool? dontSettingAddress;
  const EditProfileRoute({this.dontSettingAddress});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final address = state.extra as AddressResult?;
    return EditProfilePage(
      address: address,
      dontSettingAddress: dontSettingAddress,
    );
  }
}

@TypedGoRoute<CreateRoute>(path: '/create', routes: [
  TypedGoRoute<ReleasePreparationRoute>(path: 'release_preparation'),
  TypedGoRoute<TextTemplatePreviewRoute>(path: 'text_template_preview'),
  TypedGoRoute<NetworkSingleImagePreviewRoute>(path: 'network_image_preview'),
])
class CreateRoute extends GoRouteData {
  final String? fromUrl;
  const CreateRoute({this.fromUrl});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CreatePage(
      fromUrl: fromUrl,
    );
  }
}

// 搜索页 路由
@TypedGoRoute<GlobalSearchRoute>(path: '/global_search')
class GlobalSearchRoute extends GoRouteData {
  const GlobalSearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return GlobalSearchPage();
  }
}

// 聊天页 路由
@TypedGoRoute<ChatRoute>(path: '/chat')
class ChatRoute extends GoRouteData {
  const ChatRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatPage();
  }
}

/// 互动消息（赞评@ / 新关注等）
@TypedGoRoute<InteractiveMessagesRoute>(path: '/interactive_messages')
class InteractiveMessagesRoute extends GoRouteData {
  const InteractiveMessagesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const InteractiveMessagesPage();
  }
}

/// 聊天信息（会话设置）；[ChatInfoPageArgs] 通过 `context.push(..., extra: ...)` 传入。
@TypedGoRoute<ChatInfoRoute>(path: '/chat_info')
class ChatInfoRoute extends GoRouteData {
  const ChatInfoRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final extra = state.extra;
    final args = extra is ChatInfoPageArgs ? extra : const ChatInfoPageArgs();
    return ChatInfoPage(args: args);
  }
}

/// 发起群聊：选择互相关注的人。
@TypedGoRoute<SelectMutualFollowersRoute>(path: '/select_mutual_followers')
class SelectMutualFollowersRoute extends GoRouteData {
  const SelectMutualFollowersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SelectMutualFollowersPage();
  }
}

/// 查找聊天内容（会话内搜索）。
@TypedGoRoute<ChatHistorySearchRoute>(path: '/chat_history_search')
class ChatHistorySearchRoute extends GoRouteData {
  const ChatHistorySearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final extra = state.extra;
    final args = extra is ChatHistorySearchPageArgs ? extra : const ChatHistorySearchPageArgs();
    return ChatHistorySearchPage(args: args);
  }
}

// 他人主页路由
@TypedGoRoute<OtherHomeRoute>(path: '/other_home')
class OtherHomeRoute extends GoRouteData {
  const OtherHomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return OtherHomePage();
  }
}

// 音乐详情页路由
@TypedGoRoute<MusicDetailRoute>(path: '/music_detail')
class MusicDetailRoute extends GoRouteData {
  const MusicDetailRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MusicDetailPage();
  }
}


// 五个分支
@TypedStatefulShellRoute<ShellRouteData>(
  branches: [
    TypedStatefulShellBranch<HomeBranchData>(
      routes: [TypedGoRoute<HomeRoute>(path: '/')],
    ),
    TypedStatefulShellBranch<FriendBranchData>(
      routes: [TypedGoRoute<FriendRoute>(path: '/friend')],
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
