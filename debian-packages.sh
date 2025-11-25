#!/usr/bin/env bash
set -e

debian_postinstall() {
    # List of desired packages
    packages=(vim git bat source-highlight duf fd-find lsd qalc ncdu btop curl wget unar stow)
    to_install=()
    dry_run=false

    # Check for --dry-run flag
    if [[ "$1" == "--dry-run" ]]; then
        dry_run=true
    fi

    # Check which packages are missing
    for pkg in "${packages[@]}"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "Will install: $pkg"
            to_install+=("$pkg")
        else
            echo "Already installed: $pkg"
        fi
    done

    # Install missing packages if needed
    if [ ${#to_install[@]} -gt 0 ]; then
        if $dry_run; then
            echo "[Dry-run] Missing packages would be installed: ${to_install[*]}"
        else
            echo "Updating package index..."
            sudo apt update
            sudo apt install -y "${to_install[@]}"
        fi
    else
        echo "All packages already installed. Nothing to do."
    fi
}

# Pass the first argument to the function (e.g., --dry-run)
debian_postinstall "$1"
