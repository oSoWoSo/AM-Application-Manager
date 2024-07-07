#!/bin/sh

# AM INSTALL SCRIPT VERSION 3.5
set -u
APP=gron.awk
SITE="xonixx/gron.awk"

# CREATE DIRECTORIES AND ADD REMOVER
[ -n "$APP" ] && mkdir -p "/opt/$APP/tmp" "/opt/$APP/icons" && cd "/opt/$APP/tmp" || exit 1
printf "#!/bin/sh\nset -e\nrm -f /usr/local/bin/$APP\nrm -R -f /opt/$APP" > ../remove
#printf '\n%s' "rm -f /usr/local/share/applications/$APP-AM.desktop" >> ../remove
chmod a+x ../remove || exit 1

# DOWNLOAD AND PREPARE THE APP, $version is also used for updates
version=$(curl -Ls https://api.github.com/repos/xonixx/gron.awk/releases | sed 's/[()",{} ]/\n/g' | grep 'https.*.gron.awk.*tarball' | head -1)
wget "$version" -O download.tar.gz || exit 1
[ -e ./*tar.* ] && tar fx ./*tar.* && rm -f ./*tar.*
cd ..
if [ -d ./tmp/* 2>/dev/null ]; then mv ./tmp/*/* ./; else mv ./tmp/* ./"$APP" 2>/dev/null || mv ./tmp/* ./; fi
rm -R -f ./tmp || exit 1
echo "$version" > ./version
chmod a+x ./$APP || exit 1

# LINK TO PATH
ln -s "/opt/$APP/$APP" "/usr/local/bin/$APP"

# SCRIPT TO UPDATE THE PROGRAM
cat >> ./AM-updater << 'EOF'
#!/bin/sh
set -u
APP=gron.awk
SITE="xonixx/gron.awk"
version0=$(cat "/opt/$APP/version")
version=$(curl -Ls https://api.github.com/repos/xonixx/gron.awk/releases | sed 's/[()",{} ]/\n/g' | grep 'https.*.gron.awk.*tarball' | head -1)
[ -n "$version" ] || { echo "Error getting link"; exit 1; }
if [ "$version" != "$version0" ]; then
	mkdir "/opt/$APP/tmp" && cd "/opt/$APP/tmp" || exit 1
	notify-send "A new version of $APP is available, please wait"
	wget "$version" -O download.tar.gz || exit 1
	[ -e ./*tar.* ] && tar fx ./*tar.* && rm -f ./*tar.*
	cd ..
	if [ -d ./tmp/* 2>/dev/null ]; then mv --backup=t ./tmp/*/* ./; else mv --backup=t ./tmp/* ./"$APP" 2>/dev/null || mv --backup=t ./tmp/* ./; fi
	chmod a+x ./"$APP" || exit 1
	echo "$version" > ./version
	rm -R -f ./tmp ./*~
	notify-send "$APP is updated!"
else
	echo "Update not needed!"
fi
EOF
chmod a+x ./AM-updater || exit 1
