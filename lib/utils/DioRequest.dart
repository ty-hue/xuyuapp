import 'package:bilbili_project/constants/index.dart';
import 'package:bilbili_project/utils/TokenManager.dart';
import 'package:dio/dio.dart';

// 基于Dio进行二次封装
class DioRequest {
  final Dio _dio = Dio();
  // 构造方法
  DioRequest() {
    // 配置基础地址
    _dio.options..baseUrl = GlobalConstants.BASE_URL
    // 配置连接超时时间
    ..connectTimeout = Duration(seconds: GlobalConstants.TIME_OUT)
    // 配置响应超时时间
    ..receiveTimeout = Duration(seconds: GlobalConstants.TIME_OUT)
    // 配置发送超时时间
    ..sendTimeout = Duration(seconds: GlobalConstants.TIME_OUT);

    // 拦截器
    _addInterceptor();
  }
  void _addInterceptor() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (request, handler) {
        String token = tokenManager.getToken();
        if(token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
        // 在发送请求之前做些什么
        return handler.next(request); // 继续发送请求
      },
      onResponse: (response, handler) {
        if(response.statusCode! >= 200 && response.statusCode! < 300) {
          return handler.next(response); 
        }
        return handler.reject(DioException(response: response, requestOptions: response.requestOptions)); // 继续处理响应
      },
      onError: (error, handler) {
        // 在响应错误之前做些什么
        return handler.reject(error); // 继续处理错误
      },
    ));
  }
  Future<dynamic> get(String url, {Map<String, dynamic>? queryParameters}) {
      return _handleResponse(_dio.get(url,queryParameters: queryParameters));     
  }
  // post请求
  Future<dynamic> post(String url, {Map<String, dynamic>? data}) {
    return _handleResponse(_dio.post(url,data: data));
  }
  // 处理请求结果方法
  Future<dynamic> _handleResponse(Future<Response<dynamic>> task) async{
    Response<dynamic>  res =  await task;
    Map<String,dynamic> data =  res.data as Map<String,dynamic>;
    if(data['code'] == GlobalConstants.SUCCESS_CODE ){
      // 业务状态成功
      return data['data'];
    }
    throw Exception(data['msg'] ?? '加载数据异常');
  }
}

// 单例对象
final dioRequest = DioRequest();