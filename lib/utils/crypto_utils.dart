import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class CryptoUtils {
  static const String _defaultKey = '9rDal3705V6xVMLL';

  /// AES加密
  static String aesEncrypt(String text, {String keyWord = _defaultKey}) {
    try {
      // 创建密钥和IV
      final key = Key.fromUtf8(keyWord);
      final iv = IV.fromUtf8(keyWord);

      // 创建加密器
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

      // 加密数据
      final encrypted = encrypter.encrypt(text, iv: iv);

      // 获取Base64编码的结果
      final base64Str = encrypted.base64;

      return base64Str;
    } catch (e) {
      print('加密失败: $e');
      return '';
    }
  }

  /// AES解密
  static String aesDecrypt(String ciphertext, {String keyWord = _defaultKey}) {
    try {

      // 检查密文是否为空
      if (ciphertext.isEmpty) {
        print('密文为空');
        return '';
      }

      // 尝试解析JSON
      String actualCiphertext;
      try {
        final jsonData = json.decode(ciphertext);
        if (jsonData is Map && jsonData['data'] != null) {
          actualCiphertext = jsonData['data'].toString();
        } else {
          actualCiphertext = ciphertext;
        }
      } catch (e) {
        actualCiphertext = ciphertext;
      }

      // 清理Base64字符串（移除可能的空格和换行符）
      final cleanCiphertext = actualCiphertext.trim().replaceAll(RegExp(r'\s+'), '');

      // 将密钥转换为Latin1编码的字节数组
      final keyBytes = latin1.encode(keyWord);
      final ivBytes = latin1.encode(keyWord);

      // 创建密钥和IV
      final key = Key(keyBytes);
      final iv = IV(ivBytes);

      // 创建加密器，使用CBC模式和PKCS7填充
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

      try {
        // 尝试直接解密
        final decrypted = encrypter.decrypt64(cleanCiphertext, iv: iv);
        return decrypted;
      } catch (e) {
        // 尝试URL安全的Base64解码
        try {
          final decoded = base64Url.decode(cleanCiphertext);
          final encrypted = Encrypted(decoded);
          final decrypted = encrypter.decrypt(encrypted, iv: iv);
          return decrypted;
        } catch (e) {
          return '';
        }
      }
    } catch (e) {
      print('解密失败: $e');
      return '';
    }
  }

  /// AES加密（兼容CryptoJS版本）
  static String aesEncryptCryptoJS(String text, {String keyWord = _defaultKey}) {
    try {
      // 创建密钥和IV
      final key = Key.fromUtf8(keyWord);
      final iv = IV.fromUtf8(keyWord);

      // 创建加密器，使用CBC模式和PKCS7填充
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

      // 加密数据
      final encrypted = encrypter.encrypt(text, iv: iv);

      // 获取Base64编码的结果
      final base64Str = encrypted.base64;

      return base64Str;
    } catch (e) {
      print('CryptoJS兼容加密失败: $e');
      return '';
    }
  }
}
