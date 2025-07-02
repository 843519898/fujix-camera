import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../components/cx-components-ui/cx-five-category-popup/cx-five-category-popup.dart';
import '../../../../utils/tool/resolve_cdn.dart';
import 'dart:convert';
import '../../../../services/common_service.dart'; // 接口


class FilterHotPopup extends StatefulWidget {
  final BuildContext context;
  final String currentTabs;
  final Function()? onSelectedFunc;

  FilterHotPopup({
    Key? key,
    required this.context,
    required this.currentTabs,
    this.onSelectedFunc,
  }) : super(key: key);

  @override
  State<FilterHotPopup> createState() => FilterHotPopupState();
}

class FilterHotPopupState extends State<FilterHotPopup> {
  final GlobalKey<CxFiveCategoryPopupState> _childKey = GlobalKey();
  List<Map<String, dynamic>> categoryList = [];
  List<dynamic> selectedCategoryList = [];
  StateSetter? _modalSetState;
  List<dynamic> dayList = [
    {
      'name': '昨日',
      'value': '1',
    },
    {
      'name': '近3天',
      'value': '3',
    },
    {
      'name': '近7天',
      'value': '7',
    },
    {
      'name': '近15天',
      'value': '15',
    },
    {
      'name': '近30天',
      'value': '30',
    },
  ];
  String date_type = '1';

  List<dynamic> hoursList = [
    {
      'name': '近1小时',
      'value': '1',
    },
    {
      'name': '近3天',
      'value': '3',
    },
  ];
  String date_hour_type = '1';

  List<dynamic> rankList = [
    {
      'name': '实时',
      'value': '1',
    },
    {
      'name': '飙升',
      'value': '2',
    },
  ];
  String rank_type = '1';

  @override
  void initState() {
    super.initState();
    getType5();
  }

