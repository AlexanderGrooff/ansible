#/bin/env sh
cp xscreensaver_daemon.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable xscreensaver_daemon
systemctl start xscreensaver_daemon
