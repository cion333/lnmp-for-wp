#!/bin/bash
WordPress 终极全自动建站工具 (V7.1 究极性能版)
#    集成：BBR + TFO + PHP 8.3 + WP-CLI + Redis + 汇总报告
#    # ============================================================
#
#    # --- 0. 环境预检 ---
#    if [ ! -f /etc/debian_version ]; then
#        echo "错误：此脚本仅支持 Ubuntu/Debian 系统。"
#            exit 1
#            fi
#
#            clear
#            echo "################################################"
#            echo "#    CloudCone VPS 专属优化：BBR + TFO + WP    #"
#            echo "################################################"
#            echo ""
#            read -p "确认域名解析已生效请按 [回车]，取消请按 [Ctrl+C]: " CONFIRM_DNS
#
#            # --- 1. 交互询问 ---
#            read -p "网站目录名 (例如 myblog): " WEB_DIR
#            read -p "网站域名 (例如 mydomain.com): " DOMAIN
#
#            echo "--- 数据库配置 ---"
#            read -p "请输入数据库名 [默认: wordpress]: " DB_NAME
#            DB_NAME=${DB_NAME:-"wordpress"}
#            read -p "请输入数据库用户 [默认: wordpress]: " DB_USER
#            DB_USER=${DB_USER:-"wordpress"}
#            read -p "请输入数据库密码 [直接回车则随机生成]: " DB_PASS
#            [ -z "$DB_PASS" ] && DB_PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 12)
#
#            echo "--- WordPress 站点设置 ---"
#            read -p "WordPress 站点标题: " WP_TITLE
#            read -p "WordPress 管理员账号: " WP_ADMIN_USER
#            read -p "WordPress 管理员密码: " WP_ADMIN_PASS
#            read -p "WordPress 管理员邮箱: " WP_ADMIN_EMAIL
#
#            read -p "是否申请 SSL 证书 (HTTPS)? (y/n): " NEED_SSL
#            if [[ "$NEED_SSL" =~ ^[Yy]$ ]]; then
#                SSL_EMAIL=${WP_ADMIN_EMAIL}
#                    SSL_STATUS="已配置 (Certbot + 自动重载钩子)"
#                    else
#                        SSL_STATUS="未配置"
#                        fi
#
#                        # --- 2. 网络内核深度优化 (BBR + TFO) ---
#                        echo "正在注入内核优化参数 (BBR & TCP Fast Open)..."
#                        sudo sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
#                        sudo sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
#                        sudo sed -i '/net.ipv4.tcp_fastopen/d' /etc/sysctl.conf
#
#                        cat <<EOF | sudo tee -a /etc/sysctl.conf
#                        net.core.default_qdisc=fq
#                        net.ipv4.tcp_congestion_control=bbr
#                        net.ipv4.tcp_fastopen = 3
#                        EOF
#                        sudo sysctl -p
#
#                        # --- 3. 安装核心环境 ---
#                        sudo apt update && sudo apt install -y software-properties-common curl
#                        sudo add-apt-repository -y ppa:ondrej/php
#                        sudo apt update
#                        sudo apt install -y nginx mariadb-server redis-server certbot python3-certbot-nginx \
#                        php8.3-{common,cli,fpm,mysql,mysqli,redis,imagick,curl,bz2,mbstring,intl,gd,xml,xmlrpc,soap,zip,bcmath,exif,opcache}
#
#                        # 安装 WP-CLI
#                        if [ ! -f /usr/local/bin/wp ]; then
#                            curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
#                                chmod +x wp-cli.phar
#                                    sudo mv wp-cli.phar /usr/local/bin/wp
#                                    fi
#
#                                    # --- 4. 基础服务启动与数据库加固 ---
#                                    sudo systemctl enable mariadb redis-server
#                                    sudo systemctl start mariadb redis-server
#                                    sudo mysql -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
#                                    sudo mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
#                                    sudo mysql -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';"
#                                    sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
#                                    sudo mysql -e "DROP DATABASE IF EXISTS test;"
#                                    sudo mysql -e "FLUSH PRIVILEGES;"
#
#                                    # --- 5. 配置优化 (PHP & Nginx) ---
#                                    # PHP 性能调优
#                                    for param in post_max_size=128M memory_limit=512M upload_max_filesize=512M max_execution_time=300 opcache.enable=1
#                                    do
#                                        key=${param%=*}
#                                            value=${param#*=}
#                                                sudo sed -i "s|^;*\($key\)\s*=.*|\1 = $value|" /etc/php/8.3/fpm/php.ini
#                                                done
#                                                sudo sed -i '/http {/a \    client_max_body_size 512M;' /etc/nginx/nginx.conf 2>/dev/null
#
#                                                # 生成优化版 Nginx 配置 (支持 TFO)
#                                                cat <<EOF | sudo tee /etc/nginx/sites-available/$DOMAIN
#                                                server {
#                                                    listen 80;
#                                                        server_name $DOMAIN www.$DOMAIN;
#                                                            root /home/www/$WEB_DIR;
#                                                                index index.php index.html;
#                                                                    return 301 https://\$host\$request_uri;
#                                                                    }
#
#                                                                    server {
#                                                                        # 核心优化：针对 HTTPS 开启 reuseport 和 fastopen
#                                                                            listen 443 ssl reuseport fastopen=256;
#                                                                                server_name $DOMAIN www.$DOMAIN;
#                                                                                    root /home/www/$WEB_DIR;
#                                                                                        index index.php index.html;
#
#                                                                                            client_max_body_size 512M;
#
#                                                                                                # SSL 占位符 (Certbot 随后会更新)
#                                                                                                    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
#                                                                                                        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
#
#                                                                                                            location / { try_files \$uri \$uri/ /index.php?\$args; }
#                                                                                                                
#                                                                                                                    location ~ \.php$ {
#                                                                                                                            include snippets/fastcgi-php.conf;
#                                                                                                                                    fastcgi_pass unix:/run/php/php8.3-fpm.sock;
#                                                                                                                                            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
#                                                                                                                                                }
#
#                                                                                                                                                    # 静态资源长期缓存
#                                                                                                                                                        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|otf|webp)\$ {
#                                                                                                                                                                expires max;
#                                                                                                                                                                        log_not_found off;
#                                                                                                                                                                                access_log off;
#                                                                                                                                                                                    }
#
#                                                                                                                                                                                        location ~ /\. { deny all; }
#                                                                                                                                                                                        }
#                                                                                                                                                                                        EOF
#
#                                                                                                                                                                                        sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
#                                                                                                                                                                                        sudo rm -f /etc/nginx/sites-enabled/default
#
#                                                                                                                                                                                        # --- 6. WordPress 自动安装与优化 ---
#                                                                                                                                                                                        sudo mkdir -p /home/www/$WEB_DIR
#                                                                                                                                                                                        cd /home/www/$WEB_DIR
#                                                                                                                                                                                        sudo wp core download --locale=zh_CN --allow-root
#                                                                                                                                                                                        sudo wp config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASS --allow-root
#                                                                                                                                                                                        sudo wp core install --url=$DOMAIN --title="$WP_TITLE" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_EMAIL --allow-root
#
#                                                                                                                                                                                        # 伪静态与媒体优化
#                                                                                                                                                                                        sudo wp rewrite structure '/%postname%/' --allow-root
#                                                                                                                                                                                        sudo wp option update thumbnail_size_w 0 --allow-root
#                                                                                                                                                                                        sudo wp option update thumbnail_size_h 0 --allow-root
#                                                                                                                                                                                        sudo wp option update medium_size_w 0 --allow-root
#                                                                                                                                                                                        sudo wp option update medium_size_h 0 --allow-root
#                                                                                                                                                                                        sudo wp option update large_size_w 0 --allow-root
#                                                                                                                                                                                        sudo wp option update large_size_h 0 --allow-root
#
#                                                                                                                                                                                        sudo chown -R www-data:www-data /home/www/$WEB_DIR
#
#                                                                                                                                                                                        # --- 7. SSL 证书与自动重载钩子 ---
#                                                                                                                                                                                        if [[ "$NEED_SSL" =~ ^[Yy]$ ]]; then
#                                                                                                                                                                                            sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email $SSL_EMAIL --redirect
#                                                                                                                                                                                                
#                                                                                                                                                                                                    sudo mkdir -p /etc/letsencrypt/renewal-hooks/deploy/
#                                                                                                                                                                                                        echo -e '#!/bin/bash\nsystemctl reload nginx' | sudo tee /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
#                                                                                                                                                                                                            sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
#                                                                                                                                                                                                            fi
#
#                                                                                                                                                                                                            sudo nginx -t && sudo systemctl restart nginx php8.3-fpm
#
#                                                                                                                                                                                                            # --- 8. 安装汇总报告 (恢复核心部分) ---
#                                                                                                                                                                                                            clear
#                                                                                                                                                                                                            echo "===================================================="
#                                                                                                                                                                                                            echo "          WordPress 自动建站安装汇总报告 (V7.1)"
#                                                                                                                                                                                                            echo "===================================================="
#                                                                                                                                                                                                            echo "【站点性能状态】"
#                                                                                                                                                                                                            echo "  - BBR 加速:       $(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')"
#                                                                                                                                                                                                            echo "  - TCP Fast Open:  $(cat /proc/sys/net/ipv4/tcp_fastopen) (状态3为开启)"
#                                                                                                                                                                                                            echo "  - PHP 版本:       8.3 (Opcache Enabled)"
#                                                                                                                                                                                                            echo "  - Redis 缓存:     已安装 (请在 WP 后台开启插件)"
#                                                                                                                                                                                                            echo ""
#                                                                                                                                                                                                            echo "【站点基础信息】"
#                                                                                                                                                                                                            echo "  - 网站域名:       $DOMAIN"
#                                                                                                                                                                                                            echo "  - 网站目录:       /home/www/$WEB_DIR"
#                                                                                                                                                                                                            echo "  - SSL 状态:       $SSL_STATUS"
#                                                                                                                                                                                                            echo ""
#                                                                                                                                                                                                            echo "【数据库配置】"
#                                                                                                                                                                                                            echo "  - 数据库名:       $DB_NAME"
#                                                                                                                                                                                                            echo "  - 数据库用户:     $DB_USER"
#                                                                                                                                                                                                            echo "  - 数据库密码:     $DB_PASS"
#                                                                                                                                                                                                            echo ""
#                                                                                                                                                                                                            echo "【WordPress 管理信息】"
#                                                                                                                                                                                                            echo "  - 管理员账号:     $WP_ADMIN_USER"
#                                                                                                                                                                                                            echo "  - 管理员密码:     $WP_ADMIN_PASS"
#                                                                                                                                                                                                            echo ""
#                                                                                                                                                                                                            echo "===================================================="
#                                                                                                                                                                                                            echo "            💡 后续建议：异地备份方案 (NAS)"
#                                                                                                                                                                                                            echo "----------------------------------------------------"
#                                                                                                                                                                                                            echo "1. VPS端定时打包：建议使用脚本每周一 03:00 运行"
#                                                                                                                                                                                                            echo "2. NAS端拉取备份：建议在 NAS 任务计划配置以下命令 (05:00)"
#                                                                                                                                                                                                            echo "    rsync -avz -e \"ssh -p VPS端口\" root@$DOMAIN:/home/www/$WEB_DIR /群晖路径/"
#                                                                                                                                                                                                            echo "===================================================="
#                                                                                                                                                                                                            echo "请及时记录以上信息。祝您的网站运行愉快！"
