import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/tool/resolve_cdn.dart';
import 'dart:convert';

class CxFiveCategoryPopup extends StatefulWidget {

  final BuildContext context;
  final List<Map<String, dynamic>> categoryList;
  final Function(List<dynamic>)? onCategorySelected;

  CxFiveCategoryPopup({
    Key? key,
    required this.context,
    required this.categoryList,
    this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CxFiveCategoryPopup> createState() => CxFiveCategoryPopupState();
}

class CxFiveCategoryPopupState extends State<CxFiveCategoryPopup> {
  List<dynamic> currentCategoryList = [];
  StateSetter? _modalSetState;
  List<Map<String, dynamic>> typeList = [];
  List<dynamic> selectCategoryList = [];

  Future<void> showCategoryBottomSheet() async {
    setState(() {
      currentCategoryList = widget.categoryList;
      typeList = [];
    });
    showModalBottomSheet(
      context: widget.context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(widget.context).size.height * 0.95,
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
              return buildCategoryListItems();
            }
        );
      },
    );
  }

  void _nextCategory(item) {
    List<dynamic> deepCopy = json.decode(json.encode(currentCategoryList));

    _modalSetState?.call(() {
      typeList = [...typeList, {
        ...item,
        'fatherCategoryList': deepCopy,
      }];
      currentCategoryList = item['sub_categories'];
    });
  }

  void _onSelectType(index) {
    if (index == -1) {
      return;
    }
    _modalSetState?.call(() {
      currentCategoryList = typeList[index]['fatherCategoryList'];
      typeList.removeRange(index, typeList.length);
    });
  }

  void _onSelectBox(item) {
    if (selectCategoryList.isNotEmpty) {
      if (selectCategoryList[selectCategoryList.length - 1]['cat_name'] == item['cat_name']) {
        return;
      }
    }
    _modalSetState?.call(() {
      List<dynamic> typeListCopy = [];
      for (var type in typeList) {
        typeListCopy.add(Map<String, dynamic>.from(type));
      }
      selectCategoryList = [...typeListCopy, item];
    });
  }

  bool isSelectColor(item) {
    if (selectCategoryList.isEmpty) {
      return false;
    }
    if (typeList.length >= selectCategoryList.length) {
      return false;
    }
    if (selectCategoryList[typeList.length]['cat_name'] == item['cat_name']) {
      return true;
    }
    return false;
  }

  bool _isCheckFunc(item) {
    if (selectCategoryList.isEmpty) {
      return false;
    }
    if (item['cat_name'] == selectCategoryList[selectCategoryList.length - 1]['cat_name']) {
      return true;
    }
    return false;
  }

  String _isSelectText() {
    if (selectCategoryList.isEmpty) {
      return '';
    }
    return selectCategoryList[selectCategoryList.length - 1]['cat_name'];
  }

  void _onResetList() {
    _modalSetState?.call(() {
      selectCategoryList = [];
      typeList = [];
      currentCategoryList = widget.categoryList;
    });
  }

  Widget buildCategoryListItems() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            decoration: BoxDecoration(
              // border: Border(
              //   bottom: BorderSide(
              //     color: Color(0xFFEEEEEE),
              //     width: 1,
              //   ),
              // ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '商品类目',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 20.w, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 8.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromRGBO(242, 242, 242, 1),
                      width: 1,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ...List.generate(
                        typeList.length,
                            (index) => _buildTypeInput(index),
                      ),
                      _buildTypeInput(-1)
                    ],
                  ),
                ),
              ),
              Container(
                height: 300.h,
                constraints: BoxConstraints(
                  maxHeight: 300.h,
                ),
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: currentCategoryList.map((item) => Container(
                        height: 40.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _onSelectBox(item),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18.w,
                                    height: 18.h,
                                    margin: EdgeInsets.only(left: 12.w, right: 4.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1,color: _isCheckFunc(item) ? Colors.transparent : Color(0xFF999999)),
                                      color: _isCheckFunc(item) ? Color(0xFFa5df2a) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(40)
                                    ),
                                    child: Center(
                                      child: _isCheckFunc(item) ? Icon(Icons.check, color: Colors.white, size: 14) : Container(),
                                    ),
                                  ),
                                  Text(
                                    item['cat_name'] ?? '',
                                    style: TextStyle(
                                      color: isSelectColor(item) ? Color(0xFFa5df2a) : Color(0xFF333333),
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (item['sub_categories'].isNotEmpty)
                            Row(
                              children: [
                                Container(
                                  width: 1.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFf2f2f2)
                                  ),
                                ),
                                SizedBox(width: 12.w,),
                                GestureDetector(
                                  onTap: () => _nextCategory(item),
                                  child: Row(
                                    children: [
                                      Text('下级', style: TextStyle(color: Color(0xFF999999), fontSize: 14.sp)),
                                      SizedBox(width: 12.w,),
                                      Image.network('https://cdn-static.chanmama.com/sub-module/static-file/2/d/d921a02333', width: 5.w, height: 8.h),
                                      SizedBox(width: 12.w,),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Container(
                height: 110.h,
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 12.h,
                  // bottom: MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFEEEEEE),
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('已选:', style: TextStyle(color: Color(0xFFbabbbc), fontSize: 12.sp)),
                        SizedBox(width: 4.w),
                        Text(_isSelectText(), style: TextStyle(color: Color(0xFF333333), fontSize: 12.sp)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
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
                                child: Text('重置', style: TextStyle(color: Color(0xFF4E5969), fontSize: 14.sp)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              widget.onCategorySelected?.call(selectCategoryList);
                            },
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
                    SizedBox(height: 12.h)
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTypeInput(index) {
    return GestureDetector(
      onTap: () => _onSelectType(index),
      child: Container(
        padding: EdgeInsets.only(left: 12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(index == -1 ? _backNumber() : typeList[index]['cat_name'], style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                SizedBox(width: 8.w),
                if (index != -1)
                Image.network(resolveCDN('@cdn?2dd921a02333'), width: 5.w, height: 8.h),
              ],
            ),
            Container(
              width: 30.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 8.h),
              decoration: BoxDecoration(
                color: index == -1 ? Color(0xFFA5DF2A) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _backNumber() {
    if (typeList.length == 0) {
      return '一级类目';
    }
    if (typeList.length == 1) {
      return '二级类目';
    }
    if (typeList.length == 2) {
      return '三级类目';
    }
    if (typeList.length == 3) {
      return '四级类目';
    }
    if (typeList.length == 4) {
      return '五级类目';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
