#!/bin/bash

# Photography 图片更新一键推送脚本
# 用法: 
#   1. 把新图片放到 images/ 目录
#   2. 运行 ./update_and_push.sh [提交信息]
# 脚本会自动生成 fulls 和 thumbs 然后推送到 GitHub

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}  Photography 图片更新推送脚本${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# 检查 images 根目录是否有新图片需要处理
NEW_IMAGES=$(find images -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null)

if [ -n "$NEW_IMAGES" ]; then
    echo -e "${YELLOW}📷 发现新图片，正在生成 fulls 和 thumbs...${NC}"
    
    for img in $NEW_IMAGES; do
        filename=$(basename "$img")
        echo -e "  处理: ${BLUE}$filename${NC}"
        
        # 生成 fulls (1024px 宽)
        sips -Z 1024 "$img" --out "images/fulls/$filename" >/dev/null 2>&1
        
        # 生成 thumbs (512px 宽)
        sips -Z 512 "$img" --out "images/thumbs/$filename" >/dev/null 2>&1
        
        # 删除原图
        rm "$img"
    done
    
    echo -e "${GREEN}✅ 图片处理完成${NC}"
    echo ""
fi

# 检查是否有更改
echo -e "${YELLOW}📋 检查文件更改...${NC}"

if [[ -z $(git status --porcelain) ]]; then
    echo -e "${GREEN}✅ 没有需要提交的更改${NC}"
    exit 0
fi

# 显示更改详情
echo -e "${YELLOW}📁 更改的文件:${NC}"
git status --short
echo ""

# 添加所有更改
echo -e "${YELLOW}📦 添加所有更改...${NC}"
git add --all

# 获取提交信息
if [ -n "$1" ]; then
    COMMIT_MSG="$1"
else
    # 生成默认提交信息
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    COMMIT_MSG="更新图片 - $TIMESTAMP"
fi

# 提交更改
echo -e "${YELLOW}💾 提交更改...${NC}"
git commit -m "$COMMIT_MSG"

# 推送到远程仓库
echo ""
echo -e "${YELLOW}🚀 推送到 GitHub...${NC}"
git push origin main

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}✅ 推送成功！${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "📍 仓库地址: ${BLUE}https://github.com/lzf00/photography${NC}"
echo -e "🌐 网站地址: ${BLUE}https://lzf00.github.io/photography${NC}"
echo ""

# 显示最新提交信息
echo -e "${YELLOW}📜 最新提交:${NC}"
git log -1 --oneline
