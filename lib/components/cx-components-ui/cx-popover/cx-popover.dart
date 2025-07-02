import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum PopoverPosition {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class CxPopover extends StatelessWidget {
  final BuildContext context;
  final Widget Function(BuildContext) bodyBuilder;
  final VoidCallback? onPop;
  final double? width;
  final Offset? offset;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final PopoverPosition position;
  final double arrowSize;
  final Color? arrowColor;
  final double elevation;

  const CxPopover({
    Key? key,
    required this.context,
    required this.bodyBuilder,
    this.onPop,
    this.width,
    this.offset,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.position = PopoverPosition.bottom,
    this.arrowSize = 8.0,
    this.arrowColor,
    this.elevation = 2.0,
  }) : super(key: key);

  RelativeRect _calculatePosition(RenderBox button, RenderBox overlay) {
    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final buttonSize = button.size;
    final screenSize = overlay.size;

    double left = 0;
    double top = 0;
    final popoverWidth = width ?? 200.w;

    // 计算触发元素的中心点
    final buttonCenter = buttonPosition.dx + buttonSize.width / 2;

    switch (position) {
      case PopoverPosition.top:
        left = buttonCenter - (popoverWidth / 2);
        top = buttonPosition.dy - arrowSize;
        break;
      case PopoverPosition.bottom:
        left = buttonCenter - (popoverWidth / 2);
        top = buttonPosition.dy + buttonSize.height + arrowSize - 20;
        break;
      case PopoverPosition.left:
        left = buttonPosition.dx - popoverWidth - arrowSize;
        top = buttonPosition.dy + (buttonSize.height) / 2;
        break;
      case PopoverPosition.right:
        left = buttonPosition.dx + buttonSize.width + arrowSize;
        top = buttonPosition.dy + (buttonSize.height) / 2;
        break;
      case PopoverPosition.topLeft:
        left = buttonPosition.dx;
        top = buttonPosition.dy - arrowSize;
        break;
      case PopoverPosition.topRight:
        left = buttonPosition.dx + buttonSize.width - popoverWidth;
        top = buttonPosition.dy - arrowSize;
        break;
      case PopoverPosition.bottomLeft:
        left = buttonPosition.dx;
        top = buttonPosition.dy + buttonSize.height + arrowSize;
        break;
      case PopoverPosition.bottomRight:
        left = buttonPosition.dx + buttonSize.width - popoverWidth;
        top = buttonPosition.dy + buttonSize.height + arrowSize;
        break;
    }

    // 确保不超出屏幕边界
    left = left.clamp(0.0, screenSize.width - popoverWidth);
    top = top.clamp(0.0, screenSize.height);

    return RelativeRect.fromLTRB(left, top, left + popoverWidth, screenSize.height);
  }

  Widget _buildArrow() {
    return CustomPaint(
      size: Size(arrowSize * 2, arrowSize),
      painter: ArrowPainter(
        position: position,
        color: arrowColor ?? (backgroundColor ?? Colors.white),
      ),
    );
  }

  void show() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = _calculatePosition(button, overlay);

    showMenu(
      context: context,
      position: position,
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
      ),
      constraints: BoxConstraints(
        maxWidth: width ?? 200.w,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: padding ?? EdgeInsets.zero,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: width ?? 200.w,
                  child: bodyBuilder(context),
                ),
              ),
              Positioned(
                child: _buildArrow(),
                top: position == PopoverPosition.bottom ? -arrowSize : null,
                bottom: position == PopoverPosition.top ? -arrowSize : null,
                left: position == PopoverPosition.right ? -arrowSize : null,
                right: position == PopoverPosition.left ? -arrowSize : null,
              ),
            ],
          ),
        ),
      ],
    ).then((_) {
      if (onPop != null) {
        onPop!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class ArrowPainter extends CustomPainter {
  final PopoverPosition position;
  final Color color;

  ArrowPainter({required this.position, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (position) {
      case PopoverPosition.top:
        path.moveTo(size.width / 2, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case PopoverPosition.bottom:
        path.moveTo(size.width / 2, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case PopoverPosition.left:
        path.moveTo(size.width, size.height / 2);
        path.lineTo(0, 0);
        path.lineTo(0, size.height);
        break;
      case PopoverPosition.right:
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      default:
        return;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 便捷方法
void cxPopover({
  required BuildContext context,
  required Widget Function(BuildContext) bodyBuilder,
  VoidCallback? onPop,
  double? width,
  Offset? offset,
  Color? backgroundColor,
  double? borderRadius,
  EdgeInsets? padding,
  PopoverPosition position = PopoverPosition.bottom,
  double arrowSize = 8.0,
  Color? arrowColor,
  double elevation = 2.0,
}) {
  CxPopover(
    context: context,
    bodyBuilder: bodyBuilder,
    onPop: onPop,
    width: width,
    offset: offset,
    backgroundColor: backgroundColor,
    borderRadius: borderRadius,
    padding: padding,
    position: position,
    arrowSize: arrowSize,
    arrowColor: arrowColor,
    elevation: elevation,
  ).show();
}
