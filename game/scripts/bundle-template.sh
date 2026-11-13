mkdir -p releases
rm -rf releases/love2d-fennel-template
mkdir releases/love2d-fennel-template
cp -rf *.fnl *.lua buildtools assets license.txt lib releases/love2d-fennel-template
rm -rf releases/love2d-fennel-template/buildtools/appimage/love-prepared/
rm releases/love2d-fennel-template/buildtools/appimage/*.AppImage
rm -rf releases/love2d-fennel-template/buildtools/appimage/squashfs-root
cd releases
find love2d-fennel-template | sort | uniq | env TZ=UTC zip -r -q -9 -X love2d-fennel-template.zip -@
rm -rf love2d-fennel-template/buildtools/
find love2d-fennel-template | sort | uniq | env TZ=UTC zip -r -q -9 -X love2d-fennel-template-nobuildtools.zip -@
rm -rf love2d-fennel-template
