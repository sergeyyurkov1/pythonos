#!/bin/sh

_step_counter=0
step() {
	_step_counter=$(( _step_counter + 1 ))
	printf '\n\033[1;36m%d) %s\033[0m\n' $_step_counter "$@" >&2  # bold cyan
}

uname -a

step 'Set up timezone'
setup-timezone -z Asia/Shanghai

step 'Set up networking'
cat > /etc/network/interfaces <<-EOF
	iface lo inet loopback
	iface eth0 inet dhcp
EOF
ln -s networking /etc/init.d/net.lo
ln -s networking /etc/init.d/net.eth0

step 'Adjust rc.conf'
sed -Ei \
	-e 's/^[# ](rc_depend_strict)=.*/\1=NO/' \
	-e 's/^[# ](rc_logger)=.*/\1=YES/' \
	-e 's/^[# ](unicode)=.*/\1=YES/' \
	/etc/rc.conf

step 'Enable services'
rc-update add acpid default
rc-update add chronyd default
rc-update add crond default
rc-update add net.eth0 default
rc-update add net.lo boot
rc-update add termencoding boot

step 'List /usr/local/bin'
ls -la /usr/local/bin

step '/usr/local/bin'
chmod +x /usr/local/bin/install-pui
chmod +x /usr/local/bin/git-proxy-on
chmod +x /usr/local/bin/git-proxy-on-2
chmod +x /usr/local/bin/git-proxy-off

step 'Setup'
adduser -D --shell /bin/ash pui
echo 'pui:pui' | chpasswd
for u in $(ls /home); do for g in wheel disk lp input audio cdrom dialout video netdev games users; do addgroup $u $g; done;done
echo 'permit persist :wheel' > /etc/doas.d/doas.conf
setup-xorg-base
apk add font-dejavu
apk add dbus
dbus-uuidgen > /var/lib/dbus/machine-id
rc-update add dbus
apk add i3wm xfce4-terminal i3status bash git
echo 'exec i3' > /home/pui/.xinitrc
echo 'startx' > /home/pui/.profile
# doas -n -u pui 'i3-config-wizard --modifier win'
# echo 'exec_always --no-startup-id "xfce4-terminal --hide-menubar --hide-toolbar --hide-scrollbar"' >> /home/pui/.config/i3/config
# echo "for_window [class=".*"] border none" >> /home/pui/.config/i3/config
apk add elogind polkit-elogind
