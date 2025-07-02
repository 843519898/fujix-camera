import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterGoods extends StatefulWidget {
  final Function(Map<String, dynamic>) onTypeChange;

  const FilterGoods({Key? key, required this.onTypeChange}) : super(key: key);

  @override
  State<FilterGoods> createState() => _FilterGoodsState();
}

class _FilterGoodsState extends State<FilterGoods> {
  bool _isSelected = true;

  final List<Map<String, dynamic>> _SearchList = [
    {
      'title': '综合',
      'value': 9,
    },
    {
      'title': '昨日新星',
      'value': 1,
    },
    {
      'title': '3日潜力',
      'value': 2,
    },
    {
      'title': '7日热销',
      'value': 3,
    },
    {
      'title': '持续好货',
      'value': 4,
    },
    {
      'title': '历史同期',
      'value': 5,
    }
  ];
  int _currentTabs = 9;

  void _onType (index) {
    setState(() {
      _currentTabs = _SearchList[index]['value'];
    });
    _onChangeValue();
  }

  void _onChangeValue () {
    widget.onTypeChange({
      'rank_type': _currentTabs,
      'need_material': _isSelected ? 1 : 0,
    });
  }

  void _toggleSelection () {
    setState(() {
      _isSelected = !_isSelected;
    });
    _onChangeValue();
  }

  Widget _buildInput (index) {
    return GestureDetector(
      onTap: () => _onType(index),
      child: Container(
        height: 26.h,
        padding: const EdgeInsets.only(left: 12, right: 12),
        decoration: BoxDecoration(
          color: _currentTabs == _SearchList[index]['value'] ? const Color(0xFFFFFFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(48),
        ),
        child: Center(
          child: Text(_SearchList[index]['title'], style: TextStyle(color: Color(0xFF949494), fontSize: 12.sp))
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              // clipBehavior: Clip.none,  // 允许子组件超出边界
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...List.generate(
                    _SearchList.length,
                        (index) => _buildInput(index),
                  )
                ],
              )
            )
          ),
          SizedBox(width: 4.w),
          if (_currentTabs != 9)
          Row(
            children: [
              GestureDetector(
                onTap: _toggleSelection,
                child: Container(
                  width: 14.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: _isSelected ? Color(0xFFA1F74A) : Colors.transparent,
                    border: Border.all(
                      color: _isSelected ? Colors.transparent : Color(0xFF999999),
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(4.sp),
                  ),
                  child: _isSelected
                      ? SizedBox(
                    width: 4.w,
                    height: 4.h,
                    child: Image.network('https://cdn-static.chanmama.com/sub-module/static-file/c/a/4dc77c5723'),
                  )
                      : null,
                ),
              ),
              const SizedBox(width: 4),
              Text('有素材', style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
