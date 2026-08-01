#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}开始执行 DIY 第一部分预处理脚本${NC}"
echo -e "${BLUE}========================================${NC}"

FEEDS_CONF=feeds.conf.default

# 1. 更新 feeds
echo -e "\n${YELLOW}[1/7] 正在更新 feeds 软件包列表...${NC}"
./scripts/feeds update -a

echo -e "\n${YELLOW}[2/7] 正在安装 feeds 中的软件包...${NC}"
./scripts/feeds install -a

# 2. 移除自带冲突包
echo -e "\n${YELLOW}[3/7] 正在移除 feeds 中自带的代理相关包（防止冲突）...${NC}"
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
echo -e "${GREEN}  ✅ 已移除 feeds/packages/net/ 下的冲突包${NC}"

# 移除 luci 应用
echo -e "\n${YELLOW}[4/7] 正在移除 feeds 中自带的 LuCI 应用...${NC}"
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-ssr-plus
rm -rf feeds/luci/applications/helloworld
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-openlist
rm -rf feeds/packages/net/openlist
rm -rf feeds/packages/net/mosdns
echo -e "${GREEN}  ✅ 已移除自带 LuCI 应用${NC}"

# 3. 克隆第三方插件（先清理旧目录）
echo -e "\n${YELLOW}[5/7] 正在克隆第三方插件源码...${NC}"

echo -e "  → 克隆 lucky (gdy666/luci-app-lucky)..."
rm -rf package/lucky
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

echo -e "  → 克隆 taskplan (sirpdboy/luci-app-taskplan)..."
rm -rf package/luci-app-taskplan
git clone https://github.com/sirpdboy/luci-app-taskplan.git package/luci-app-taskplan

# echo -e "  → 克隆 istore (linkease/istore)..."
# rm -rf package/istore
# git clone https://github.com/linkease/istore.git package/istore

# echo -e "  → 克隆 small 仓库 (kenzok8/small)..."
# rm -rf package/small
# git clone  https://gh.dpik.top/https://github.com/kenzok8/small.git package/small

# echo -e "  → 克隆 vnt2 (whzhni1/luci-app-vnt2)..."
# rm -rf package/vnt
# git clone https://github.com/whzhni1/luci-app-vnt2.git package/vnt

echo -e "${GREEN}  ✅ 第三方插件克隆完成${NC}"

# 4. 处理 myMPD 特殊包
echo -e "\n${YELLOW}[6/7] 正在处理 myMPD 包...${NC}"
rm -rf package/mympd
echo -e "  → 临时克隆 myMPD 仓库到 /tmp/tmp_mympd"
git clone --depth 1 https://github.com/jcorporation/myMPD.git /tmp/tmp_mympd
echo -e "  → 移动 OpenWrt 打包文件到 package/mympd/"
mv /tmp/tmp_mympd/contrib/packaging/openwrt package/mympd/
rm -rf /tmp/tmp_mympd
echo -e "  → 修补 myMPD 的 Makefile（调整第78行缩进）"
sed -i '78s/^[[:space:]]*/\t/' package/mympd/Makefile
echo -e "${GREEN}  ✅ myMPD 处理完成${NC}"

# 5. 完成
echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 DIY 第一部分预处理脚本执行完毕！${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "下一步请运行 ${YELLOW}make menuconfig${NC} 配置编译选项，然后编译。"
