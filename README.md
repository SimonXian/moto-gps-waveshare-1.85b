# MOTO GPS — Waveshare ESP32-S3-Touch-LCD-1.85B

本仓库保存当前已刷入设备的 1.85B 移植版源码与固件。仓库为 **Private**，未添加其他协作者。

## 下载完整源码

打开 [Release 下载页](https://github.com/SimonXian/moto-gps-waveshare-1.85b/releases/tag/v0.2.1-1.85b)，下载附件 **moto-gps-1.85b-source.zip**（约 166 MB）。解压后先阅读 **README-FIRST.md**。

完整源码以 Release 附件保存。GitHub 自动生成的 Source code.zip/tar.gz 和直接克隆本仓库仅包含说明文件，不是完整项目源码。

源码包包含项目源码、1.85B 显示/触控/Flash 移植、固定 LVGL 和驱动依赖源码、iOS App 与后端源码、实际刷入的镜像及哈希清单；不含原设备 Flash/NVS 备份或账号凭证。

## 硬件与构建

- ST77916：360×360 RGB565 QSPI，官方 1.85B 引脚及初始化表。
- CST816：关闭自动休眠，过滤无效坐标。
- Flash：16 MB QIO；PSRAM：8 MB Octal。
- 固件版本：0.2.1-1.85b；构建工具：ESP-IDF 5.5.5。
- 固件目标：`project/platforms/esp32_1_85b/`，请勿混用原 1.75C 目标。
- iOS 源码：`project/platforms/ios/`，使用 Mac/Xcode 和自己的 Apple 账号签名安装。

源码包 SHA-256：
`457c332f898fa6c260407400fe57b324c858cb152c000719a64bab16d0fc2955`

已刷入应用镜像 SHA-256：
`d4c39ac858f682c481552765c186833fd27d312116b1606f1e0c413318025c54`

## 验证范围

编译、刷写哈希、启动、PSRAM 自测及电脑 BLE 加密握手/路线 ACK/页面指令通过。实体画面、手指滑动、iPhone 实际导航仍待确认。QMI8658 启动校准为 0 个稳定样本；NimBLE 有本地 IRK 保存警告，未将这两项算为验证通过。

## 来源与许可

上游：[mx3353672833-debug/moto-gps-waveshare](https://github.com/mx3353672833-debug/moto-gps-waveshare)，提交 `03932af24aa462a2cd8ee71f4bf68af813a590cb`。微雪官方 1.85B 源码提交 `139e6db584f3737fcfc6a958ee83b79fb69d317c`。原项目及依赖的许可文件保留在源码包中。
