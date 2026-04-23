import 'package:azlistview/azlistview.dart';
import 'package:bilbili_project/components/with_statusBar_color.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lpinyin/lpinyin.dart';

/// 互关用户一条（用于字母分组列表）。
class MutualFollowContact implements ISuspensionBean {
  MutualFollowContact({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.tag,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String tag;

  @override
  bool isShowSuspension = false;

  @override
  String getSuspensionTag() => tag;
}

/// 名称匹配：昵称子串（中/英） + 全拼片段 + 首字母序列（语义同 [contact_name_filter]）。
bool mutualFollowMatchesQuery(MutualFollowContact e, String queryRaw) {
  final trimmed = queryRaw.trim();
  if (trimmed.isEmpty) return true;

  final needleLower = trimmed.toLowerCase();
  final nameLower = e.name.toLowerCase();
  if (nameLower.contains(needleLower)) return true;

  final needleCompact = needleLower.replaceAll(RegExp(r'\s+'), '');
  if (needleCompact.isEmpty) return true;

  try {
    final full = PinyinHelper.getPinyinE(
      e.name,
      separator: '',
      defPinyin: '',
      format: PinyinFormat.WITHOUT_TONE,
    ).toLowerCase().replaceAll(RegExp(r'\s+'), '');
    if (full.contains(needleCompact)) return true;

    final initials = PinyinHelper.getShortPinyin(e.name).toLowerCase().replaceAll(RegExp(r'\s+'), '');
    if (initials.contains(needleCompact)) return true;
  } catch (_) {
    // ignore
  }
  return false;
}

/// 选择互相关注的人 → 发起群聊（示意 UI：搜索、多选、右侧字母索引）。
class SelectMutualFollowersPage extends StatefulWidget {
  const SelectMutualFollowersPage({super.key});

  /// 主题色：偏粉，接近常见 IM「建群」按钮
  static const Color accentPink = Color(0xFFFF2C55);

  @override
  State<SelectMutualFollowersPage> createState() => _SelectMutualFollowersPageState();
}

class _SelectMutualFollowersPageState extends State<SelectMutualFollowersPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedIds = [];

  late List<MutualFollowContact> _all;
  List<MutualFollowContact> _visible = [];

  /// 与 [susItemBuilder] 内占位高度一致，避免 azlistview 悬浮头布局异常。
  double get _susHeaderHeight => 36.h;

  static String _tagForName(String name) {
    try {
      final py = PinyinHelper.getShortPinyin(name);
      if (py.isEmpty) return '#';
      final c = py[0].toUpperCase();
      if (RegExp(r'^[A-Z]$').hasMatch(c)) return c;
    } catch (_) {
      // ignore
    }
    final first = name.trim();
    if (first.isEmpty) return '#';
    final ch = first[0];
    if (RegExp(r'^[A-Za-z]$').hasMatch(ch)) return ch.toUpperCase();
    return '#';
  }

  static final List<String> _demoAvatars = [
    'https://q6.itc.cn/q_70/images03/20250306/355fba6a5cb049f5b98c2ed9f03cc5e1.jpeg',
    'https://q2.itc.cn/q_70/images03/20250623/337b5e62a9444bcda5d4b1aee5cddf54.jpeg',
    'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
    'https://ww3.sinaimg.cn/mw690/6c79248dly1iba2jh0rpzj20wr0wb42e.jpg',
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fci.xiaohongshu.com%2F0f978950-9630-58ff-e79a-3ac8f7dfbfcc%3FimageView2%2F2%2Fw%2F1080%2Fformat%2Fjpg&refer=http%3A%2F%2Fci.xiaohongshu.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto',
  ];

  @override
  void initState() {
    super.initState();
    _all = _buildDemoContacts();
    _rebuildVisible('');
    _searchController.addListener(() => _rebuildVisible(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MutualFollowContact> _buildDemoContacts() {
    final names = <String>[
      'Aaron 测试',
      '艾米莉',
      '宝贝',
      '白鸟',
      '北大师兄',
      '蔡明浩',
      '曹操',
      'CF 张琦 (通行证)',
      '陈晨',
      '哆啦A梦',
      '杜甫',
      'Echo 工作室',
      '范范',
      '菲菲',
      '郭德纲',
      '高通',
      '韩寒',
      'IU 粉丝站',
      'Jack',
      '橘子味夏天',
      '孔子',
      '李白',
      '刘诗诗',
      'Mike',
      '慕容雪',
      '哪吒',
      '欧阳锋',
      '彭于晏',
      '秦朝',
      '屈原',
      '孙悟空',
      '唐朝',
      '汤圆',
      '王羲之',
      '夏日微风',
      '小希',
      '薛之谦',
      '徐志摩',
      '杨洋',
      '易烊千玺',
      '薛之谦工作室',
      '周星驰',
      '诸葛亮',
    ];

    final raw = <MutualFollowContact>[];
    for (var i = 0; i < names.length; i++) {
      final name = names[i];
      raw.add(
        MutualFollowContact(
          id: 'mf_$i',
          name: name,
          avatarUrl: _demoAvatars[i % _demoAvatars.length],
          tag: _tagForName(name),
        ),
      );
    }
    SuspensionUtil.sortListBySuspensionTag(raw);
    SuspensionUtil.setShowSuspensionStatus(raw);
    return raw;
  }

  void _rebuildVisible(String query) {
    final next = query.trim().isEmpty
        ? List<MutualFollowContact>.from(_all)
        : _all.where((e) => mutualFollowMatchesQuery(e, query)).toList();
    SuspensionUtil.sortListBySuspensionTag(next);
    SuspensionUtil.setShowSuspensionStatus(next);
    setState(() => _visible = next);
  }

  void _toggle(MutualFollowContact c) {
    setState(() {
      if (_selectedIds.contains(c.id)) {
        _selectedIds.remove(c.id);
      } else {
        _selectedIds.add(c.id);
      }
    });
  }

  bool _isSelected(String id) => _selectedIds.contains(id);

  MutualFollowContact? _byId(String id) {
    for (final c in _all) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _onCreateGroup() {
    if (_selectedIds.isEmpty) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text('建群（演示）：已选 ${_selectedIds.length} 人')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final count = _selectedIds.length;

    return WithStatusbarColorView(
      statusBarColor: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, top, count),
            _buildSearchRow(),
            Divider(height: 1.h, thickness: 1, color: const Color(0xFFE5E5EA)),
            Expanded(child: _buildAzList()),
          ],
        ),
      ),
    );
  }

  /// 标题绝对水平居中：左右占位同宽（取右侧「建群」最大宽度），避免 `Expanded + Text` 视觉偏移。
  Widget _buildHeader(BuildContext context, double statusBarHeight, int count) {
    const title = '选择互相关注的人';
    final rightLabel = '建群 ($count)';
    final rightStyleActive = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: SelectMutualFollowersPage.accentPink,
    );
    final rightStyleDisabled = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFC7C7CC),
    );

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA))),
      ),
      child: SizedBox(
        height: 44.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120.w.clamp(72.w, 140.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(22.r),
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.w, right: 8.w),
                          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18.r, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 120.w.clamp(72.w, 140.w),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: count > 0 ? _onCreateGroup : null,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          rightLabel,
                          style: count > 0 ? rightStyleActive : rightStyleDisabled,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IgnorePointer(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 已选头像条占宽：避免 `Flexible(flex:1)` 与 `Expanded` 对半分行导致与输入框间距过大。
  double _selectedAvatarsBarWidth(int count) {
    if (count <= 0) return 0;
    return count * 32.r + (count - 1) * 6.w;
  }

  Widget _buildSearchRow() {
    final sheetW = MediaQuery.sizeOf(context).width;
    final rowPad = 12.w * 2;
    final gap = 10.w;
    final maxBar = (sheetW - rowPad - gap) * 0.55;
    final barW = _selectedIds.isEmpty ? 0.0 : _selectedAvatarsBarWidth(_selectedIds.length).clamp(0.0, maxBar);

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_selectedIds.isNotEmpty)
            SizedBox(
              height: 36.h,
              width: barW,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedIds.length,
                separatorBuilder: (context, index) => SizedBox(width: 6.w),
                itemBuilder: (context, i) {
                  final c = _byId(_selectedIds[i]);
                  if (c == null) return const SizedBox.shrink();
                  return ClipOval(
                    child: ExtendedImage.network(
                      c.avatarUrl,
                      width: 32.r,
                      height: 32.r,
                      fit: BoxFit.cover,
                      loadStateChanged: (state) {
                        if (state.extendedImageLoadState == LoadState.failed) {
                          return ColoredBox(
                            color: const Color(0xFFE5E5EA),
                            child: Icon(Icons.person, size: 18.r, color: Colors.white70),
                          );
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
            ),
          if (_selectedIds.isNotEmpty) SizedBox(width: gap),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontSize: 15.sp, color: Colors.black87),
              decoration: InputDecoration(
                isDense: true,
                hintText: '搜索',
                hintStyle: TextStyle(fontSize: 15.sp, color: const Color(0xFFC7C7CC)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzList() {
    if (_visible.isEmpty) {
      return Center(
        child: Text('无匹配联系人', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF8E8E93))),
      );
    }

    final indexLetters = SuspensionUtil.getTagIndexList(_visible);
    final sheetW = MediaQuery.sizeOf(context).width;

    return AzListView(
      key: ValueKey<String>('${_searchController.text}_${_visible.length}_${_visible.first.id}'),
      data: _visible,
      itemCount: _visible.length,
      padding: EdgeInsets.only(right: 20.w),
      susItemHeight: _susHeaderHeight,
      susItemBuilder: (context, index) {
        final bean = _visible[index];
        return SizedBox(
          width: sheetW,
          height: _susHeaderHeight,
          child: Container(
            width: sheetW,
            color: Colors.white,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              bean.getSuspensionTag(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ),
        );
      },
      itemBuilder: (context, index) {
        final c = _visible[index];
        final sel = _isSelected(c.id);
        return Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => _toggle(c),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  _checkCircle(sel),
                  SizedBox(width: 12.w),
                  ClipOval(
                    child: ExtendedImage.network(
                      c.avatarUrl,
                      width: 44.r,
                      height: 44.r,
                      fit: BoxFit.cover,
                      loadStateChanged: (state) {
                        if (state.extendedImageLoadState == LoadState.failed) {
                          return Container(
                            width: 44.r,
                            height: 44.r,
                            color: const Color(0xFFE5E5EA),
                            child: Icon(Icons.person, size: 24.r, color: Colors.white70),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      c.name,
                      style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      hapticFeedback: true,
      indexBarData: indexLetters,
      indexBarWidth: 18.w,
      indexBarOptions: IndexBarOptions(
        textStyle: TextStyle(fontSize: 11.sp, color: const Color(0xFF8E8E93)),
        selectTextStyle: TextStyle(fontSize: 12.sp, color: SelectMutualFollowersPage.accentPink, fontWeight: FontWeight.w600),
        selectItemDecoration: const BoxDecoration(color: Colors.transparent),
      ),
    );
  }

  Widget _checkCircle(bool selected) {
    const pink = SelectMutualFollowersPage.accentPink;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? pink : Colors.transparent,
        border: Border.all(
          color: selected ? pink : const Color(0xFFC7C7CC),
          width: 1.5,
        ),
      ),
      child: selected ? Icon(Icons.check_rounded, size: 15.r, color: Colors.white) : null,
    );
  }
}
