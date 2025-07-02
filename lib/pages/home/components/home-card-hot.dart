import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/tool/cx_tools.dart';
import 'package:fl_chart/fl_chart.dart';
import './hot-detail-popup.dart';

class HomeCardHot extends StatelessWidget {
  final List<dynamic> hotList;
  final Map searchParams;
  final GlobalKey<HotDetailPopupState> _childKey = GlobalKey();

  // 将构造函数改为非const
  HomeCardHot({
    Key? key,
    required this.hotList,
    required this.searchParams,
  }) : super(key: key);

  void _onButtonClip() {}

  // X轴标签
  SideTitles get _bottomTitles => SideTitles(
    showTitles: false, // 不显示X轴标签
  );

  // Y轴标签
  SideTitles get _leftTitles => SideTitles(
    showTitles: false, // 不显示Y轴标签
  );

  // 根据trends数据生成折线图点
  List<FlSpot> _getSpots(List<dynamic> trends) {
    if (trends == null || trends.isEmpty) {
      return [
        FlSpot(0, 0),
        FlSpot(1, 0),
      ];
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < trends.length; i++) {
      double x = i.toDouble();
      double y = (trends[i]['hot_score'] ?? 0).toDouble();
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    if (hotList.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      children: [
        Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: hotList.indexed.map((entry) {
            final (index, hot) = entry; // 解构语法
            // 获取trends数据
            List<dynamic> trends = hot['trends'] ?? [];

            return GestureDetector(
              onTap: () {
              _childKey.currentState?.showBottomSheet(hot);
            },
              child: Container(
                width: double.infinity,
                height: 90.h,
                decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE6E6E6), width: 1.w),
                    )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24.w,
                          height: 24.h,
                          child: Row(
                            children: [
                              if (index == 0)
                                Image.network(
                                    'https://cdn-static.chanmama.com/sub-module/static-file/f/b/338caf0dab', width: 24.w, height: 24.h
                                ),
                              if (index == 1)
                                Image.network(
                                    'https://cdn-static.chanmama.com/sub-module/static-file/b/7/a287fe7edb', width: 24.w, height: 24.h
                                ),
                              if (index == 2)
                                Image.network(
                                    'https://cdn-static.chanmama.com/sub-module/static-file/7/e/a8991c60dc', width: 24.w, height: 24.h
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${!hot.containsKey('hot_score') ? '#' : ''}${hot['title']}', style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4.w),
                            if (hot.containsKey('hot_score'))
                              Row(
                                children: [
                                  Text('热度值', style: TextStyle(fontSize: 12.sp, color: Color(0xFF999999))),
                                  SizedBox(width: 2.w),
                                  Text(getNumberFloorShow(hot['hot_score']), style: TextStyle(fontSize: 12.sp, color: Color(0xFF999999))),
                                ],
                              ),
                            if (!hot.containsKey('hot_score'))
                              Row(
                                children: [
                                  Text('视频数', style: TextStyle(fontSize: 12.sp, color: Color(0xFF999999))),
                                  SizedBox(width: 2.w),
                                  Text(getNumberFloorShow(hot['relate_video_count']), style: TextStyle(fontSize: 12.sp, color: Color(0xFF999999))),
                                ],
                              )
                          ],
                        )
                      ],
                    ),
                    if (hot.containsKey('hot_score'))
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('近7天热度', style: TextStyle(fontSize: 12.sp, color: Color(0xFF999999))),
                          SizedBox(height: 8.h),
                          Container(
                            width: 90.w,
                            height: 30.h,
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _getSpots(trends),
                                    isCurved: true,
                                    color: Color(0xFFA5DF2A), // 使用绿色
                                    dotData: FlDotData(show: false), // 不显示数据点
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Color(0xFFA5DF2A).withOpacity(0.1), // 添加轻微填充
                                    ),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(sideTitles: _bottomTitles),
                                  leftTitles: AxisTitles(sideTitles: _leftTitles),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(show: false), // 不显示网格
                                borderData: FlBorderData(show: false), // 不显示边框
                                lineTouchData: LineTouchData(enabled: false), // 禁用交互
                              ),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            );
          }
            ).toList(),
          ),
        ),
        HotDetailPopup(
          key: _childKey,
          context: context,
          searchParams: searchParams,
        ),
      ],
    );
  }
}
