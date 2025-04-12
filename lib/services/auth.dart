import 'package:oktoast/oktoast.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';
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

      String decodedString = gbk.decode(response.data!);
      // 解析 XML 数据
      final document = XmlDocument.parse(decodedString);
      final verifyElement = document.findElements('verify').first;
      final retElement = verifyElement.findElements('ret').first;
      final code = retElement.getAttribute('code');
      final msg = retElement.getAttribute('msg');

      if (response.statusCode == 200) {
        if (code == '-1') {
          showToast(msg!);
          return false;
        }
        // 请求成功，处理响应数据
        showToast('登录成功');
        return true;
      } else {
        // 请求失败，处理错误
        showToast('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      showToast(e.toString());
    }

    return false;
  }
}
