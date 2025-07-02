import '../utils/dio/request.dart' show Request;
import 'package:dio/dio.dart' show Options;
import '../models/common.m.dart';

// 获取素材库列表
Future<Object> getQueryList(params) async {
  return Request.get('/tool/v1/video/vList', queryParameters: params);
}

// 获取素材库列表
Future<Object> productRank(params) async {
  return Request.get(
    '/tool/v1/product/rank',
    options: Options(extra: {'encrypt': true}),
    queryParameters: params,
  );
}

// 素材库列表
Future<Object> getMaterialList(params) async {
  return Request.get('/tool/v1/video/list', queryParameters: params);
}

// 商品类目分类（五级）
Future<Object> getFiveCategoryList(params) async {
  return Request.get('/tool/v1/common/category/list', queryParameters: params);
}

// 热点
Future<Object> getHotApiList(data) async {
  return Request.post('/tool/v1/ckj/hotspot', data: data);
}

// 热点详情
Future<Object> getHotApiDetail(data) async {
  return Request.post('/tool/v1/ckj/hotspot/detail', data: data);
}

// 随机爆款
Future<Object> getUrlRandom() async {
  return Request.get('/tool/v1/ckj/url/random');
}

// 解析url
Future<Object> getParseUrlToId(data) async {
  return Request.post('/tool/v1/video/tool/parseUrlToId', data: data);
}

// 获取用户信息
Future<Object> getUserInfo() async {
  return Request.get('/tool/v1/user/info');
}

// app版本控制
Future<Object> appCtrl(params) async {
  return Request.get('/tool/v1/user/app/ctrl', queryParameters: params);
}

// 获取app版本号
Future<Object> getAppVersion() async {
  return Request.get('/tool/v1/app/version');
}

// 埋点
Future<Object> reportApi(data) async {
  return Request.post('https://analysis.chanmama.com/v1/report', data: data);
}

// 上传文件
Future<Object> uploadVideo(data) async {
  return Request.post(
    '/digital/oss/upload',
    data: data,
    options: Options(
      contentType: 'multipart/form-data',
    ),
  );
}

// 抖音视频分镜
Future<Object> parseUrlToVideo(data) async {
  return Request.post('/tool/v1/video/tool/parseUrlToVideo', data: data);
}

/// 请求示例
Future<Object> getDemo() async {
  return Request.get(
    '/m1/3617283-3245905-default/pet/1',
    queryParameters: {'corpId': 'e00fd7513077401013c0'},
  );
}

Future<Object> postDemo() async {
  return Request.post('/api', data: {});
}

Future<Object> putDemo() async {
  return Request.put('/api', data: {});
}

/// 获取APP最新版本号, 演示更新APP组件
Future<NewVersionData> getNewVersion() async {
  // TODO: 替换为你的真实请求接口，并返回数据，此处演示直接返回数据
  // var res = await Request.get(
  //   '/api',
  //   queryParameters: {'key': 'value'},
  // ).catchError((e) => resData);
  var resData = NewVersionRes.fromJson({
    "code": "0",
    "message": "success",
    "data": {
      "version": "2.2.4",
      "info": ["修复bug提升性能", "增加彩蛋有趣的功能页面", "测试功能"]
    }
  });
  return (resData.data ?? {}) as NewVersionData;
}
