#!/bin/bash

while test $# -gt 0; do
	case "$1" in
                --working-directory)
                        shift
                        if test $# != ""; then
                                WORKING_DIRECTORY=$1
                        else
                                echo "No working directory specified"
                                exit 1
                        fi
                        shift
                        ;;
                --static-directory)
                        shift
                        if test $# != ""; then
                                STATIC_DIRECTORY=$1
                        else
                                echo "No static directory specified"
                                exit 1
                        fi
                        shift
                        ;;
                --static-alias)
                        shift
                        if test $# != ""; then
                                STATIC_ALIAS=$1
                        else
                                echo "No static alias specified"
                                exit 1
                        fi
                        shift
                        ;;
                --wsgi-module)
                        shift
                        if test $# != ""; then
                                WSGI_MODULE=$1
                        else
                                echo "No WSGI module specified"
                                exit 1
                        fi
                        shift
                        ;;
        esac
done

# Generate UWSGI configuration files

mkdir -p /.uwsgi_config

UWSGI_PARAMS_FILE="/.uwsgi_config/uwsgi_params"

echo "uwsgi_param QUERY_STRING \$query_string;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param REQUEST_METHOD \$request_method;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param CONTENT_TYPE \$content_type;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param CONTENT_LENGTH \$content_length;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param REQUEST_URI \$request_uri;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param PATH_INFO \$document_uri;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param DOCUMENT_ROOT \$document_root;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param SERVER_PROTOCOL \$server_protocol;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param REMOTE_ADDR \$remote_addr;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param REMOTE_PORT \$remote_port;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param SERVER_ADDR \$server_addr;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param SERVER_PORT \$server_port;" >> $UWSGI_PARAMS_FILE
echo "uwsgi_param SERVER_NAME \$server_name;" >> $UWSGI_PARAMS_FILE

UWSGI_INI_FILE="/.uwsgi_config/uwsgi.ini"

echo "[uwsgi]" >> $UWSGI_INI_FILE
echo "chdir           = /app/$WORKING_DIRECTORY" >> $UWSGI_INI_FILE
echo "module          = $WSGI_MODULE" >> $UWSGI_INI_FILE
echo "home            = /.virtualenv/venv" >> $UWSGI_INI_FILE
echo "master          = true" >> $UWSGI_INI_FILE
echo "processes       = 10" >> $UWSGI_INI_FILE
echo "socket          = /.uwsgi_config/$WORKING_DIRECTORY.sock" >> $UWSGI_INI_FILE
echo "chmod-socket    = 666" >> $UWSGI_INI_FILE
echo "vacuum          = true" >> $UWSGI_INI_FILE

# Generate log-rotate rules

LOGROTATE_FILE="/etc/logrotate.d/nginx"

echo "/var/log/nginx/*.log {" >> $LOGROTATE_FILE
echo "	size 10m" >> $LOGROTATE_FILE
echo "	copytruncate" >> $LOGROTATE_FILE
echo "	create 640 root root" >> $LOGROTATE_FILE
echo "	su root root" >> $LOGROTATE_FILE
echo "  rotate 10" >> $LOGROTATE_FILE
echo "  compress" >> $LOGROTATE_FILE
echo "}" >> $LOGROTATE_FILE

# Remove default config
rm -f /etc/nginx/sites-enabled/default

# Generate nginx configuration file
NGINX_CONFIG_FILE="/etc/nginx/sites-enabled/django.conf"

echo "upstream django {" >> $NGINX_CONFIG_FILE
echo "    server unix:///.uwsgi_config/$WORKING_DIRECTORY.sock;" >> $NGINX_CONFIG_FILE
echo "}" >> $NGINX_CONFIG_FILE
echo "server {" >> $NGINX_CONFIG_FILE
echo "    listen      80;" >> $NGINX_CONFIG_FILE
echo "    server_name 0.0.0.0;" >> $NGINX_CONFIG_FILE
echo "    charset     utf-8;" >> $NGINX_CONFIG_FILE
echo "    error_log /var/log/nginx/error.log info;" >> $NGINX_CONFIG_FILE
echo "    client_max_body_size 75M;" >> $NGINX_CONFIG_FILE
echo "    client_header_buffer_size 64k;" >> $NGINX_CONFIG_FILE
echo "    large_client_header_buffers 4 64k;" >> $NGINX_CONFIG_FILE
echo "    location $STATIC_ALIAS { alias /app/$WORKING_DIRECTORY/$STATIC_DIRECTORY; }" >> $NGINX_CONFIG_FILE
echo "    location / { uwsgi_pass django; include $UWSGI_PARAMS_FILE; }" >> $NGINX_CONFIG_FILE
echo "}" >> $NGINX_CONFIG_FILE

# Generate supervisord config
SUPERVISOR_CONFIG_FILE="/etc/supervisor/conf.d/supervisor-app.conf"

rm -f $SUPERVISOR_CONFIG_FILE
echo "[supervisord]" >> $SUPERVISOR_CONFIG_FILE
echo "nodaemon=true" >> $SUPERVISOR_CONFIG_FILE
echo "[program:uwsgi]" >> $SUPERVISOR_CONFIG_FILE
echo "command = /usr/local/bin/uwsgi --ini $UWSGI_INI_FILE" >> $SUPERVISOR_CONFIG_FILE

# Install python requirements into virtualenv
/bin/bash -c "source /.virtualenv/venv/bin/activate && pip install -r /app/requirements.txt"

# Restart nginx
service nginx restart

# Start supervisord
/usr/bin/supervisord
