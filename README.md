# MOTO GPS · Waveshare 1.85B

面向 **Waveshare ESP32-S3-Touch-LCD-1.85B** 的固件与配套资料。请先按用途选择版本：

| 使用目标 | 下载入口 | 范围 |
| --- | --- | --- |
| 圆屏 + iPhone 配套体验 | [完整配套修复版 v0.2.1-1.85b-ios-fix1](https://github.com/SimonXian/moto-gps-waveshare-1.85b/releases/tag/v0.2.1-1.85b-ios-fix1) | ESP32 仍为 0.2.1；完整源码、独立刷机包、iOS BLE 修复与测试 |
| 单页箭头纯硬件版 | [0.3.0-1.85b-arrow 工程验证版](https://github.com/SimonXian/moto-gps-waveshare-1.85b/releases/tag/v0.3.0-1.85b-arrow) | 保留既有硬件包；与完整配套版分别验证 |

## 完整配套修复版（2026-11-09）

- 只刷圆屏：下载 `MOTO-GPS-1.85B-0.2.1-ios-fix1-firmware.zip`，先读 [1.85B 刷机教程](docs/FLASHING-1.85B.md)。无需 ESP-IDF。
- 安装 iPhone App：下载 `MOTO-GPS-1.85B-0.2.1-ios-fix1-source.zip`，按 [iOS 安装与网关说明](docs/IOS-INSTALL.md) 使用自己的签名和 HTTPS 网关。
- 已有旧完整源码：也可下载 `MOTO-GPS-1.85B-ios-ble-fix1.zip` 覆盖两份 Swift 文件并重新生成、签名安装 App。
- 修复 CRLF 测试向量解析导致的“连接后立即断开”；保留真正的协议自检。ESP32 镜像未改变，无需为本次 iOS 修复重刷圆屏。
- 实体 iPhone 通过换行回归测试、完整 BLE 握手，以及接入私人网络后的真实搜索 / 公共地点路线检查；[验证范围与限制](docs/VALIDATION-ios-fix1.md)。
- 真实搜索必须配置可用网关；本地演示不依赖它。私人网关要求手机与主机都已连接私人网络。包中没有个人网关地址、签名或公共导航服务。

下文保留 **0.3.0 纯箭头硬件版** 原有步骤；不要与上述配套版混用。

> 仓库目前为私有：仅拿到链接不代表获得访问权限，需要登录已获授权的 GitHub 账号。

## 1. 下载硬件安装包

**[打开 0.3.0 下载页](https://github.com/SimonXian/moto-gps-waveshare-1.85b/releases/tag/v0.3.0-1.85b-arrow)**

优先下载 **[MOTO-GPS-1.85B-0.3.0-hardware-install.zip](https://github.com/SimonXian/moto-gps-waveshare-1.85b/releases/download/v0.3.0-1.85b-arrow/MOTO-GPS-1.85B-0.3.0-hardware-install.zip)**，解压后阅读 `硬件安装与使用说明.txt`。

安装包含主固件、bootloader、分区表、回退镜像和中文使用说明，无需编译源码。也可[单独下载使用说明](https://github.com/SimonXian/moto-gps-waveshare-1.85b/releases/download/v0.3.0-1.85b-arrow/HARDWARE-INSTALL-GUIDE.txt)。

Release 同时保留原始固件归档和硬件源码包。普通用户只需首选安装包。**不要下载 GitHub 自动生成的 Source code.zip/tar.gz 来刷写**；它们只是本仓库说明文件。

## 2. 核对板卡并准备

- 仅支持 ESP32-S3-Touch-LCD-1.85B：360×360、ST77916、16 MB Flash / 8 MB PSRAM。
- 不支持 1.75C，不适用于其他任意 ESP32 开发板。
- 使用 USB 数据线连接电脑，保持供电稳定，关闭占用串口的程序。
- 先安装并激活 ESP-IDF 5.5.5 环境；本包不包含电脑工具链。
- 在解压后的 `.bin` 文件目录打开终端，下面的 `PORT` 必须换成实际串口，例如 `COM3` 或 `/dev/cu.usbmodem...`。

## 3. 先备份，再刷写

备份完整 16 MB Flash，备份含设备个人数据，请自行保管：

```sh
python -m esptool --chip esp32s3 --port PORT read_flash 0x0 0x1000000 original-device-backup.bin
```

**已有兼容 1.85B 固件的设备，仅更新应用：**

```sh
python -m esptool --chip esp32s3 --port PORT --baud 460800 write_flash 0x10000 moto_gps_1_85b.bin
```

**新设备，或已确认需要安装启动程序及分区表：**

```sh
python -m esptool --chip esp32s3 --port PORT --baud 460800 write_flash --flash_mode dio --flash_size 16MB --flash_freq 80m 0x0 bootloader.bin 0x8000 partition-table.bin 0x10000 moto_gps_1_85b.bin
```

应用写入地址是 **0x10000，不能写到 0x0**。0.3.0 构建采用 **DIO / 16MB / 80m**，不要套用旧版 QIO 参数。等待写入与校验完成，期间不要断电。失败时核对端口和数据线，可将波特率降到 115200 后重试。

## 4. 启动与日常使用

启动后进入单一箭头页面，待机显示“等待连接”和 `MOTO GPS XXXXXX`。收到有效导航数据后显示转向箭头、到下一动作的距离、环岛出口与到达状态。无有效更新约 5–5.25 秒后隐藏旧指引；断线立即使旧动作失效。

本硬件通过 BLE 接收外部导航数据，不独立搜索目的地或计算路线。无数据时不显示箭头是正常行为。本版没有地图切页、音乐入口或演示任务。更多状态含义及回退步骤见安装包内中文说明。

## 版本与验证状态

- 2026-10-05 已完成一台设备的 0.3.0 应用刷写、哈希校验和 30 秒启动日志检查。
- 启动确认版本、PSRAM 自测、显示/触控初始化及 BLE 广播；构建时通过 8 组原生测试和 1 组 LVGL 界面测试。
- 实体屏幕目视、端到端导航、断电重连和道路验收尚未完成；仍有原有 IRK 保存警告 rc=17/27。
- 原始归档写有“尚未刷写”，是归档生成时的历史状态，以本页及新发布说明为准。
- 通用回退镜像不一定与设备原应用完全相同，恢复原状应优先使用该设备自己的备份。

主固件 SHA-256：`eca5723bb6830cf9f38bf072a2776f0955d39a89ec0a3317622e5ccba3d6f02b`。附件完整校验值见 Release 的 `SHA256SUMS`。

## 历史版本与许可

[0.2.1 历史发布](https://github.com/SimonXian/moto-gps-waveshare-1.85b/releases/tag/v0.2.1-1.85b)仅供追溯，包含旧的完整项目材料，不作为当前纯硬件安装入口。

原作者：Maler X。上游：[moto-gps-waveshare](https://github.com/mx3353672833-debug/moto-gps-waveshare)。原项目采用 PolyForm Noncommercial 1.0.0（个别文件及第三方依赖另有许可），请阅读各包内 `LICENSE.md`、`NOTICE` 和第三方许可文件。
