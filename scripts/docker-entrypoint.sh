#!/usr/bin/env bash


# Run XVfb in DISPLAY :99 as usual
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf &

# Run VNC in DISPLAY :98
mkdir -p ~/.vnc
# Password can only be 8 char at most
vncpasswd -f > ~/.vnc/passwd << EOF
userpass
EOF
chmod 600 ~/.vnc/passwd

USER=root /usr/bin/tightvncserver :98 &

#  Run SSH in port 22
/usr/sbin/sshd -D &

# Wait for background process to finish
sleep 10

# Execute any extra script

if find "/docker-entrypoint-scripts.d" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
for f in /docker-entrypoint-scripts.d/*; do
case "$f" in
    *.sh)     echo "$0: running $f"; . $f || true;;
    *requirements.txt)  echo "$0: install pip requirements file $f"; pip3 install -r $f || true;;
    *)        echo "$0: ignoring $f" ;;
esac
echo
done
fi

exec "$@"