  Future<void> showBottomSheet() async {
    showModalBottomSheet(
      context: widget.context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(widget.context).size.height * 0.6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
        ),
      ),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              _modalSetState = setModalState;
              return buildListItems();
            }
        );
      },
    );
  }

  Map<String, dynamic> getParams() {
    if (widget.currentTabs == '3') {
      return {
        'date_type': date_type,
        'category_id': selectedCategoryList.isNotEmpty ? selectedCategoryList[selectedCategoryList.length - 1]['id'].toString() : '-1',
      };
    } else if (widget.currentTabs == '2') {
      return {
        'date_type': date_hour_type,
        'date_hour_type': date_hour_type == '1' ? date_hour_type : '',
      };
    } else if (widget.currentTabs == '1') {
      return {
        'rank_type': rank_type,
      };
    } else if (widget.currentTabs == '4') {
      return {
        'date_type': date_type,
        'rank_type': rank_type,
        'category_id': selectedCategoryList.isNotEmpty ? selectedCategoryList[selectedCategoryList.length - 1]['id'].toString() : '-1',
      };
    }
    return {};
  }

  void _onResetList() {
    _modalSetState?.call(() {
      date_type = '1';
      date_hour_type = '1';
      selectedCategoryList = [];
    });
  }

  void _onSubmit() {
    Navigator.pop(context);
    widget.onSelectedFunc?.call();
  }

  String _onCateGoryText() {
    if (selectedCategoryList.isEmpty) {
      return '';
    }
    return selectedCategoryList[selectedCategoryList.length - 1]['cat_name'];
  }

  void _onDayInput(index) {
    _modalSetState?.call(() {
      date_type = dayList[index]['value'];
    });
  }

  void _onHoursInput(index) {
    _modalSetState?.call(() {
      date_hour_type = hoursList[index]['value'];
    });
  }

  void _onRankInput(index) {
    _modalSetState?.call(() {
      rank_type = rankList[index]['value'];
    });
  }

  void _onChangeParams() {
    // widget.onTypeChange({
    //   'sort': _currentTabs,
    //   'order_by': 'desc',
    //   'time': _dayList[_currentDayIndex]['value'],
    //   'category_id': selectedCategoryList.isNotEmpty ? selectedCategoryList[selectedCategoryList.length - 1]['id'] : '-1',
    // });
  }

  Future<void> getType5() async {
    try {
      final res = await getFiveCategoryList({
        'deep': 2,
      });
      final dynamic list = res is Map ? res['data'] : null;
      if (list != null) {
        setState(() {
          categoryList = List<Map<String, dynamic>>.from(list);
        });
      }
    } catch (e) {
      print('获取类目列表失败: $e');
    }
  }

  Widget buildListItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50.h,
          child: Center(
            child: Text('热点筛选', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16.sp)),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.currentTabs == '1' || widget.currentTabs == '4')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h,),
                    Container(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Text('热度排序', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                    ),
                    SizedBox(height: 12.h,),
                    Row(
                      children: [
                        ...List.generate(
                          rankList.length,
                              (index) => _buildRankInput(index),
                        ),
                      ],
                    )
                  ],
                ),
              if (widget.currentTabs == '3' || widget.currentTabs == '4')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h,),
                    Container(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Text('行业', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      height: 40.h,
                      margin: EdgeInsets.only(left: 12.w, right: 12.w),
                      padding: EdgeInsets.only(left: 8.w, right: 8.w),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.w, color: Color(0xFFE5E6EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_onCateGoryText(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _childKey.currentState?.showCategoryBottomSheet();
                                },
                                child: Row(
                                  children: [
                                    Text('去选择', style: TextStyle(color: Color(0xFF86909C), fontWeight: FontWeight.w600, fontSize: 12.sp)),
                                    SizedBox(width: 4.w),
                                    Image.network('https://cdn-static.chanmama.com/sub-module/static-file/3/1/659afa8712', width: 14.w, height: 14.h),
                                  ],
                                ),
                              ),
                              CxFiveCategoryPopup(
                                key: _childKey,
                                context: context,
                                categoryList: categoryList,
                                onCategorySelected: (selectedCategories) {
                                  // 在这里处理选中的类目数据
                                  _modalSetState?.call(() {
                                    selectedCategoryList = selectedCategories;
                                  });
                                  _onChangeParams();
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h,),
                  ],
                ),
              if (widget.currentTabs != '1')
              Container(
                padding: EdgeInsets.only(left: 12.w),
                child: Text('时间', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14.sp)),
              ),
              SizedBox(height: 12.h,),
              Row(
                children: [
                  if (widget.currentTabs == '3' || widget.currentTabs == '4')
                  ...List.generate(
                    dayList.length,
                        (index) => _buildDayInput(index),
                  ),
                  if (widget.currentTabs == '2')
                    ...List.generate(
                      hoursList.length,
                          (index) => _buildHoursInput(index),
                    ),
                ],
              ),
            ],
          )
        ),
        Container(
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            top: 12.h,
            bottom: MediaQuery.of(context).padding.bottom + 24.h,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide( // 只设置上边框
                color: Color(0xFFF7F8FA),
                width: 1,
              ),
            )
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _onResetList(),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F3F5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text('清空', style: TextStyle(color: Color(0xFF4E5969), fontSize: 14.sp)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => _onSubmit(),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF22262C),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text('确定', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ]
    );
  }

  Widget _buildDayInput(index) {
    return GestureDetector(
      onTap: () => _onDayInput(index),
      child: Container(
        padding: EdgeInsets.only(left: 8.w, right: 8.w),
        margin: EdgeInsets.only(left: 12.w),
        height: 40.h,
        decoration: BoxDecoration(
          color: date_type == dayList[index]['value'] ? Color(0xFFEDFBDC) : Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(dayList[index]['name'], style: TextStyle(color: Colors.black, fontSize: 14.sp)),
        ),
      ),
    );
  }

  Widget _buildHoursInput(index) {
    return GestureDetector(
      onTap: () => _onHoursInput(index),
      child: Container(
        padding: EdgeInsets.only(left: 8.w, right: 8.w),
        margin: EdgeInsets.only(left: 12.w),
        height: 40.h,
        decoration: BoxDecoration(
          color: date_hour_type == hoursList[index]['value'] ? Color(0xFFEDFBDC) : Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(hoursList[index]['name'], style: TextStyle(color: Colors.black, fontSize: 14.sp)),
        ),
      ),
    );
  }

  Widget _buildRankInput(index) {
    return GestureDetector(
      onTap: () => _onRankInput(index),
      child: Container(
        padding: EdgeInsets.only(left: 8.w, right: 8.w),
        margin: EdgeInsets.only(left: 12.w),
        height: 40.h,
        decoration: BoxDecoration(
          color: rank_type == rankList[index]['value'] ? Color(0xFFEDFBDC) : Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(rankList[index]['name'], style: TextStyle(color: Colors.black, fontSize: 14.sp)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
