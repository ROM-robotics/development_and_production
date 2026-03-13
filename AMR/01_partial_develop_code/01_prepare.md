# Development Environment Preparation

> Development စတင်မတိုင်မီ အောက်ပါ အဆင့်များကို ပြင်ဆင်ထားရန် လိုအပ်ပါသည်။  
> **Automated Script** — [`01_prepare.sh`](01_prepare.sh) ကို run ခြင်းဖြင့် အဆင့်အားလုံးကို အလိုအလျောက် လုပ်ဆောင်နိုင်ပါသည်။

---

## Prerequisites

| # | Item | Required |
|---|------|----------|
| 1 | Ubuntu **22.04.5 LTS** | OS version တိကျရပါမည် |
| 2 | SSH Key | `ROM-robotics` GitHub org ကို access လုပ်နိုင်ရမည် |
| 3 | ROS 2 **Humble** | `/opt/ros/humble/setup.bash` ရှိရမည် |
| 4 | User `mr_robot` | System user account ရှိရပါမည် |
| 5 | VS Code | `code` command available ဖြစ်ရမည် |

---

## Step-by-Step Setup

### Step 1 — OS Version စစ်ဆေးခြင်း

```bash
grep -q "Ubuntu 22.04" /etc/os-release && echo "✅ OK" || echo "❌ Ubuntu 22.04 မဟုတ်ပါ"
```

### Step 2 — SSH Key ပြင်ဆင်ခြင်း

SSH key generate လုပ်ပြီး GitHub account တွင် ထည့်သွင်းထားရပါမည်။

```bash
ssh -T git@github.com
# Hi <username>! You've successfully authenticated ...
```

### Step 3 — ROS 2 Humble စစ်ဆေးခြင်း

```bash
[ -f /opt/ros/humble/setup.bash ] && echo "✅ OK" || echo "❌ ROS2 Humble မရှိပါ"
```

### Step 4 — User Account စစ်ဆေးခြင်း

```bash
id mr_robot >/dev/null 2>&1 && echo "✅ OK" || echo "❌ mr_robot user မရှိပါ"
```

### Step 5 — Work Directory ပြင်ဆင်ခြင်း

```bash
mkdir -p /home/mr_robot/Desktop/Git
```

### Step 6 — VS Code စစ်ဆေးခြင်း

```bash
command -v code >/dev/null && echo "✅ OK" || echo "❌ VS Code မရှိပါ"
```

### Step 7 — VS Code Extension Install လုပ်ခြင်း

1. [rom_vscode_extension](https://github.com/ROM-robotics/rom_vscode_extension) repository ကို clone လုပ်ပါ။  
2. `robot-code-sync-0.0.1.vsix` ဖိုင်ကို VS Code တွင် install လုပ်ပါ။  
3. VS Code ကို **restart** လုပ်ပါ။

```bash
# Example
code --install-extension robot-code-sync-0.0.1.vsix --force
```

### Step 8 — ROM Robotics Repository Clone လုပ်ခြင်း

[rom_robotics](https://github.com/ROM-robotics/rom_robotics) repository ကို branch နှင့် tag ရွေးချယ်ပြီး recursive submodule များအပါအဝင် clone လုပ်ပါ။

```bash
BRANCH="arc-humble-release"
TAG="v1.0.5"
WORK_DIR="/home/mr_robot/Desktop/Git"

git clone --branch "$BRANCH" git@github.com:ROM-robotics/rom_robotics.git "$WORK_DIR/rom_robotics"
cd "$WORK_DIR/rom_robotics"
git fetch --tags
git checkout "$TAG"
git submodule update --init --recursive
```

---

## Quick Start (Automated)

အထက်ပါ အဆင့်အားလုံးကို တစ်ခါတည်း run လိုပါက —

```bash
bash 01_prepare.sh
```

> **Note:** Script သည် Zenity GUI dialog များဖြင့် step-by-step guide လုပ်ပေးပါသည်။

---

## Final Directory Structure

```
/home/mr_robot/Desktop/Git/
└── rom_robotics/          ← main workspace
    ├── <submodule_1>/
    ├── <submodule_2>/
    └── ...
```