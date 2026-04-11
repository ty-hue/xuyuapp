import 'package:bilbili_project/components/static_app_bar.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:bilbili_project/pages/Message/comps/contacts_list.dart';
import 'package:bilbili_project/pages/Message/comps/frequent_contacts.dart';
import 'package:bilbili_project/pages/Message/comps/search_view.dart';
import 'package:bilbili_project/routes/app_router.dart';
import 'package:bilbili_project/utils/PopoverUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MessagePage extends StatefulWidget {
  MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  bool isSearch = false;
  // 点击搜索按钮
  void _onSearch() {
    setState(() {
      isSearch = true;
    });
  }
  // 取消搜索
  void cancelSearch(){
    setState(() {
      isSearch = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return WithStatusbarColorView(
      statusBarColor: Colors.transparent,
      child: Stack(
        children: [
          Scaffold(
        appBar: StaticAppBar(
          backgroundColor: Colors.white,
          statusBarHeight: MediaQuery.of(context).padding.top,
          title: '消息',
          titleColor: Colors.black,
          titleFontWeight: FontWeight.w600,
          titleFontSize: 20.sp,
          actions: [
            _DimTapIconButton(
              icon: FontAwesomeIcons.search,
              size: 22.sp,
              color: Colors.black,
              onPressed: () {
                _onSearch();
              },
            ),

            Builder(
              builder: (anchorContext) {
                return _DimTapIconButton(
                  icon: FontAwesomeIcons.plus,
                  size: 22.sp,
                  color: Colors.black,
                  onPressed: () {
                    PopoverUtils.show(
                      context: anchorContext,
                      bodyBuilder: (context) => Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  print('发起群聊');
                                },
                                splashColor: Color.fromRGBO(207, 72, 53, 0.2),
                                highlightColor: Color.fromRGBO(
                                  207,
                                  72,
                                  53,
                                  0.1,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 12.0.w,
                                    children: [
                                      // 群聊图标
                                      Icon(
                                        FontAwesomeIcons.comment,
                                        size: 20.0.sp,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        '发起群聊',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            height: 1.0.h,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  AddFriendRoute().push(context);
                                  Navigator.pop(context);
                                },
                                splashColor: Color.fromRGBO(207, 72, 53, 0.2),
                                highlightColor: Color.fromRGBO(
                                  207,
                                  72,
                                  53,
                                  0.1,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 12.0.w,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.userPlus,
                                        size: 20.0.sp,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        '添加朋友',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPop: () {},
                      width: 180.w,
                      height: 130.h,
                      arrowHeight: 15.h,
                      arrowWidth: 30.w,
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [FrequentContacts(), ContactsList(),Container(
                height: 60.h,
                child: Center(
                  child: Text('暂时没有更多了', style: TextStyle(color: Colors.grey, fontSize: 14.sp),),
                ),
              )],
            ),
          ),
        ),
      ),
      if(isSearch)
        Positioned.fill(child: SearchView(cancelSearch: cancelSearch))
        ],
      )
    );
  }
}

/// 无圆形/矩形水波纹背景；按下时仅图标变暗，抬起恢复（与默认 [IconButton] 区分）。
class _DimTapIconButton extends StatefulWidget {
  const _DimTapIconButton({
    required this.icon,
    required this.size,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onPressed;

  @override
  State<_DimTapIconButton> createState() => _DimTapIconButtonState();
}

class _DimTapIconButtonState extends State<_DimTapIconButton> {
  bool _pressed = false;

  Color get _iconColor {
    if (widget.onPressed == null) {
      return widget.color.withValues(alpha: 0.38);
    }
    if (!_pressed) return widget.color;
    return widget.color.withValues(alpha: widget.color.a * 0.45);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: kMinInteractiveDimension,
          minHeight: kMinInteractiveDimension,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.onPressed == null
              ? null
              : (_) => setState(() => _pressed = true),
          onTapUp: widget.onPressed == null
              ? null
              : (_) => setState(() => _pressed = false),
          onTapCancel: widget.onPressed == null
              ? null
              : () => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: Center(
            child: Icon(widget.icon, size: widget.size, color: _iconColor),
          ),
        ),
      ),
    );
  }
}
