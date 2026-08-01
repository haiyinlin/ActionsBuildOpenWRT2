#!/bin/bash
set -e

# ============================================================
# 颜色定义
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}开始执行 DIY 第一部分预处理脚本${NC}"
echo -e "${BLUE}========================================${NC}"

# ============================================================
# 0. 确保 feeds.conf.default 存在
# ============================================================
if [ ! -f feeds.conf.default ]; then
    echo -e "${RED}错误: feeds.conf.default 不存在！${NC}"
    exit 1
fi

# ============================================================
# 1. 更新 feeds（必须先执行，保证后续操作基于最新源）
# ============================================================
echo -e "\n${YELLOW}[1/5] 正在更新 feeds 软件包列表...${NC}"
./scripts/feeds update -a

echo -e "\n${YELLOW}[2/5] 正在安装 feeds 中的软件包...${NC}"
./scripts/feeds install -a
echo -e "${GREEN}  ✅ feeds 更新完成${NC}"

# ============================================================
# 2. 移除不需要的 feeds 包（删除 package/ 下的符号链接，而非 feeds/ 源码）
#    这样既保留了 feeds 源码（便于后续更新），又防止这些包被编译
# ============================================================
echo -e "\n${YELLOW}[3/5] 正在移除 feeds 中不需要的包符号链接（防止冲突）...${NC}"

# 移除 packages/net 下的代理相关包
rm -rf package/feeds/packages/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}

# 移除 luci 应用
rm -rf package/feeds/luci/applications/luci-app-passwall
rm -rf package/feeds/luci/applications/luci-app-ssr-plus
rm -rf package/feeds/luci/applications/helloworld
rm -rf package/feeds/luci/applications/luci-app-openclash
rm -rf package/feeds/luci/applications/luci-app-openlist
rm -rf package/feeds/packages/net/openlist
rm -rf package/feeds/packages/net/mosdns

echo -e "${GREEN}  ✅ 已移除冲突包符号链接${NC}"

# ============================================================
# 3. 克隆第三方插件（直接放在 package/ 下，覆盖同名符号链接）
# ============================================================
echo -e "\n${YELLOW}[4/5] 正在克隆第三方插件源码...${NC}"

# 3.1 lucky (gdy666/luci-app-lucky)
echo -e "  → 克隆 lucky..."
rm -rf package/lucky
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# 3.2 taskplan (sirpdboy/luci-app-taskplan)
echo -e "  → 克隆 taskplan..."
rm -rf package/luci-app-taskplan
git clone https://github.com/sirpdboy/luci-app-taskplan.git package/luci-app-taskplan

# 3.3 small 仓库 (kenzok8/small) - 包含大量常用插件依赖
echo -e "  → 克隆 small 仓库..."
rm -rf package/small
git clone https://github.com/kenzok8/small.git package/small
rm -rf package/small/trojan-plus package/small/luci-app-fchomo

# 3.4 可选插件（按需取消注释）
# echo -e "  → 克隆 istore..."
# rm -rf package/istore
# git clone https://github.com/linkease/istore.git package/istore
#
# echo -e "  → 克隆 vnt2..."
# rm -rf package/vnt
# git clone https://github.com/whzhni1/luci-app-vnt2.git package/vnt

# ============================================================
# 4. 处理 myMPD 特殊包
# ============================================================
echo -e "  → 处理 myMPD 包..."
rm -rf package/mympd
git clone --depth 1 https://github.com/jcorporation/myMPD.git /tmp/tmp_mympd
mv /tmp/tmp_mympd/contrib/packaging/openwrt package/mympd/
rm -rf /tmp/tmp_mympd
# 修补 Makefile 缩进（第78行）
sed -i '78s/^[[:space:]]*/\t/' package/mympd/Makefile

echo -e "${GREEN}  ✅ 第三方插件克隆完成${NC}"

# ============================================================
# 5. 保存第三方插件 commit 快照（用于 CI 变更检测）
# ============================================================
echo -e "\n${YELLOW}[5/5] 正在保存第三方插件 commit 快照...${NC}"

# 收集 package/ 下的插件目录（排除 base-files）
find package -maxdepth 1 -type d | grep -v base-files > /tmp/third_list.txt
while read dir; do
  if [ -d "${dir}/.git" ]; then
    echo "$(basename $dir):$(git -C $dir rev-parse HEAD)"
  fi
done < /tmp/third_list.txt > /tmp/third_commits.txt

# 将快照复制到上层目录，供后续 CI 步骤使用（例如作为缓存 key 的一部分）
if [ -n "$GITHUB_WORKSPACE" ]; then
    cp /tmp/third_commits.txt "$GITHUB_WORKSPACE/plugin_commits.txt" 2>/dev/null || true
fi

# 打印快照（便于调试）
echo -e "\n====================【第三方插件当前 commit】===================="
cat /tmp/third_commits.txt
echo -e "==============================================================\n"

# 清理临时文件
rm -f /tmp/third_list.txt /tmp/third_commits.txt

# ============================================================
# 完成
# ============================================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 DIY 第一部分预处理脚本执行完毕！${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "下一步请运行 ${YELLOW}make menuconfig${NC} 配置编译选项，然后编译。"
