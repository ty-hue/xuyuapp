import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MyAssetPickerTextDelegate extends AssetPickerTextDelegate {
  @override
  String get confirm => '确认';  // 自定义确认按钮文本

  @override
  String get cancel => '取消';  // 自定义取消按钮文本

  @override
  String get preview => '预览';  // 自定义预览按钮文本

  @override
  String get emptyList => '没有找到资源';  // 资源列表为空时的文本

  @override
  String get loadFailed => '资源加载失败，请重试';  // 资源加载失败时的提示
}