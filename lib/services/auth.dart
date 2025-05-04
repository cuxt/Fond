import 'package:flutter/material.dart';
import 'package:fond/widgets/toast/fond_toast.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

class Auth {
  static Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception("用户名或密码不能为空");
    }

    Dio dio = Dio();

    String hexMd5(String input) {
      // 将输入字符串编码为UTF-8
      var bytes = utf8.encode(input);
      // 创建MD5哈希对象
      var digest = md5.convert(bytes);
      // 返回MD5加密结果的十六进制表示
      return digest.toString();
    }

    String encode(String input) {
      // 模数和公钥指数
      final modulus = BigInt.parse(
        "CB99A3A4891FFECEDD94F455C5C486B936D0A37247D750D299D66A711F5F7C1EF8C17EAFD2E1552081DFFD1F78966593D81A499B802B18B0D76EF1D74F217E3FD98E8E05A906245BEDD810557DFB8F653118E59293A08C1E51DDCFA2CC13251A5BE301B080A0C93A587CB71BAED18AEF9F1E27DA6877AFED6BC5649DB12DD021",
        radix: 16,
      );
      final publicExponent = BigInt.parse("10001", radix: 16);
      // 创建RSA公钥
      final publicKey = RSAPublicKey(modulus, publicExponent);
      // 使用RSA加密
      final encrypter = Encrypter(RSA(publicKey: publicKey));
      final encrypted = encrypter.encrypt(input);
      // 返回加密后的字符串
      return encrypted.base64;
    }

    final url = "http://ft.10jqka.com.cn/thsft/jgbservice";

    final encodeName = encode(username);
    final encodePassword = encode(hexMd5(password));

    final params = {
      "reqtype": "verify",
      "account": encodeName,
      "passwd": encodePassword,
      "qsid": "800",
      "securities": "同花顺iFinD",
      "jgbversion": "1.10.12.405",
      "Encrypt": "1",
    };

    try {
      Response<List<int>> response = await dio.get<List<int>>(
        url,
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );

      // 检查响应状态码
      if (response.statusCode != 200) {
        FondToast.show('请求失败，状态码: ${response.statusCode}');
        return false;
      }

      // 确保响应数据不为空
      if (response.data == null || response.data!.isEmpty) {
        FondToast.show('服务器返回数据为空');
        return false;
      }

      String decodedString = gbk.decode(response.data!);

      // 解析 XML 数据
      final document = XmlDocument.parse(decodedString);

      // 确保能找到必要的XML元素
      final verifyElements = document.findElements('verify');
      if (verifyElements.isEmpty) {
        FondToast.show('服务器返回数据格式错误');
        return false;
      }

      final verifyElement = verifyElements.first;
      final retElements = verifyElement.findElements('ret');

      if (retElements.isEmpty) {
        FondToast.show('服务器返回数据不包含结果信息');
        return false;
      }

      final retElement = retElements.first;
      final code = retElement.getAttribute('code');
      final msg = retElement.getAttribute('msg') ?? '未知错误';

      // 根据返回码判断登录是否成功
      if (code == '0') {
        // 登录成功情况
        FondToast.show('登录成功');
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          Map<String, String> cookieMap = {};

          for (var rawCookie in cookies) {
            // 删除空格，分号分割
            List<String> parts = rawCookie.replaceAll(' ', '').split(';');
            for (var part in parts) {
              if (part.contains('=')) {
                List<String> keyValue = part.split('=');
                if (keyValue.length == 2) {
                  String key = keyValue[0].trim();
                  String value = keyValue[1].trim();
                  cookieMap[key] = value;
                }
              }
            }
          }

          debugPrint('登录成功 - cookie: $cookieMap');
          // 保存cookie到本地
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cookie', jsonEncode(cookieMap));
        }

        return true;
      } else {
        debugPrint('登录响应 - code: $code, msg: $msg');
        FondToast.show('登录失败: $msg');
        return false;
      }
    } catch (e) {
      // 捕获并处理所有异常
      debugPrint('登录异常: ${e.toString()}');
      FondToast.show('登录失败: ${e.toString()}');
      return false;
    }
  }
}
