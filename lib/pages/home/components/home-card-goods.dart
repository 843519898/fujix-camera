import 'package:flutter/material.dart';
// import 'package:flutter_module/utils/native_bridge.dart';
import 'package:flutter_module/utils/storage_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/tool/cx_tools.dart';
import '../../../routes/route_name.dart';
import '../../../config/app_env.dart';

class HomeCardGoods extends StatelessWidget {
  final List<dynamic> goodsList;
  final Function(Map<String, dynamic>) onOpenHotVideo;
  final Map searchParams;

  const HomeCardGoods({
    Key? key,
    required this.goodsList,
    required this.onOpenHotVideo,
    required this.searchParams,
  }) : super(key: key);

  void _onButtonClip(goods) {
    onOpenHotVideo(goods);
  }

  void _onGoDetail(goods, context) async {
    final Map userInfo = await StorageUtil.getUserInfo();
    final token = userInfo['token'] ?? '';
    bool isLoggedIn = token != '';
    if (isLoggedIn) {
      String product_id = goods['product_id'];
      // Navigator.pushNamed(
      //   context,
      //   RouteName.h5RoutePage,
      //   arguments: {'url': AppEnv.buildGoodsDetailUrl(product_id)},
      // );
    } else {
      // NativeBridge.openUserLogin();
    }
  }

  String _getVolumeText() {
    if (searchParams['rank_type'] == 1) {
      return '昨日销量';
    } else if (searchParams['rank_type'] == 2) {
      return '近3日销量';
    } else if (searchParams['rank_type'] == 3) {
      return '近7日销量';
    } else if (searchParams['rank_type'] == 4) {
      return '近90日销量';
    } else if (searchParams['rank_type'] == 5) {
      return '去年同期销量';
    } else if (searchParams['rank_type'] == 7) {
      return '7日销量';
    }
    return '7日销量';
  }

  @override
  Widget build(BuildContext context) {
    if (goodsList.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children:
            goodsList.map((goods) {
              return GestureDetector(
                onTap: () => _onGoDetail(goods, context),
                child: Container(
                  margin: EdgeInsets.only(top: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // 商品图片
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Image.network(
                          solveCdnImgUrlResize(
                                80,
                                goods['cover'] ?? goods['product_url'] ?? '',
                              ) ??
                              '',
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80.w,
                              height: 80.h,
                              color: Colors.grey[200],
                              child: Icon(Icons.error_outline),
                            );
                          },
                        ),
                      ),
                      // 商品信息
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 12.w),
                          child: Column(
                            children: [
                              Text(
                                goods['title'] ?? '',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Color(0xFF111111),
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.none,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5.h),
                              Row(
                                children: [
                                  Text(
                                    '¥',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff333333),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Text(
                                    '${getJxPriceFromMap(goods)}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff333333),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _getVolumeText(),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff999999),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    getNumberFloorShow(goods['volume']),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.sp,
                                      color: Color(0xff666666),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 20.h,
                                        padding: EdgeInsets.only(
                                          left: 4.w,
                                          right: 4.w,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFFFFD9CC),
                                            width: 0.5,
                                          ),
                                          color: Color(0xFFFFF7F1),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              goods['jx_status'] == 2
                                                  ? '蝉选高佣'
                                                  : '公开佣金',
                                              style: TextStyle(
                                                color: Color(0xFF111111),
                                                fontSize: 10.sp,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              getJxRatioFromMap(goods),
                                              style: TextStyle(
                                                color: Color(0xFFFF5628),
                                                fontSize: 12.sp,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              '%',
                                              style: TextStyle(
                                                color: Color(0xFFFF5628),
                                                fontSize: 12.sp,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        height: 20.h,
                                        padding: EdgeInsets.only(
                                          left: 4.w,
                                          right: 4.w,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFFFFD9CC),
                                            width: 0.5,
                                          ),
                                          color: Color(0xFFFFDDF5),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '赚',
                                              style: TextStyle(
                                                color: Color(0xFF111111),
                                                fontSize: 10.sp,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              '¥',
                                              style: TextStyle(
                                                color: Color(0xFFFF5628),
                                                fontSize: 12.sp,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              getJxFeeFromMap(goods),
                                              style: TextStyle(
                                                color: Color(0xFFEB3D3C),
                                                fontSize: 12.sp,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => _onButtonClip(goods),
                                    child: Container(
                                      width: 80.w,
                                      height: 24.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Color(0xFFF2F3F5),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '一键快剪',
                                          style: TextStyle(
                                            color: Color(0xFF4E5969),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
