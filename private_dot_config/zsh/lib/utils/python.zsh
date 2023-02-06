# list python packages installed both as user and system wide
function pip_list_dup() {
	grep -Fxf <(pip list --user | awk '{print $1}')  <(pip list --path /usr/lib/python$(pacman -Qi python | awk '/Version/ {print $3}' | grep -o '[0-9]\.[0-10]*')/site-packages | awk '{print $1}')
}
