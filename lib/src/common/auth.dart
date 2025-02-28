import 'package:cruise/src/common/net/rest/rest_clinet.dart';
import 'package:cruise/src/models/api/login_type.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cruise/src/common/config/global_config.dart' as global;
import 'config/global_config.dart';
import 'cruise_user.dart';
import 'net/rest/http_result.dart';

class AuthResult {
  String message;
  Result result;

  AuthResult({
    required this.message,
    required this.result,
  });
}

class Auth {
  final baseUrl = global.baseUrl;
  static RegExp validationRequired = RegExp(r"Validation required");

  static Future<bool> isLoggedIn() async {
    final storage = new FlutterSecureStorage();
    String? username = await storage.read(key: "username");
    if(username == null){
      return true;
    }else{
      return false;
    }
  }

  static Future<CruiseUser> currentUser() async {
    final storage = new FlutterSecureStorage();
    String? userName = await storage.read(key: "username");
    String? registerTime = await storage.read(key: "registerTime");
    CruiseUser user = new CruiseUser(phone: userName,registerTime:registerTime );
    return user;
  }

  static Future<AuthResult> vote({required String itemId}) async {
    Map body = {
      "id": itemId
    };
    final response = await RestClient.putHttp("/post/article/upvote",body);
    if (RestClient.respSuccess(response)) {
      return AuthResult(message: "SMS send success", result: Result.ok);
    } else {
      return AuthResult(
          message: "SMS send failed. Did you mistype your credentials?",
          result: Result.error);
    }
  }

  static Future<bool> logout() async {
    final storage = new FlutterSecureStorage();
    await storage.delete(key: "username");
    await storage.delete(key: "password");
    await storage.delete(key: "registerTime");
    return true;
  }

  static Future<AuthResult> sms({required String phone}) async {
    Map body = {
      "phone": phone
    };
    final response = await RestClient.postHttp("/post/user/sms",body);
    if (RestClient.respSuccess(response)) {
      final storage = new FlutterSecureStorage();
      await storage.write(key: "phone", value: phone);
      return AuthResult(message: "SMS send success", result: Result.ok);
    } else {
      return AuthResult(
          message: response.data["msg"],
          result: Result.error);
    }
  }

  static Future<AuthResult> setPwd({required String phone, required String password}) async {
    Map body = {
      "phone": phone,
      "password": password,
      "goto": 'news',
    };
    final response = await RestClient.postHttp("/post/user/set/pwd",body);
    if (RestClient.respSuccess(response)) {
      final storage = new FlutterSecureStorage();
      await storage.write(key: "username", value: phone);
      await storage.write(key: "password", value: password);
      return AuthResult(message: "Login success", result: Result.ok);
    }  else {
      return AuthResult(
          message: "Login failed. Did you mistype your credentials?",
          result: Result.error);
    }
  }

  static Future<AuthResult> verifyPhone({required String phone, required String verifyCode}) async {
    Map body = {
      "phone": phone,
      "verifyCode": verifyCode,
      "goto": 'news',
    };
    final response = await RestClient.postHttp("/post/user/verify",body);
    if (RestClient.respSuccess(response)) {
      final storage = new FlutterSecureStorage();
      await storage.write(key: "phone", value: phone);
      await storage.write(key: "verifyCode", value: verifyCode);
      return AuthResult(message: "Login success", result: Result.ok);
    } else {
      return AuthResult(
          message: "Login failed. Did you mistype your credentials?",
          result: Result.error);
    }
  }

  static Future<AuthResult> login({required String username, required String password, required LoginType loginType}) async {
    Map body = {
      "phone": username,
      "password": password,
      "goto": 'news',
      "loginType": loginType.statusCode
    };
    final response = await RestClient.postHttpNewDio("/post/user/login",body);
    if (RestClient.respSuccess(response)) {
      Map result = response.data["result"];
      String token = result["token"];
      String registerTime = result["registerTime"];
      await storage.write(key: "username", value: username);
      await storage.write(key: "password", value: password);
      await storage.write(key: "token", value: token);
      await storage.write(key: "registerTime", value: registerTime);
      return AuthResult(message: "Login success", result: Result.ok);
    } else {
      return AuthResult(
          message: "Login failed. Did you mistype your credentials?",
          result: Result.error);
    }
  }
}
