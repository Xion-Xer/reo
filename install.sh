#!/usr/bin/env bash

# =========================================
# REO INSTALLER
# =========================================

REO_DIR="$(cd "$(dirname "$0")" && pwd)"
BASHRC="$HOME/.bashrc"
MARKER="# REO CLI"

echo ""
echo "=================================="
echo "        REO INSTALLER"
echo "=================================="
echo ""

# =========================================
# ALREADY INSTALLED CHECK
# =========================================

if grep -q "$MARKER" "$BASHRC" 2>/dev/null; then
    echo "  [INFO] REO already in PATH ($BASHRC)"
    echo ""
else
    echo "  Adding REO to PATH..."
    echo "" >> "$BASHRC"
    echo "$MARKER" >> "$BASHRC"
    echo "export PATH=\"$REO_DIR:\$PATH\"" >> "$BASHRC"
    echo "  Done."
    echo ""
fi

# =========================================
# MAKE REO EXECUTABLE
# =========================================

if [[ ! -x "$REO_DIR/reo" ]]; then
    chmod +x "$REO_DIR/reo"
    echo "  Made reo executable."
    echo ""
fi

# =========================================
# APPS DIR
# =========================================

if [[ ! -d "$REO_DIR/apps" ]]; then
    mkdir -p "$REO_DIR/apps"
    echo "  Created apps/ directory."
    echo ""
fi

# =========================================
# CLEAN UP OLD INSTALLS
# =========================================

if [[ -f "$HOME/bin/reo" ]]; then
    rm -f "$HOME/bin/reo"
    echo "  Removed old ~/bin/reo"
    echo ""
fi

# =========================================
# RELOAD
# =========================================

export PATH="$REO_DIR:$PATH"
hash -r

echo "  REO installed successfully!"
echo ""
echo "  Reload your shell:"
echo "    source ~/.bashrc"
echo ""
echo "  Then run:"
echo "    reo help"
echo ""
