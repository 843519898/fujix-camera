import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './filter-hot-popup.dart';

class FilterHot extends StatefulWidget {
  final Function(Map<String, dynamic>) onTypeChange;
  const FilterHot({Key? key, required this.onTypeChange}) : super(key: key);

  @override
  State<FilterHot> createState() => _FilterHotState();
}

class _FilterHotState extends State<FilterHot> {
  final GlobalKey<FilterHotPopupState> _childKey = GlobalKey();

  final List<dynamic> _SearchList = [
    {
      'title': '电商热点',
      'value': '3',
    },
    {
      'title': '话题热点',
      'value': '4',
    },
    {
      'title': '种草热点',
      'value': '2',
    },
    {
      'title': '平台热点',
      'value': '1',
    },
  ];
  String _currentTabs = '3';

  void _onType(index) {
    setState(() {
      _currentTabs = _SearchList[index]['value'];
    });
    _onChangeParams();
  }

  Map<String, dynamic> _getParams() {
    final params = _childKey.currentState?.getParams();
    return params ?? {};
  }

  void _onChangeParams() {
    widget.onTypeChange({
      'type': _currentTabs,
      'date_type': '1',
      'category_id': '-1',
      ..._getParams(),
    });
  }

  Widget _buildInput(index) {
    return GestureDetector(
      onTap: () => _onType(index),
      child: Container(
        height: 26.h,
        padding: const EdgeInsets.only(left: 12, right: 12),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 0, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ...List.generate(
                    _SearchList.length,
                        (index) => _buildInput(index),
                  ),
                  Container(
                      width: 1.w,
                      height: 18.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFE5E6EB),
                      )
                  ),
                ],
              )
          ),
          Container(
            width: 60.w,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _childKey.currentState?.showBottomSheet();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network('https://cdn-static.chanmama.com/sub-module/static-file/b/f/2873edf01e', width: 14.w, height: 14.h),
                        SizedBox(width: 2.w),
                        Text('筛选', style: TextStyle(color: Color(0xFF2A480C), fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  FilterHotPopup(
                    key: _childKey,
                    context: context,
                    currentTabs: _currentTabs,
                    onSelectedFunc: () {
                      _onChangeParams();
                    }
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
