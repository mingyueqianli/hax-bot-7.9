#!/bin/bash

set -e

APP=/opt/hax-bot-6.7
REPO="https://github.com/mingyueqianli/HAX-BOT-6.6.git"

echo "🚀 HAX BOT 6.7 防错终极安装启动..."

# =========================
# 1. 系统依赖
# =========================
apt update -y
apt install -y python3 python3-pip python3-venv git curl

# =========================
# 2. 清理旧环境
# =========================
rm -rf $APP

# =========================
# 3. clone（强制成功）
# =========================
git clone $REPO $APP || {
    echo "❌ Git clone失败"
    exit 1
}

# =========================
# 4. 强制进入目录（核心修复）
# =========================
cd $APP || {
    echo "❌ 目录进入失败"
    exit 1
}

echo "📂 当前路径: $(pwd)"

# =========================
# 5. 自动修复 requirements
# =========================
if [ ! -f requirements.txt ]; then
    echo "⚠️ requirements.txt不存在，自动生成"
    cat > requirements.txt << EOF
python-telegram-bot
requests
beautifulsoup4
lxml
EOF
fi

# =========================
# 6. Python环境
# =========================
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

# =========================
# 7. 数据目录
# =========================
mkdir -p data logs

# =========================
# 8. 强制交互模式（关键）
# =========================
exec < /dev/tty

echo "===================="
read -p "🔑 TOKEN: " TOKEN
echo $TOKEN > token.txt

echo "===================="
read -p "⏱ INTERVAL(默认30秒): " INTERVAL
INTERVAL=${INTERVAL:-30}
echo $INTERVAL > interval.txt

# =========================
# 9. 启动系统
# =========================
echo "🚀 启动 BOT + COLLECTOR..."

nohup python -m app.collector.runner > logs/collector.log 2>&1 &
nohup python -m app.bot.main > logs/bot.log 2>&1 &

# =========================
# 10. 状态输出
# =========================
echo "===================="
echo "✅ HAX BOT 6.7 安装成功"
echo "📂 安装目录: $APP"
echo "📊 BOT + COLLECTOR 已运行"
echo "===================="
