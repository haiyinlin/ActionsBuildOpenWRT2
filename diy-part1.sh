#!/bin/bash
set -e
FEEDS_CONF=feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -a

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
rm -rf feeds/packages/net/mosdns

# 拉取第三方插件示例
git clone  https://github.com/gdy666/luci-app-lucky.git package/lucky   #  lucky 
git clone https://github.com/sirpdboy/luci-app-taskplan.git package/luci-app-taskplan               #  定时任务设置

# git clone https://github.com/linkease/istore.git package/istore

git clone https://github.com/kenzok8/small.git package/small

# git clone https://github.com/whzhni1/luci-app-vnt2.git package/vnt

git clone --depth 1 https://github.com/jcorporation/myMPD.git /tmp/tmp_mympd
mv /tmp/tmp_mympd/contrib/packaging/openwrt package/mympd/
rm -rf /tmp/tmp_mympd
sed -i '78s/^[[:space:]]*/\t/' package/mympd/Makefile
