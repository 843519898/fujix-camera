# flexible 脚手架介绍

无需复杂配置即可快速搭建 app 基础架子，让你更加专注业务 ui 实现。

flexible 通过运行一个命令来创建一个 app 应用程序。可在 macOS，Windows 和 Linux 上运行。

flutter版本

```bash
Flutter 3.32.2 • channel stable
Tools • Dart 3.8.1
```

## 🔧 **系统要求**

- iOS 14.0 或更高版本（因 flutter_inappwebview 插件需要）
- Android minSdkVersion 19 或更高版本

## 内置集成功能

• 动态环境构建打包，挂载在 app 内部全局参数中，如请求接口动态前缀 url，根据不同打包环境使用不同的接口域名。

• 状态管理：集成 Provider 在 Flutter 项目中，任何页面声明好 store，注入 lib/providers_config.dart 文件内即可使用。

• 页面组件更便捷的接收 路由别名跳转传参，底层已处理无需任何插件支持！简单易用，无学习成本。

• 全局主题一键换色，只需要配置你的主题颜色，调用方法即可。

• 全局浮动调试组件，让你在真机上也能便利的获取错误捕获。

• 全局 context 对象，可在任意位置获取使用，例如在状态管理 provider 层内使用

• OTA 更新 app 功能，内置一套 ui 界面，轻松配置 OTA 更新地址。

• **自定义拍照功能**：集成 camera 插件，支持前后摄像头切换、闪光灯控制、手势缩放、自动保存到相册等完整拍照功能。

PS：其它更多功能介绍往下拉查看 功能介绍区文档，或自行体验探索。

## 目录

