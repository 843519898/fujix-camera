import 'package:flutter/material.dart';

// 全局路由观察者
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

// 路由监听混入
mixin RouteChangeMixin<T extends StatefulWidget> on State<T> implements RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 注册路由观察者
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // 取消订阅路由观察者
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 当从其他页面返回到当前页面时调用
  @override
  void didPopNext() {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    print('路由变化 ==> 返回到页面: $currentRoute');
    onRoutePopNext();
  }

  // 当页面被其他页面覆盖时调用
  @override
  void didPushNext() {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    print('路由变化 ==> 页面被覆盖: $currentRoute');
    onRoutePushNext();
  }

  // 当页面被销毁时调用
  @override
  void didPop() {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    print('路由变化 ==> 页面被销毁: $currentRoute');
    onRoutePop();
  }

  // 当页面被创建时调用
  @override
  void didPush() {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    print('路由变化 ==> 页面被创建: $currentRoute');
    onRoutePush();
  }

  // 以下方法可以在使用此混入的类中重写
  void onRoutePopNext() {}
  void onRoutePushNext() {}
  void onRoutePop() {}
  void onRoutePush() {}
}