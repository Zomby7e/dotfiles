#!/usr/bin/env fish
function debian-postinstall
    echo "Updating package index..."
    sudo apt update

    set packages vim git bat source-highlight duf fd-find lsd qalc
    set to_install

    for pkg in $packages
        if not dpkg -s $pkg >/dev/null 2>&1
            echo "Will install: $pkg"
            set to_install $to_install $pkg
        else
            echo "Already installed: $pkg"
        end
    end

    if count $to_install > /dev/null
        sudo apt install -y $to_install
    end
end
