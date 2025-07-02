import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/tool/resolve_cdn.dart';
import '../../../../components/cx-components-ui/cx-popover/cx-popover.dart';
import '../../../../components/cx-components-ui/cx-five-category-popup/cx-five-category-popup.dart';
import '../../../../services/common_service.dart'; // 接口
import 'dart:convert';

class FilterVideo extends StatefulWidget {
  final Function(Map<String, dynamic>) onTypeChange;
  const FilterVideo({Key? key, required this.onTypeChange}) : super(key: key);

  @override
  State<FilterVideo> createState() => _FilterVideoState();
}

class _FilterVideoState extends State<FilterVideo> {
  final GlobalKey<CxFiveCategoryPopupState> _childKey = GlobalKey();
  List<dynamic> selectedCategoryList = [];

  final List<Map<String, dynamic>> _SearchList = [
    {
      'title': '销量榜',
      'value': 'product_volume',
    },
    {
      'title': '点赞榜',
      'value': 'digg_count',
    },
    {
      'title': '评论榜',
      'value': 'comment_count',
    },
  ];
  String _currentTabs = 'product_volume';

  final List<Map<String, dynamic>> _dayList = [
    {
      'title': '全部',
      'index': 0,
      'value': '',
    },
    {
      'title': '近24小时',
      'index': 1,
      'value': '24h',
    },
    {
      'title': '近7天',
      'index': 2,
      'value': '7d',
    },
    {
      'title': '近30天',
      'index': 3,
      'value': '30d',
    },
  ];
  int _currentDayIndex = 2;

  List<Map<String, dynamic>> categoryList = [];

  @override
  void initState() {
    super.initState();
    getType5();
  }

  void _onType(index) {
    setState(() {
      _currentTabs = _SearchList[index]['value'];
    });
    _onChangeParams();
  }

  void _onChangeParams() {
    widget.onTypeChange({
      'sort': _currentTabs,
      'order_by': 'desc',
      'time': _dayList[_currentDayIndex]['value'],
      'category_id': selectedCategoryList.isNotEmpty ? selectedCategoryList[selectedCategoryList.length - 1]['id'] : '-1',
    });
  }

  Widget _buildInput(index) {
    return GestureDetector(
      onTap: () => _onType(index),
      child: Container(
        height: 26.h,
        padding: const EdgeInsets.only(left: 11, right: 11),
        decoration: BoxDecoration(
          color: _currentTabs == _SearchList[index]['value']
              ? const Color(0xFFFFFFFF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(48),
        ),
        child: Center(
            child: Text(_SearchList[index]['title'],
                style: TextStyle(color: Color(0xFF949494), fontSize: 12.sp))),
      ),
    );
  }

  Widget _buildDayInput(index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentDayIndex = index;
          _onChangeParams();
        });
        Navigator.of(context).pop();
      },
      child: Container(
        height: 30.h,
        child: Center(
          child: Text(_dayList[index]['title']),
        ),
      ),
    );
  }

  Future<void> getType5() async {
    try {
      final res = await getFiveCategoryList({
        'deep': 4,
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

  Future<void> _showCategoryBottomSheet() async {
    if (categoryList.isEmpty) {
      await getType5();
    }
    if (categoryList.isNotEmpty) {
      _childKey.currentState?.showCategoryBottomSheet();
      // _childKey.currentState?.showCategoryBottomSheet("来自父组件的调用");
    }
  }

  Widget ListItems () {
    return Column(
      children: [
        ...List.generate(
          _dayList.length,
              (index) => _buildDayInput(index),
        ),
      ],
    );
  }

  void prettyPrint(List data) {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyString = encoder.convert(data);
    print(prettyString);
  }

  String _onCateGoryText() {
    if (selectedCategoryList.isEmpty) {
      return '带货类目';
    }
    return selectedCategoryList[selectedCategoryList.length - 1]['cat_name'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...List.generate(
                      _SearchList.length,
                          (index) => _buildInput(index),
                    ),
                  ],
                )),
                Container(
                  margin: EdgeInsets.only(left: 5.w),
                  width: 1.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFE5E6EB),
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 76.w,
                        margin: const EdgeInsets.only(left: 6),
                        child: GestureDetector(
                          onTap: _showCategoryBottomSheet,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  _onCateGoryText(),
                                  style: TextStyle(color: Color(0xFF999999), fontSize: 12.sp),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Image.network(resolveCDN('@cdn?8b2092f8f08a'), width: 8.w, height: 8.h),
                              CxFiveCategoryPopup(
                                key: _childKey,
                                context: context,
                                categoryList: categoryList,
                                onCategorySelected: (selectedCategories) {
                                  // 在这里处理选中的类目数据
                                  setState(() {
                                    selectedCategoryList = selectedCategories;
                                  });
                                  print('回调事件');
                                  prettyPrint(selectedCategories);
                                  _onChangeParams();
                                },
                              ),
                            ],
                          ),
                        )
                    ),
                    GestureDetector(
                      onTap: () {
                        cxPopover(
                            context: context,
                            bodyBuilder: (context) => ListItems(),
                            onPop: () => print('Popover was popped!'),
                            width: 100.w,
                          position: PopoverPosition.bottomRight,
                        );
                      },
                      child: Container(
                        width: 76.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                _dayList[_currentDayIndex]['title'],
                                style: TextStyle(color: Colors.black, fontSize: 12.sp),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Image.network(resolveCDN('@cdn?8b2092f8f08a'), width: 8.w, height: 8.h),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}
