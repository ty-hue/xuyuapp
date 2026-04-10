import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactsList extends StatefulWidget {
  ContactsList({Key? key}) : super(key: key);

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  static final List<_ContactRowData> _rows = [
    _ContactRowData(
      name: '互动消息',
      time: '26分钟前',
      preview: '海阔天空刚刚点赞了你的评论',
      avatarUrl:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
      interaction: true,
    ),
    _ContactRowData(
      name: '用户昵称',
      time: '26分钟前',
      preview:
          'ListView.builder 的 itemCount 是 frequentContacts.length + 1，所以最后一个 index 等于 frequentContacts.length。',
      avatarUrl:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
    ),
    _ContactRowData(
      name: '李四',
      time: '昨天',
      preview: '好的，明天见。',
      avatarUrl:
          'https://q2.itc.cn/q_70/images03/20250623/337b5e62a9444bcda5d4b1aee5cddf54.jpeg',
    ),
    _ContactRowData(
      name: '特别特别特别特别特别长的用户昵称用于测试省略',
      time: '周一',
      preview: '这是一条预览消息。',
      avatarUrl:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
    ),
    _ContactRowData(
      name: '用户昵称2133',
      time: '26分钟前',
      preview:
          'ListView.builder 的 itemCount 是 frequentContacts.length + 1，所以最后一个 index 等于 frequentContacts.length。',
      avatarUrl:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
    ),
    _ContactRowData(
      name: '李四21312',
      time: '昨天',
      preview: '好的，明天见。',
      avatarUrl:
          'https://q2.itc.cn/q_70/images03/20250623/337b5e62a9444bcda5d4b1aee5cddf54.jpeg',
    ),
    _ContactRowData(
      name: '特别特别特别特别特别长的用户昵称用于测试省略32131',
      time: '周一',
      preview: '这是一条预览消息。',
      avatarUrl:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
    ),
     _ContactRowData(
      name: '特别特别特别特别特别长的用户昵称用于测试省略',
      time: '周一',
      preview: '这是一条预览消息。',
      avatarUrl:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
    ),
    _ContactRowData(
      name: '用户昵称2133',
      time: '26分钟前',
      preview:
          'ListView.builder 的 itemCount 是 frequentContacts.length + 1，所以最后一个 index 等于 frequentContacts.length。',
      avatarUrl:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
    ),
    _ContactRowData(
      name: '李四21312',
      time: '昨天',
      preview: '好的，明天见。',
      avatarUrl:
          'https://q2.itc.cn/q_70/images03/20250623/337b5e62a9444bcda5d4b1aee5cddf54.jpeg',
    ),
    _ContactRowData(
      name: '特别特别特别特别特别长的用户昵称用于测试省略32131',
      time: '周一',
      preview: '这是一条预览消息。',
      avatarUrl:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
    ),
     _ContactRowData(
      name: '特别特别特别特别特别长的用户昵称用于测试省略',
      time: '周一',
      preview: '这是一条预览消息。',
      avatarUrl:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
    ),
    _ContactRowData(
      name: '用户昵称2133',
      time: '26分钟前',
      preview:
          'ListView.builder 的 itemCount 是 frequentContacts.length + 1，所以最后一个 index 等于 frequentContacts.length。',
      avatarUrl:
          'https://q8.itc.cn/q_70/images03/20250114/d9d8d1106f454c2b83ea395927bfc020.jpeg',
    ),
    _ContactRowData(
      name: '李四21312',
      time: '昨天',
      preview: '好的，明天见。',
      avatarUrl:
          'https://q2.itc.cn/q_70/images03/20250623/337b5e62a9444bcda5d4b1aee5cddf54.jpeg',
    ),
    _ContactRowData(
      name: '特别特别特别特别特别长的用户昵称用于测试省略32131',
      time: '周一',
      preview: '这是一条预览消息。',
      avatarUrl:
          'https://wx4.sinaimg.cn/mw690/70e1e519ly1i9xgh6g04ej20sg0sggsj.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _rows.length,
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        itemBuilder: (context, index) {
          final data = _rows[index];
          return Slidable(
            key: ValueKey(data.avatarUrl + data.name),
            groupTag: 'message_contacts',
            closeOnScroll: true,
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.46,
              children: [
                SlidableAction(
                  onPressed: (ctx) {
                    // 置顶
                  },
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  icon: Icons.vertical_align_top_rounded,
                  label: '置顶',
                ),
                SlidableAction(
                  onPressed: (ctx) {
                    // 标为已读
                  },
                  backgroundColor: const Color(0xFF78909C),
                  foregroundColor: Colors.white,
                  icon: Icons.mark_chat_read_outlined,
                  label: '已读',
                ),
                SlidableAction(
                  onPressed: (ctx) {
                    // 删除
                  },
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: '删除',
                ),
              ],
            ),
            child: _ContactRowContent(data: data),
          );
        },
      ),
    );
  }
}

class _ContactRowData {
  const _ContactRowData({
    required this.name,
    required this.time,
    required this.preview,
    required this.avatarUrl,
    this.interaction = false,
  });

  final String name;
  final String time;
  final String preview;
  final String avatarUrl;
  final bool interaction; // 是否为互动消息
}

class _ContactRowContent extends StatelessWidget {
  const _ContactRowContent({required this.data});

  final _ContactRowData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 65.0.w,
            height: 65.0.h,
            decoration: BoxDecoration(
              color: Color.fromRGBO(243, 243, 244, 1),
              shape: BoxShape.circle,
            ),
            child: !data.interaction
                ? CircleAvatar(backgroundImage: NetworkImage(data.avatarUrl))
                : Center(
                    child: Icon(
                      FontAwesomeIcons.heartbeat,
                      size: 24.sp,
                      color: Colors.red,
                    ),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        spacing: 6.h,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                data.time,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color.fromRGBO(105, 105, 105, 1),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data.preview,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: const Color.fromRGBO(
                                      105,
                                      105,
                                      105,
                                      1,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 20.w,
                                height: 20.h,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(child: Text('1', style: TextStyle(fontSize: 12.sp, color: Colors.white),),),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
