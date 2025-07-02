import '../utils/dio/request.dart' show Request;
import 'package:dio/dio.dart' show Options;
import '../models/common.m.dart';

// 获取素材进行合成
Future<Object> getVideoAndMaterial(params) async {
  return Request.get('/tool/v1/video/tool/getVideoAndMaterial', queryParameters: params);
}
