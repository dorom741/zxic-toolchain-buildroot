# QEMU VExpress：Linux 3.4.110 构建记录

## 目标配置

此配置用于 QEMU `vexpress-a9`：Linux 内核源码固定为 `3.4.110`，Buildroot 工具链使用独立的 Linux `6.1.x` 头文件。内核版本和 libc/toolchain 头文件版本是两个独立选择，不要使用“头文件与内核相同”。

板级 defconfig 选择 `BR2_KERNEL_HEADERS_6_1=y`；Buildroot 2024.02.1 将其解析为 `BR2_DEFAULT_KERNEL_HEADERS="6.1.82"`。内核版本仍为 `3.4.110`。

## 已记录的兼容修复

- **头文件版本检查**：将工具链头文件固定到 6.1.x，同时保留 3.4.110 内核。否则 `linux-headers` 会从内核源码选到 3.4.x，严格检查报版本不符。
- **host-libffi**：`LIBFFI_CONF_OPTS` 不会自动用于 host 变体；`HOST_LIBFFI_CONF_OPTS` 复用它，关闭会导致 `open_temp_exec_file()` 未声明的静态 trampoline 路径。
- **Linux 3.4 与 GCC 12**：板级补丁让 GCC 5 及以上复用 `compiler-gcc5.h`、恢复 GNU89 inline 语义，并在 ARM `__put_user` 汇编调用前将值操作数移入 ABI 要求的 `r2`。
- **设备树**：`linux-3.4-of.fragment` 启用 `CONFIG_USE_OF`，从而选择 `CONFIG_OF_FLATTREE` 和内核树自带的 DTC；否则 3.4 的 `scripts/dtc/dtc` 不会生成。
- **bare-metal GCC**：此 profile 保留额外 bare-metal 工具链，并将 `BR2_TOOLCHAIN_BARE_METAL_BUILDROOT_ARCH` 固定为 `arm-none-eabi`、启用 Newlib。旧 `.config` 若该 tuple 为空，GCC 会尝试运行 `host/bin/-ar`，导致 `host-gcc-bare-metal` 构建失败。
- **host-gcc-initial 的 PTR**：host-binutils 安装到 `host/include` 的新 `ansidecl.h` 不再提供 legacy `PTR`，会遮蔽 GCC 源码自带定义并导致 libiberty/GCC 生成器编译失败。GCC initial/final 配方优先搜索各自源码的 `include` 目录，host 依赖 include 仍保留在后面。
- **PATH 空格**：Buildroot 的依赖检查不接受含空格的 PATH 项。脚本只在自身进程中滤除这些目录，不修改登录环境。

## 构建

脚本默认输出到 `buildroot` 同级的 `build_target`。`--clean` 会删除该输出目录中的 Buildroot 构建产物和 `.config`，保留下载缓存；运行前先备份任何需要保留的输出或手工配置。

```sh
cd /workplace/project/lab/buildroot
./board/qemu/vexpress/build-linux-3.4.110.sh --clean
```

可覆盖输出目录、并行度和主机编译器：

```sh
O=/workplace/project/lab/build_target JOBS=8 HOSTCC=/usr/bin/gcc \
  ./board/qemu/vexpress/build-linux-3.4.110.sh --clean
```

脚本会加载 `qemu_arm_vexpress_defconfig`、完整构建、检查 host-gcc-initial 和 bare-metal GCC 产物、执行 6.1 strict 头文件检查，并确认 `zImage`、`vexpress-v2p-ca9.dtb` 和 `rootfs.ext2` 均已生成。

## 单项诊断

检查工具链 sysroot 中的头文件版本：

```sh
HOSTCC=/usr/bin/gcc support/scripts/check-kernel-headers.sh \
  /workplace/project/lab/build_target/build \
  /workplace/project/lab/build_target/host/arm-buildroot-linux-gnueabihf/sysroot \
  6.1 strict
```

只重建内核：

```sh
make O=/workplace/project/lab/build_target linux-dirclean
make O=/workplace/project/lab/build_target linux
```
