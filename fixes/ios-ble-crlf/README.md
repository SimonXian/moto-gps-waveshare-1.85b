# iOS BLE CRLF 修复

将此目录的 platforms/ 合并到原完整源码包的 project/，保留两份 Swift 文件，再在 platforms/ios/ 运行 xcodegen generate。不要复制原电脑的签名设置或私人网关地址。

修复后以所有换行字符解析 golden 文件；测试使用真实编码器覆盖 LF / CRLF。需要自行重新签名安装 iPhone App。ESP32 镜像未变，此修复无需重新刷圆屏。

完整说明见新发布的 IOS-INSTALL.md。原包中的 Windows 本地依赖锁路径仍需按 README-FIRST.md 调整。本目录不是完整 App，也不是可直接安装的 IPA。
