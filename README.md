# REO CLI
A lightweight Bash CLI framework designed to run applications inside the terminal. It works out of the box simply clone and execute, with zero build steps, no package managers, and no runtime dependencies.
---

## Requirements

- Linux, WSL, or Termux
- bash 4+
- curl
- git

---

## Install

### Quick install (recommended)

```bash
bash <(curl -fsSL https://Xion-Xer.koyeb.app/install.sh)
```

Then reload your shell and verify:

```bash
source ~/.bashrc
reo
reo help
```

### Manual install

#### 1. Clone the repo

```bash
git clone https://github.com/Xion-Xer/reo.git
cd reo
```

#### 2. Run the installer

```bash
chmod +x install.sh
./install.sh
```

#### 3. Reload your shell

```bash
source ~/.bashrc
```

#### 4. Verify

```bash
reo
reo help
```

---

## Usage

```bash
reo               # home screen
reo help          # interactive plugin browser (↑ ↓ + ENTER)
reo <name>        # run plugin directly
```

---

## Adding Plugins

Create a `.sh` file in the `apps/` folder with these header comments:

```bash
# name: hello
# description: Says hello

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/core/index."

echo -e "  ${CYAN}${BOLD}Hello, world!${RESET}"
```

No reinstall needed — `reo help` picks it up instantly.

---


## Uninstall

```bash
# remove PATH entry from ~/.bashrc
sed -i '/# REO CLI/d' ~/.bashrc
sed -i '/reo/d' ~/.bashrc

# delete the repo
cd ..
rm -rf reo
```

---

## License


MIT
