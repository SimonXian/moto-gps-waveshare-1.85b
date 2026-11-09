# iPhone 配套 App：安装与真实搜索

对应 `v0.2.1-1.85b-ios-fix1`，配套 ESP32 固件 `0.2.1-1.85b`。本包是源码交付，不包含 App Store / TestFlight 邀请、通用签名 IPA 或作者开发证书。

## 准备

- Mac、Xcode（Swift 6 工具链）、XcodeGen、自己的 Apple 账号，以及 iOS 17+ 的 iPhone。
- 完整源码包中的 `project/platforms/ios/`，以及相对路径引用的 `project/shared/` 等文件。不要只复制 iOS 单独文件夹。
- 圆屏刷入配套 1.85B 固件。0.3.0 纯箭头固件的完整配套体验未在本发布中验证，不能据此承诺兼容。

## 配置网关和签名

打开 `project/platforms/ios/project.yml`：

1. 将 `MOTOGPSGatewayBaseURL` 改为自己可用的 HTTPS 网关地址，保留末尾 `/`。默认 `https://example.invalid/moto-gps/api/` 是占位地址，不支持真实搜索。
2. 将三个 `PRODUCT_BUNDLE_IDENTIFIER` 改为自己的唯一标识。
3. `DEVELOPMENT_TEAM` 使用自己的团队，也可在 Xcode 中选择。

网关部署见 `project/backend/README.md`。高德 Web 服务 Key 留在服务端，不应写入 App。本版 iOS 请求没有试用访问码配置界面，要求访问码的另一个云端网关不能仅改 URL 就直接接入。

使用 Tailscale 私人网关时，网关主机必须运行，手机与主机须登录对应私人网络且均为 Connected。它不会因为安装 MOTO GPS 就自动连接；某些其他 VPN 配置也可能影响它。私人网关不是随本包提供的公共服务。

仅进行本地演示时可以暂保留占位 URL，但请勿将其当作真实搜索和导航验收。

## 生成工程并安装

在 `project/platforms/ios/` 目录：

```sh
xcodegen generate
open MotoGPS.xcodeproj
```

在 Xcode 登录自己的 Apple 账号，连接并信任 iPhone，选择 `MotoGPS` scheme 和真实设备。在 Signing & Capabilities 选择自己的团队，启用自动签名，再点击 Run。按 iPhone / Xcode 提示启用开发者模式；若安装后被系统阻止，按手机“设置 → 通用 → VPN 与设备管理”的提示信任自己的开发者。

开发安装的有效期由实际签名描述文件决定，到期需要重新签名。包中不提供任何账号的签名或无限期安装承诺。

## 第一次使用

1. 允许蓝牙、定位和精确位置权限。
2. 在“我的圆屏”连接设备，确认显示“已连接”。
3. 如采用私人网关，先让手机 Tailscale 显示 Connected。
4. 搜索公共地点，选中结果后等待获取当前位置并规划路线，再开始导航。
5. 演示使用本地数据；即便演示正常，也不能据此判断真实搜索、定位和路线可用。

若正在演示或导航，先结束当前会话，再搜索新的真实终点。

## 连接或搜索失败

| 现象 | 检查 |
| --- | --- |
| 反复连接后马上断开 | 确认使用本修复包的 iOS 源码；旧 Debug 包的黄金帧解析不兼容 CRLF，会在握手前主动断开 |
| 演示可运行，但地点搜索失败 | 确认已替换占位网关；检查手机网络、私人网络连接、HTTPS 证书及网关就绪状态 |
| 云端提示 ACCESS_REQUIRED | 该端点要求访问码，本版 iOS 未提供访问码配置；不要删除服务端鉴权或把访问码写入公开源码 |
| 搜索正常但无法规划路线 | 检查精确定位权限和当前位置是否有效，保持手机联网 |
| BLE 初始化日志有 IRK 警告 | 本版仍存在该警告，实际连接、重连应分别验证；本次完整握手与 45 秒连接观察通过不代表长期重连已验收 |

## 修复与测试

`BLEProtocolGoldenCheck.swift` 以 `Character.isNewline` 切分测试向量，兼容 LF / CRLF；保留真正的编码一致性检查，没有跳过自检。`BLEProtocolGoldenCheckTests.swift` 使用真实协议编码器验证两种换行，实体 iPhone 测试通过。

生成工程、完成自己的签名设置后，可单独运行回归测试：

```sh
xcodebuild -project MotoGPS.xcodeproj -scheme MotoGPS -destination 'id=你的设备UDID' -only-testing:MotoGPSUnitTests/BLEProtocolGoldenCheckTests test
```

测试 target 的签名也需要自己的团队。2026-11-09 另外完成了手机到私人网关的真实搜索 / 路线检查，该网络检查依赖个人测试环境，不作为默认离线回归测试随包运行。
