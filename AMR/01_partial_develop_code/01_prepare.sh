#!/bin/bash

########################################
# CONFIG
########################################

WIDTH=500
HEIGHT=300

LOG_FILE="/tmp/rom_setup.log"
> "$LOG_FILE"

ROM_REPO="git@github.com:ROM-robotics/rom_robotics.git"
EXT_REPO="git@github.com:ROM-robotics/rom_vscode_extension.git"

USER_NAME="mr_robot"
WORK_DIR="/home/$USER_NAME/Desktop/Git"
REPO_DIR="$WORK_DIR/rom_robotics"

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
# STEP 1 OS CHECK
########################################

confirm "Step 1

Ubuntu 22.04 ဖြစ်/မဖြစ် စစ်ဆေးမည်။"

grep -q "Ubuntu 22.04" /etc/os-release || error "Ubuntu 22.04 မဟုတ်ပါ"

info "Ubuntu Version မှန်ပါသည်"

########################################
# STEP 2 ROS
########################################

confirm "Step 2

ROS2 Humble ရှိ/မရှိ စစ်ဆေးမည်"

[ -f /opt/ros/humble/setup.bash ] || error "ROS2 Humble မရှိပါ"

info "ROS2 Humble ရှိပါသည်"

########################################
# STEP 3 USER
########################################

confirm "Step 3

mr_robot user ရှိ/မရှိ စစ်ဆေးမည်"

id mr_robot >/dev/null || error "mr_robot user မရှိပါ"

########################################
# STEP 4 DIRECTORY
########################################

confirm "Step 4

Development directory create လုပ်မည်"

mkdir -p "$WORK_DIR"

info "$WORK_DIR directory ready"

########################################
# STEP 5 VSCODE
########################################

confirm "Step 5

VS Code ရှိ/မရှိ စစ်ဆေးမည်"

command -v code >/dev/null || error "VS Code မရှိပါ"

########################################
# BRANCH INPUT
########################################

BRANCH_NAME=$(zenity --entry \
--width=$WIDTH \
--height=$HEIGHT \
--title="Branch Input" \
--text="Clone လုပ်မည့် Branch Name" \
--entry-text="arc-humble-release")

[ -z "$BRANCH_NAME" ] && quit_install

########################################
# TAG INPUT
########################################

TAG_NAME=$(zenity --entry \
--width=$WIDTH \
--height=$HEIGHT \
--title="Tag Input" \
--text="Checkout လုပ်မည့် Tag Name" \
--entry-text="v1.0.5")

[ -z "$TAG_NAME" ] && quit_install

########################################
# INSTALL PROCESS
########################################

(

echo "5"
echo "# [5%]
Directory: $WORK_DIR
Environment prepare လုပ်နေပါသည်..."

sleep 1

########################################
# VSCode extension
########################################

echo "15"
echo "# [15%]
Directory: /tmp
VSCode Extension clone လုပ်နေပါသည်..."

TEMP_EXT="/tmp/ext_$$"

git clone "$EXT_REPO" "$TEMP_EXT" >> "$LOG_FILE" 2>&1

echo "25"
echo "# [25%]
Directory: /tmp
VSCode Extension install လုပ်နေပါသည်..."

VSIX_FILE=$(find "$TEMP_EXT" -name "*.vsix" | head -n1)

if [ -n "$VSIX_FILE" ]; then
code --install-extension "$VSIX_FILE" --force >> "$LOG_FILE" 2>&1
fi

rm -rf "$TEMP_EXT"

########################################
# CLONE
########################################

echo "40"
echo "# [40%]
Directory: $WORK_DIR
Repository clone လုပ်နေပါသည်..."

if [ ! -d "$REPO_DIR" ]; then
git clone --branch "$BRANCH_NAME" "$ROM_REPO" "$REPO_DIR" >> "$LOG_FILE" 2>&1
fi

########################################
# CHECKOUT
########################################

echo "65"
echo "# [65%]
Directory: $REPO_DIR
Tag checkout လုပ်နေပါသည်..."

cd "$REPO_DIR"

git fetch --tags >> "$LOG_FILE" 2>&1
git checkout "$TAG_NAME" >> "$LOG_FILE" 2>&1

########################################
# SUBMODULE
########################################

echo "85"
echo "# [85%]
Directory: $REPO_DIR
Submodule update လုပ်နေပါသည်..."

git submodule update --init --recursive >> "$LOG_FILE" 2>&1

########################################
# COMPLETE
########################################

echo "100"
echo "# [100%]
Directory: $REPO_DIR
Installation Completed"

) |
zenity --progress \
--width=$WIDTH \
--height=$HEIGHT \
--title="Robotics Developer Setup" \
--text="Installation စတင်နေပါသည်..." \
--percentage=0 \
--auto-close

########################################
# DONE
########################################

zenity --info \
--width=$WIDTH \
--height=$HEIGHT \
--text="Setup အောင်မြင်စွာ ပြီးဆုံးပါပြီ။

Workspace Location
$REPO_DIR

VS Code restart လုပ်ပါ။

Quit Shortcut : Ctrl+C"