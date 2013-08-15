# Unicorn handle shell script
#
# APP_ROOT, PID             - are the same as you setup above
# CMD                       - use bundle binstubs (bundle install --binstubs) to
#                             forget about "bundle exec" stuff, run in demonize mode
#                             bin/unicorn is for Rack application (config.ru in root dir), but
#                             bin/unicorn_rails is to use with Rails 2.3
#
# To handle "app_preload true" configuration we should use USR2+QUIT signals, not HUP!
# So we rewrite capistrano deployment scripts to manage it.
#
# config/server/production/unicorn_init.sh


#!/bin/sh
set -u
set -e
# Example init script, this can be used with nginx, too,
# since nginx and unicorn accept the same signals

TIMEOUT=${TIMEOUT-60}
APP_ROOT=/var/rails/tor_search/current
PID=$APP_ROOT/tmp/pids/unicorn.pid
ENV=production
CMD="cd $APP_ROOT && bundle exec unicorn_rails -D -E $ENV -c $APP_ROOT/config/unicorn.rb"
action="$1"
set -u

old_pid="$PID.oldbin"

cd $APP_ROOT || exit 1

sig () {
        test -s "$PID" && kill -$1 `cat $PID`
}

oldsig () {
        test -s $old_pid && kill -$1 `cat $old_pid`
}

case $1 in
start)
        sig 0 && echo >&2 "Already running" && exit 0
        $CMD
        ;;
stop)
        sig QUIT && exit 0
        echo >&2 "Not running"
        ;;
force-stop)
        sig TERM && exit 0
        echo >&2 "Not running"
        ;;
restart|reload)
        sig HUP && echo reloaded OK && exit 0
        echo >&2 "Couldn't reload, starting '$CMD' instead"
        $CMD
        ;;
upgrade)
        sig TTOU && sleep 15
        sig USR2 && exit 0
        echo >&2 "Couldn't upgrade, starting '$CMD' instead"
        $CMD
        ;;
rotate)
        sig USR1 && echo rotated logs OK && exit 0
        echo >&2 "Couldn't rotate logs" && exit 1
        ;;
*)
        echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"
        exit 1
        ;;
esac