import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

Logger logger = Logger();
String apiUrl = "https://tollapi-3.onrender.com/api/";
const String tosteError = "Something Went Wrong!";

class ApiMethod {
  static const String GET = "GET";
  static const String POST = "POST";
  static const String PUT = "PUT";
  static const String PATCH = "PATCH";
  static const String DELETE = "DELETE";
}

class ApiRequest {
  final String url;
  String? method;
  var body;
  final Dio dio = Dio();

  ApiRequest(this.url, {this.method, this.body});

  Future<Response> send<T>() async {
    logger.i(
      url,
      time: DateTime.now(),
      error: body,
    );
    try {
      Response data = await dio.request<T>(
        url,
        data: body,  // Send the body as JSON
        options: Options(
          method: method ?? ApiMethod.GET,
          // headers: {
          //   'Content-Type': 'application/json',  // JSON format
          //   'Authorization': 'Bearer your_token_here',  // Replace with actual token logic
          // },
        ),
      );
      logger.f(data.data,
          time: DateTime.now(), error: "This Is Response, Method : $method");
      return data;
    } on DioException catch (e) {
      logger.e(e.response?.data, error: e.error, stackTrace: e.stackTrace);
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }
}
