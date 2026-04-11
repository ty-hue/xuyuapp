
import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/utils/DioRequest.dart';
import 'package:bilbili_project/viewmodels/Settings/index.dart';


// 通用请求协议方法
Future<AgreementModel> getAgreementByType(int type) async {
  final response = await dioRequest.get(HttpConstants.GET_AGREEMENT, queryParameters: {'type': type});
  return  AgreementModel.fromJson(response as Map<String, dynamic>);
}

