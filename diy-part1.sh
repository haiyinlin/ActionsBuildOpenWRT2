#!/bin/bash


# 拉取第三方插件示例
git clone  https://github.com/gdy666/luci-app-lucky.git package/lucky   #  lucky 
git clone https://github.com/sirpdboy/luci-app-taskplan.git package/luci-app-taskplan               #  定时任务设置

# git clone https://github.com/linkease/istore.git package/istore

git clone https://github.com/kenzok8/small.git package/small

git clone https://github.com/whzhni1/luci-app-vnt2.git package/vnt


sed -i '78s/^[[:space:]]*/\t/' package/mympd/Makefile




# 保存第三方插件当前commit快照（变更检测前置）
find package -maxdepth 1 -type d | grep -v base-files > /tmp/thrid_list.txt
while read dir; do
  if [ -d "${dir}/.git" ];then
    echo "$(basename $dir):$(git -C $dir rev-parse HEAD)"
  fi
done < /tmp/thrid_list.txt > /tmp/third_old.txt

# ======================
# 第二区块：feeds 更新
# ======================
sed -i 's/#src-git/src-git/' feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a

# ======================
# 第三区块：对比第三方插件变更并打印
# ======================
find package -maxdepth 1 -type d | grep -v base-files > /tmp/thrid_list.txt
while read dir; do
  if [ -d "${dir}/.git" ];then
    echo "$(basename $dir):$(git -C $dir rev-parse HEAD)"
  fi
done < /tmp/thrid_list.txt > /tmp/third_new.txt

echo -e "\n====================【第三方插件变更检测】===================="
diff --suppress-common-lines /tmp/third_old.txt /tmp/third_new.txt
echo -e "==============================================================\n"

# 清理临时文件
rm -f /tmp/thrid_list.txt /tmp/third_old.txt /tmp/third_new.txt

# 移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
# git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
rm -rf feeds/luci/applications/luci-app-passwall
# git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci
rm -rf feeds/luci/applications/luci-app-ssr-plus
rm -rf feeds/luci/applications/helloworld
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-openlist
rm -rf feeds/packages/net/openlist
