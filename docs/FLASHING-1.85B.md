# 1.85B 圆屏配套版：刷机与恢复

本说明对应 `v0.2.1-1.85b-ios-fix1` 配套套件，ESP32 固件仍为 `0.2.1-1.85b`。仅适用于 **Waveshare ESP32-S3-Touch-LCD-1.85B**（360×360、ST77916、16 MB Flash、8 MB PSRAM）。不要用于 1.75C、不带 B 的 1.85 或其他 ESP32 板卡。另一条 `0.3.0-1.85b-arrow` 是纯箭头固件，请使用它自己的安装说明。

## 1. 下载、工具与校验

从本版本 Release 下载 `MOTO-GPS-1.85B-0.2.1-ios-fix1-firmware.zip`，解压后进入含 `.bin` 的目录。只刷现成固件无需 ESP-IDF、Xcode 或编译器。

安装 Python 3.10 或更新版本。下面使用本次实际刷机使用的 esptool 5.6.0（连字符命令）；不要混用旧版下划线命令。

**macOS / Linux 终端**：

```sh
python3 -m venv .venv
.venv/bin/python -m pip install esptool==5.6.0
.venv/bin/python verify_files.py
.venv/bin/python -m serial.tools.list_ports
```

**Windows PowerShell**：

```powershell
py -3 -m venv .venv
.venv\Scripts\python.exe -m pip install esptool==5.6.0
.venv\Scripts\python.exe verify_files.py
.venv\Scripts\python.exe -m serial.tools.list_ports
```

`verify_files.py` 必须报告三份镜像长度和 SHA-256 全部匹配。解压包校验值在 `firmware-metadata.json`；整个下载包的校验值在 Release 附件 `SHA256SUMS`。可分别用 `shasum -a 256 文件名`（macOS）或 `Get-FileHash 文件名 -Algorithm SHA256`（Windows）核对。

## 2. 连接和识别板卡

用 USB 数据线直连电脑，关闭其他串口工具。对比插拔前后的串口列表：macOS 一般为 `/dev/cu.usbmodem...`，Windows 一般为 `COM3` 等，Linux 一般为 `/dev/ttyACM0`。以下 `PORT` 必须替换成自己的完整端口，不能原样照抄。

下文统一用 `PYTHON` 代表上节虚拟环境解释器：macOS / Linux 替换为 `.venv/bin/python`，Windows 替换为 `.venv\Scripts\python.exe`，不要把 `PYTHON` 原样输入。

```text
PYTHON -m esptool --chip esp32s3 --port PORT flash-id
PYTHON -m esptool --chip esp32s3 --port PORT get-security-info
```

应确认 ESP32-S3、16 MB Flash，Secure Boot 和 Flash Encryption 均未启用。通过芯片识别不能替代核对开发板完整型号。容量或安全状态不符时停止，不使用 `--force`。

若一直等待连接：按住 BOOT，按官方电源步骤重新上电，随后松开 BOOT，重新检查端口。带电池时拔掉 USB 不一定已断电。下载模式黑屏可能正常。参见[微雪 1.85B 官方说明](https://docs.waveshare.com/ESP32-S3-Touch-LCD-1.85B/Firmware-Flashing)。

## 3. 完整备份

先将同一设备的整个 16 MiB Flash 备份到自己电脑，并记录设备标识：

```text
PYTHON -m esptool --chip esp32s3 --port PORT --baud 460800 read-flash 0x0 0x1000000 original-device-backup.bin
```

文件必须为 **16,777,216 字节**。记录 SHA-256，妥善另存；备份可能含原应用数据和配对信息，不要随发布包上传。

macOS / Linux 检查：

```sh
wc -c original-device-backup.bin
shasum -a 256 original-device-backup.bin
```

Windows PowerShell 检查：

```powershell
(Get-Item original-device-backup.bin).Length
Get-FileHash original-device-backup.bin -Algorithm SHA256
```

## 4. 写入预编译镜像

确认备份及校验完成，在三份 `.bin` 所在目录执行整套安装：

```text
PYTHON -m esptool --chip esp32s3 --port PORT --baud 460800 write-flash --flash-mode dio --flash-size 16MB --flash-freq 80m 0x0 bootloader.bin 0x8000 partition-table.bin 0x10000 moto_gps_1_85b.bin
```

| 文件 | 地址 |
| --- | --- |
| bootloader.bin | 0x0 |
| partition-table.bin | 0x8000 |
| moto_gps_1_85b.bin | 0x10000 |

这是三份独立镜像，没有合并固件。**应用镜像不能写到 0x0**。无需先整片擦除。不要仅凭其他版本也叫 `moto_gps_1_85b.bin` 就混用分区表。

DIO / 16MB / 80m 沿用原构建刷机参数，本次实机使用相同参数通过。固件启动阶段再启用 QIO，因此启动日志显示 QIO 与刷写参数 DIO 并不矛盾。

等待每份镜像出现 `Hash of data verified` 并自动复位，期间保持供电。失败时先查端口占用、线材和供电，再将 `460800` 改为 `115200` 重试。

## 5. 启动、连接与验收

1. 松开 BOOT，正常重新启动，等待进入 MOTO GPS 界面。短暂黑色首帧不代表失败；持续黑屏需检查日志。
2. 用手机安装本修复版的 iOS 源码构建，见 `IOS-INSTALL.md`。允许蓝牙和定位，在 App 的“我的圆屏”连接。
3. App 显示已连接后，先验证演示同步。**真实搜索和路线依赖可访问的导航网关**；只刷圆屏不能独立完成导航。
4. 如果使用自己的 Tailscale 私人网关，手机与网关主机均须在线、处于同一私人网络；手机离线时本地演示仍可运行，但真实搜索失败。
5. 使用真实搜索选中地点、规划路线，再开始导航。演示结果不算实际导航验收。

本配套固件保留原共享导航 UI，和 0.3.0 单页箭头硬件版行为不同。现有 IRK 保存警告及 IMU 精度问题尚未修复，不能把广播启动等同于全部功能通过。

## 6. 恢复同一设备

核对备份对应同一块板、长度及 SHA-256；以下命令会覆盖当前固件：

```text
PYTHON -m esptool --chip esp32s3 --port PORT --baud 460800 write-flash --flash-mode keep --flash-size keep --flash-freq keep 0x0 original-device-backup.bin
```

仅恢复自己的完整备份，不能使用他人 Flash/NVS 备份。恢复命令没有在本次已正常运行的设备上执行。

## 本次验证范围（2026-11-09）

- 一台 1.85B：完整备份、三份镜像写入校验、60 秒启动和 PSRAM 自检通过；使用者确认实体画面正常。
- iPhone 13 Pro：修复后的 App 签名安装、BLE 加密与完整双阶段握手通过；45 秒采集无断连，LCD 持续刷新。
- 手机接入私人网络后，使用 App 的真实 provider 请求，搜索返回 12 个地点，并规划一条约 8.36 km 的公共地点测试路线。
- 换行兼容回归测试在实体 iPhone 上通过。
- Windows / Linux 步骤为对应平台命令说明，未在这些平台实刷；手指滑动、长时间锁屏重连、道路导航和 IMU 精度尚未完成验收。

技术参考：[esptool 命令](https://docs.espressif.com/projects/esptool/en/latest/esp32s3/esptool/basic-commands.html)、[微雪板卡资料](https://docs.waveshare.com/ESP32-S3-Touch-LCD-1.85B)。