* [项目结构](#项目目录结构)
* [快速入门上手](#快速入门上手)
  + [创建项目](#创建项目)
  + [启动项目](#启动项目)
  + [指令参数介绍](#指令参数介绍)
* [功能介绍](#功能介绍)
  + [动态环境变量](#动态环境变量)
  + [App 启动屏](#app启动屏)
  + [获取全局 context](#获取全局context)
  + [dio 封装](#dio封装简化使用)
  + [别名路由传参](#别名路由传参)
  + [OTA 更新 App 版本](#ota更新app版本)
  + [全局主题切换功能](#全局主题切换功能)
  + [全局路由监听](#全局路由监听)
  + [Provider状态管理](#Provider状态管理)
  + [自定义拍照功能](#自定义拍照功能)
  + [build渠道标记](#build渠道标记)
* [历史更新](CHANGELOG.md)

<br>

## 项目结构

```bash
  asset/ # 静态资源
  lib/
  |- components/ # 共用widget组件
  |- config/ # 全局配置参数
      |- app_config.dart # APP相关配置，如反向代理、设计稿尺寸等
  |- constants/ # 常量文件夹
  |- provider/ # 全局状态管理
  |- pages/ # 页面ui层
      |- app_main/ # APP主体页面
      |- splash/ # APP闪屏页
  |- service/ # 请求接口抽离层
  |- models/ # 数据类型
  |- routes/ # 路由相关文件夹
  |- utils/ # 工具类
```

<br/><br/>

# 快速入门上手

## 创建项目

1、全局安装 cli 插件，确保你的电脑中有 node 环境。<br>

```bash
npm i -g flib-cli // 全局安装插件

// 方式二：手动下载，但没有全局指令功能
git clone https://github.com/tec8297729/flutter_flexible.git
```

2、打开终端，输入以下指令创建项目

```bash
flib updata // 更新下载模板
flib create  // 创建项目，根据提示步骤往下进行，都有默认参数可直接回车
```

<br>

cli 相关指令介绍<br>

```bash
flib create 创建一个flutter项目
flib updata 更新最新flutter模板
flib page <name> 创建一个页面组件
```

## 启动项目

进入项目目录文件夹，初始化安装依赖包以及启用 APP（记的开启你的模拟器）<br>

输入以下命令：<br>

```bash
flutter pub get
flutter run
```

<br/>

PS：安卓如果编译失败，请在android\local.properties更改minSdkVersion版本号

```bash
# 调整版本号到19以上，原flutter默认版本为16
flutter.minSdkVersion=19
```

### 🚨 **iOS 编译问题解决**

如果遇到 iOS 模拟器崩溃，错误信息为 `Library not loaded: /usr/lib/swift/libswiftWebKit.dylib`：

1. **原因分析**：flutter_inappwebview 插件需要 iOS 14.0+ 系统支持
2. **解决方案**：项目已自动配置 iOS 14.0 为最低支持版本
3. **验证方法**：检查以下文件中的版本设置
   - `ios/Podfile`: `platform :ios, '14.0'`
   - `ios/Flutter/AppFrameworkInfo.plist`: `MinimumOSVersion: 14.0`
   - `ios/Runner.xcodeproj/project.pbxproj`: `IPHONEOS_DEPLOYMENT_TARGET = 14.0`

### 指令参数介绍

指令也是为了更方便记忆使用，你也可以使用原生 flutter 指令打包等<br>

集成在项目中的指令如下：<br>

|        命令        |                               说明                               |
| :----------------: | :--------------------------------------------------------------: |
|   npm run start    |            启动 APP 项目，请提前开好模拟器或连接真机             |
|   npm run build    |               同时打包 APP 的安卓和 IOS，prod 环境               |
|   build-apk:test   |                    打包 安卓 文件 test 环境的                    |
|   build-apk:pre    |                    打包 安卓 文件  pre 环境的                    |
|   build-apk:prod   |                    打包 安卓 文件 prod 环境的                    |
|   build-ios:test   |                    打包 IOS 文件 test 环境的                     |
|   build-ios:pre    |                    打包 IOS 文件  pre 环境的                     |
|   build-ios:prod   |                    打包 IOS 文件 prod 环境的                     |
|   build-web:test   |                     打包 web 文件 test 环境                      |
|   build-web:pre    |                      打包 web 文件 pre 环境                      |
|   build-web:prod   |                     打包 web 文件 prod 环境                      |
| build-windows:test |                   打包 windows 文件 test 环境                    |
| build-windows:pre  |                    打包 windows 文件 pre 环境                    |
| build-windows:prod |                   打包 windows 文件 prod 环境                    |
|   npm run upsdk    |    更新 sdk 版本，全局的 flutter 和 dart 版本将更新为最新版本    |
|   npm run appkey   | 验证打包后的安卓 apk 签名信息，需要本机终端安装了keytool命令工具 |

<br><br><br>

# 功能介绍

## 动态环境变量

默认使用 npm run dev 或是 npm run apk-build:test 等内置语法，是设置好了环境变量参数的，直接运行指令即可。<br>

1、在文件下定义环境参数： lib/config/app_env.dart，例如定义环境变量 baseUrl <br>

2、在其它组件页面中直接调用即可

```dart
import 'config/app_env.dart' show appEnv;
appEnv.baseUrl // 获取当前环境的url
```

## App 启动屏

App 启动屏图片修改到指定路径中替换成自己的图片<br>

```

// 这是安卓启动屏图片路径，默认只添加了一个文件加，需要不同分别率在mipmap-**相应文件夹内添加
android\app\src\main\res\mipmap\splash_bg.png

// 这是IOS启动屏图片路径，LaunchImage**.png都替换成自己的启动屏图片
ios\Runner\Assets.xcassets\LaunchImage.imageset\LaunchImage.png
```

PS：启动屏欢迎页及广告页面在 flutter 组件中定制功能，在 lib\pages\SplashPage 目录中修改

## 获取全局 context

全局 Key 和全局 context 都存放在全局 common_config.dart 文件中。<br>

PS：你可以把一些全局的类都可以此中使用，从而实现页面更加方便管理<br>

```dart
import 'config/common_config.dart' show commonConfig;
commonConfig.getGlobalKey;; // 全局context对象
```

应用场景：像弹层需要context对象，状态管理层（调用第三方插件有依赖）都可以直接使用全局的context对象透传过去

<br>

## dio 封装简化使用

已经 dio 请求底层封装，更简化使用<br>

```dart
import 'package:flexible/utils/request.dart';
// get请求使用方法，同dio组件request方法
getHomeData() async {
  Map resData = await Request.get(
    'url',
    queryParameters: {'key': 'value'}, // 在url后追加参数?key=value
  );
}

// post请求
getHomeData() async {
  Map resData = await Request.post(
    'http://url',
    data: {'version': version}, // 传递参数
    queryParameters: {'key': 'value'}, // 在url后追加参数?key=value
  );
}
```

### dio 拦截处理

在 lib/utils/dio/interceptors 目录内，扩展请求拦截处理

```dart
/*
 * header拦截器
 */
class HeaderInterceptors extends InterceptorsWrapper {
  // 请求拦截
  @override
  onRequest(RequestOptions options) async {
    options.connectTimeout = 15000;
    options.baseUrl = AppConfig.host;
    return options;
  }

  // 响应拦截
  @override
  onResponse(Response response) async {
    return response;
  }

  // 请求失败拦截
  @override
  onError(DioError err) async {}
}
```

<br>

## Provider状态管理

1、在任意目录内创建provider目录（建议页面级目录），并且在此目录内建立一个store文件

```dart
// home页面
// pages/app_main/home/provider/counterStore.p.dart文件
import 'package:flutter/material.dart';

class CounterStore extends ChangeNotifier {
  int value = 10;
  void increment() {
    value++;
    notifyListeners();
  }
}

```

2、进入lib/providers_config.dart文件，把刚创建好的store文件在里面声明一下

```dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'pages/app_main/home/provider/counterStore.p.dart';
import 'provider/global.p.dart';
import 'provider/theme_store.p.dart';

List<SingleChildWidget> providersConfig = [
  ChangeNotifierProvider<ThemeStore>(create: (_) => ThemeStore()),
  ChangeNotifierProvider<GlobalStore>(create: (_) => GlobalStore()),
  // 新增的store
  ChangeNotifierProvider<CounterStore>(create: (_) => CounterStore()),
];
```

3、在页面中使用provider状态管理

```Dart
// home页面中使用，精简代码
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/counterStore.p.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.params}) : super(key: key);
  final dynamic params;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late CounterStore _counter;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _counter = Provider.of<CounterStore>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          ElevatedButton(
            child: Text(
              // 读取ConterStore中的value变量，显示10
              Text('状态管理值：${context.watch<CounterStore>().value}'),
            ),
            onPressed: (){
              _counter.increment(); // 调用ConterStore类中的increment方法
            },
          )
        ]
      ),
    );
  }
}

```

ps：provider官方还有更多api使用方式，[文档地址](https://pub.dev/packages/provider)

<br>

## 别名路由传参

别名路由传递参数，在接收过程更便捷利与使用。<br>

1、进入路由配置文件 routes/routesData.dart，加入别名传参支持。<br>

```dart
// routesData.dart文件
import 'package:flutter/material.dart';
import '../pages/ErrorPage/ErrorPage.dart';
import '../pages/TestDemo/TestDemo.dart';

final Map<String, WidgetBuilder> routesData = {
  // 路由/testDemo 添加别名路由传参支持。
  '/testDemo': (BuildContext context, {params}) => TestDemo(params: params),
  // error路由不加入别名传参功能，
  '/error': (BuildContext context, {params}) => ErrorPage(),
};

```

<br>
2、在页面中使用别名跳转，直接使用原生别名跳转方法即可<br>

```dart
// 某页面跳转
Navigator.pushNamed(
  context,
  '/testDemo',
  arguments: {'data': 'hello world'}, //　传递参数
);

```

<br>
3、在接收的子页面直接读取params参数变量即可。<br>

```dart
// 子页面组件使用及接收
class testDemo extends StatefulWidget {
  testDemo({Key? key, this.params}) : super(key: key);
  final params; // 别名传参接收变量

  @override
  _testDemoState createState() => _testDemoState();
}
class _testDemoState extends State<testDemo>{
  @override
  void initState() {
    super.initState();
    print(widget.params); // 路由别名参数
  }
}
```

<br>

## OTA 更新 App 版本

1、添加安卓的存储权限申请标签(默认已添加, 可跳过此步)，如有删除安卓目录生成过的，请自行添加一下。

安卓权限配置文件 android\app\src\main\AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.example.flutter_flexible">
    <!-- 添加读写权限 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
        <!--  Android 10（API 29） -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

    <!-- Android 11（API 30） -->
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
    <application>
      <!-- 将以下提供程序引用添加到节点内 -->
      <provider
          android:name="sk.fourq.otaupdate.OtaUpdateFileProvider"
          android:authorities="${applicationId}.ota_update_provider"
          android:exported="false"
          android:grantUriPermissions="true">
          <meta-data
              android:name="android.support.FILE_PROVIDER_PATHS"
              android:resource="@xml/filepaths" />
      </provider>
    </application>
</manifest>
```

2、在 lib\components\UpdateAppVersion\getNewAppVer.dart 文件中，getNewAppVer 方法直接运行更新 APP 版本，但有少部份需要自己实现，已标注 TODO 位置，指定 APP 下载地址和获取新版本的接口替换。<br>

```dart
// TODO:替换成自己的获取新版本APP的接口
Map resData = await getNewVersion();
// 模拟参数结构如下  {"code":"0","message":"success","data":{"version":"1.1.0","info":["修复bug提升性能","增加彩蛋有趣的功能页面","测试功能"]}}

UpdateAppVersion(
  // TODO: 传入新版本APP相关参数、版本号、更新内容、下载地址等
  version: resData['version'] ?? '', // 版本号
  info: (resData['info'] as List).cast<String>() ?? [], // 更新内容介绍
  // ios是苹果应用商店地址
  iosUrl: 'itms-apps://itunes.apple.com/cn/app/id414478124?mt=8',
  // 安卓APK下载地址
  androidUrl: 'https://www.jonhuu.com/download/aweme.apk',
)
```

3、在指定页面运行 检查 APP 版本函数，默认在 lib\pages\AppMain\AppMain.dart 中，运行检查更新 APP 函数，你可以指定其它位置运行检查新版本。<br>

```dart
import 'package:flexible/components/UpdateAppVersion/UpdateAppVersion.dart' show getNewAppVer;

getNewAppVer(); // 在指定组件页面 执行更新检查
```

## 全局主题切换功能

目前有内置几个主题，轻松切换整体 app 颜色主题功能，只需专注配置 app 各个参数颜色

如果要自定义 app 主题，把配置参数文件放入 lib\config\themes 文件夹中，然后 part 到 index_theme.dart 文件中统一管理。<br>

案例如下：<br>

```dart
import 'package:flutter/material.dart';
// 以下你配置的全局主题颜色参数
part 'themeBlueGrey.dart';
part 'themeLightBlue.dart';
part 'themePink.dart';

```

主题配色具体可以参考是关配色文件 themeBlueGrey.dart 等。<br>

在需要替换主题的页面中调用如下：<br>

```dart
import 'package:flexible/constants/themes/index_theme.dart' show themeBlueGrey; // 主题文件
import 'package:flexible/provider/themeStore.p.dart'; // 全局主题状态管理
ThemeStore _theme = Provider.of<ThemeStore>(context);
_theme.setTheme(themeBlueGrey); // 替换主题，注入主题配置即可
```

### 灰度主题

灰度主题只有 app 首页生效，针对特殊场景使用，此功能不需要单独配置主题文件，直接使用即可。

<br>

```dart
import './lib/provider/global.p.dart';

## 自定义拍照功能

本项目集成了完整的自定义拍照功能，基于 `camera` 插件实现，提供专业级的拍照体验。

### 功能特点

• **前后摄像头切换**：支持前置和后置摄像头无缝切换
• **闪光灯控制**：支持关闭、自动、常亮三种闪光灯模式
• **手势缩放**：支持双指手势缩放相机画面
• **滑动条缩放**：提供精确的滑动条缩放控制
• **自动权限管理**：自动请求和处理相机权限
• **自动保存相册**：拍照后自动保存到系统相册
• **美观UI界面**：现代化的相机界面设计
• **拍照动画效果**：流畅的拍照动画和震动反馈

### 使用方法

1、在首页点击"自定义拍照"按钮，系统会自动检查并请求相机权限

2、进入拍照界面后，可以使用以下功能：
   - 点击屏幕上方的闪光灯图标切换闪光灯模式
   - 点击右下角的切换图标在前后摄像头间切换
   - 使用双指手势或右侧滑动条进行缩放
   - 点击中央拍照按钮进行拍照

3、拍照成功后，照片会自动保存到系统相册，并显示成功提示

### 权限配置

项目已自动配置所需权限，无需手动添加：

#### Android 权限（android/app/src/main/AndroidManifest.xml）
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS 权限（ios/Runner/Info.plist）
```xml
<key>NSCameraUsageDescription</key>
<string>此应用需要访问相机以拍照</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>此应用需要访问相册以保存照片</string>
```

### 代码示例

在任意页面调用拍照功能：

```dart
import 'package:permission_handler/permission_handler.dart';
import '../../routes/route_name.dart';

// 请求相机权限并打开拍照页面
Future<void> openCamera() async {
  // 检查权限
  PermissionStatus status = await Permission.camera.request();
  
  if (status.isGranted) {
    // 跳转到拍照页面
    final result = await Navigator.pushNamed(context, RouteName.camera);
    
    if (result != null) {
      print('拍照完成，图片路径: $result');
    }
  } else {
    print('相机权限被拒绝');
  }
}
```

### 错误处理

拍照功能包含完整的错误处理机制：

• **权限拒绝处理**：引导用户到系统设置开启权限
• **相机初始化失败**：提供重试按钮和错误提示
• **拍照失败处理**：显示具体错误信息
• **保存失败处理**：提示用户保存失败原因

### 自定义配置

可以通过修改 `lib/pages/camera/custom_camera.dart` 文件来自定义拍照功能：

```dart
// 修改拍照分辨率
ResolutionPreset.high  // 可选：low, medium, high, veryHigh, ultraHigh

// 修改默认闪光灯模式
FlashMode _flashMode = FlashMode.off;  // 可选：off, auto, always

// 修改缩放范围
double _minZoomLevel = 1.0;
double _maxZoomLevel = 8.0;
```

### 注意事项

• 首次使用需要用户授权相机权限
• iOS 14.0+ 系统支持，Android API 21+ 支持
• 拍照功能需要真机测试，模拟器可能不支持
• 建议在光线充足的环境下使用以获得最佳拍照效果
GlobalStore globalStore = Provider.of<GlobalStore>(context);
globalStore.setGrayTheme(true); // 设置灰度模式
```

PS：一般灰度主题模式用于特殊纪念日才使用，如需所有页面都展示此效果，可参考lib\pages\app_main\app_main.dart内build函数代码，使用到所有页面

## 全局路由监听

默认监听全局路由页面，只需要添加你的第三方统计埋点即可，如需要某页面 tab 监听还需要你手动继承类，并且实现相关方法。<br>

具体实现由 ana_page_loop 插件完成，详细插件文档》》 <https://github.com/tec8297729/ana_page_loop> <br>

1、先找到如下文件 lib\utils\myAppSetup\anaPageLoopInit.dart，配置第三方统计方法，如果想指定路由不监听处理事件，写入相关路由名称即可。<br>

```dart
// 找到如下文件 lib\utils\myAppSetup\anaPageLoopInit.dart
void anaPageLoopInit() {
  anaPageLoop.init(
    beginPageFn: (name) {
      // TODO: 第三方埋点统计开始
    },
    endPageFn: (name) {
      // TODO: 第三方埋点统计结束
    },
    routeRegExp: ['/appMain'], // 过滤路由
    debug: false,
  );
}
```

如果你的项目很简单，此时你已经完整了全局埋点处理，只需要添加一下第三方埋点方法即可。<br>
要是你需要独立统计 PageView 或是 Tab 组件中页面的，接着往第二步操作。<br>

2、首先提供了二个 mixin 继承类使用，用在你需要独立统计的页面，并且记得把当前独立统计的页面路由过滤掉，例如/home 页面是独立统计四个页面，所以需要过滤整体的/home 路由。<br>

```dart
PageViewListenerMixin类：用于监听类PageView组件
TabViewListenerMixin类：用于监听类TabBar组件
```

演示在 PageView 组件中的使用如下：<br>

```dart
// 当前路由页面名称是 /appMain
class _AppMainState extends State<AppMain> with PageViewListenerMixin {
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  // 实现PageViewListenerMixin类上的方法
  @override
  PageViewMixinData initPageViewListener() {
    return PageViewMixinData(
      controller: pageController, // 传递PageController控制器
      tabsData: ['首页', '分类', '购物车', '我的中心'], // 自定义每个页面记录的名称
    );
  }

  // 调用如下几个生命周期
  @override
  void didPopNext() {
    super.didPopNext();
  }

  @override
  void didPop() {
    super.didPop();
  }

  @override
  void didPush() {
    super.didPush();
  }

  @override
  void didPushNext() {
    super.didPushNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController, // 控制器
        children: <Widget>[],
      ),
    );
  }
}
```

## build渠道标记

1、打包时注入ANDROID_CHANNEL参数，标记渠道参数

```bash
flutter build apk --dart-define=ANDROID_CHANNEL=flutter # 打包，并标记渠道为flutter
flutter run --dart-define=ANDROID_CHANNEL=flutter # 本地运行（开发环境），查看当前渠道
```

PS: 打包不同渠道命令可统一写到package.json文件内（生成多条指令），使用npm run xxxx批量执行打包，具体可参考package.json文件命令

示例：批量执行多条指令

```json
{
  "scripts": {
    // 终端执行npm run build，代表同时执行build-apk:prod、build-ios:prod、build-web:prod、build-windows:prod几条指令
    "build": "npm run build-apk:prod && npm run build-ios:prod && npm run build-web:prod && npm run build-windows:prod",
    "build-apk:prod": "flutter build apk --dart-define=INIT_ENV=prod --dart-define=ANDROID_CHANNEL=flutter",
    "build-ios:prod": "flutter build ios --dart-define=INIT_ENV=prod",
    "build-web:prod": "flutter build web --dart-define=INIT_ENV=prod",
    "build-windows:prod": "flutter build windows --dart-define=INIT_ENV=prod",
  }
}
```

2、在flutter端获取渠道变量

```dart
import 'lib/config/app_env.dart' show appEnv; // 获取环境类
appEnv.getAppChannel() // 获取渠道参数
```
