#!/bin/bash

########################################
# CONFIG
########################################

WIDTH=500
HEIGHT=300

LOG_FILE="/tmp/rom_deploy.log"
> "$LOG_FILE"

USER_NAME="mr_robot"
REPO_DIR="/home/$USER_NAME/Desktop/Git/rom_robotics"
APP_DIR="$REPO_DIR/data/app"

########################################
# QUIT HANDLER
########################################

quit_install(){
zenity --warning \
--width=$WIDTH \
--height=$HEIGHT \
--text="Installer ကို ရပ်လိုက်ပါပြီ။
Shortcut: Ctrl+C

လုပ်ဆောင်မှုအားလုံး ရပ်သွားပါပြီ။"

exit 1
}

trap quit_install SIGINT SIGTERM

########################################
# UI HELPERS
########################################

info(){
zenity --info \
--width=$WIDTH \
--height=$HEIGHT \
--text="$1

Quit Shortcut : Ctrl+C"
}

error(){
zenity --error \
--width=$WIDTH \
--height=$HEIGHT \
--text="$1"
exit 1
}

confirm(){
zenity --question \
--width=$WIDTH \
--height=$HEIGHT \
--text="$1

Quit Shortcut : Ctrl+C"

if [ $? -ne 0 ]; then
quit_install
fi
}

########################################
# STEP 1 USER CHECK
########################################

confirm "Step 1

mr_robot user ရှိ/မရှိ စစ်ဆေးမည်"

id "$USER_NAME" >/dev/null 2>&1 || error "mr_robot user မရှိပါ"

info "mr_robot user ရှိပါသည်"

########################################
# STEP 2 GIT STATUS CHECK
########################################

confirm "Step 2

$REPO_DIR
nothing to commit ဖြစ်/မဖြစ် စစ်ဆေးမည်"

[ -d "$REPO_DIR/.git" ] || error "$REPO_DIR သည် git repository မဟုတ်ပါ"

cd "$REPO_DIR"

GIT_STATUS=$(git status --porcelain 2>&1)

if [ -n "$GIT_STATUS" ]; then
error "$REPO_DIR တွင် uncommitted changes ရှိနေပါသည်။

nothing to commit ဖြစ်အောင် commit သို့မဟုတ် stash လုပ်ပါ။"
fi

info "Repository သည် clean ဖြစ်ပါသည်။
nothing to commit"

########################################
# STEP 3 TAG CHECK
########################################

confirm "Step 3

rom_robotics repository ၏ tag စစ်ဆေးမည်"

cd "$REPO_DIR"

TAG_NAME=$(git describe --tags --exact-match 2>/dev/null)

if [ -z "$TAG_NAME" ]; then
# exact tag မရှိလျှင် closest tag ကို ရှာကြည့်မည်
TAG_NAME=$(git describe --tags 2>/dev/null)
fi

if [ -z "$TAG_NAME" ]; then
error "rom_robotics repository တွင် tag မရှိပါ။

Tag မရှိသောကြောင့် ဆက်လုပ်၍ မရပါ။"
fi

########################################
# STEP 4 APPIMAGE CHECK
########################################

confirm "Step 4

rsync_qt AppImage ရှိ/မရှိ စစ်ဆေးမည်"

APPIMAGE=$(find "$APP_DIR" -maxdepth 1 -name "rsync_qt-linux-v*.AppImage" 2>/dev/null | head -n1)

if [ -z "$APPIMAGE" ]; then
info "rsync_qt AppImage မရှိပါ။

download_apps script ဖြင့် download လုပ်ပါမည်..."

DOWNLOAD_SCRIPT="$APP_DIR/download_apps_v1.0.5.sh"

[ -f "$DOWNLOAD_SCRIPT" ] || error "Download script မရှိပါ။
$DOWNLOAD_SCRIPT"

(
echo "10"
echo "# [10%] AppImage download စတင်နေပါသည်...
Directory: $APP_DIR"

cd "$APP_DIR"
bash "$DOWNLOAD_SCRIPT" >> "$LOG_FILE" 2>&1

echo "100"
echo "# [100%] Download ပြီးဆုံးပါပြီ"
) |
zenity --progress \
--width=$WIDTH \
--height=$HEIGHT \
--title="AppImage Download" \
--text="Download လုပ်နေပါသည်..." \
--percentage=0 \
--auto-close

# download ပြီးနောက် ပြန်ရှာမည်
APPIMAGE=$(find "$APP_DIR" -maxdepth 1 -name "rsync_qt-linux-v*.AppImage" 2>/dev/null | head -n1)

[ -z "$APPIMAGE" ] && error "Download ပြီးသော်လည်း AppImage မတွေ့ပါ"
else
info "rsync_qt AppImage တွေ့ပါသည်။

$(basename "$APPIMAGE")"
fi

########################################
# STEP 5 SHOW TAG NAME
########################################

info "Current Tag : $TAG_NAME

Repository : $REPO_DIR
AppImage  : $(basename "$APPIMAGE")"

########################################
# STEP 6 RUN APPIMAGE
########################################

confirm "Step 6

rsync_qt AppImage ကို run မည်

$(basename "$APPIMAGE")"

chmod +x "$APPIMAGE"

"$APPIMAGE" >> "$LOG_FILE" 2>&1 &

info "rsync_qt AppImage ကို run လိုက်ပါပြီ။

Quit Shortcut : Ctrl+C"
