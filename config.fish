# Firendly Interactive Shell configure
# Path of this file ~/.config/fish/config.fish
# @zomby7e

if status is-interactive
    # Commands to run in interactive sessions can go here
    # No content yet
end

# varribles
set need_install # packages that need to be installed
set install_hint 1 # 1 on, 0 off

# Editor config
if command -v kate >/dev/null
    set -x VISUAL "kate"
else
    set need_install $need_install "kate "
end

if command -v vim >/dev/null
    set -x EDITOR "vim"
    alias vi vim
    alias vimfish "vim ~/.config/fish/config.fish"
else
    set need_install $need_install "vim "
end

# Command line tools
# Better cat
if command -v bat >/dev/null
    alias cat bat
else
    set need_install $need_install "bat "
end
# Better less
if command -v source-highlight >/dev/null
    set src_hl_path (which src-hilite-lesspipe.sh)
    export LESSOPEN="| $src_hl_path %s"
    export LESS=' -R '
else
    set need_install $need_install "source-highlight "
end

# Fish config
function fish_greeting
    printf "🐟 opened @ \033[0;92m%s \033[0m\n" (date "+%H:%M %m/%d/%Y")
    if string length --quiet $need_install
        and test "$install_hint" = "1"
        printf "There are some packages missing, install them for better experience:\n%s\n" $need_install
        printf "Edit your 🐟 config file to disable this hint, Enter `vimfish`.\n"
    end
    set current_shell (basename $SHELL)
    if not test "$current_shell" = "fish"
        printf "Your default shell is not 🐟, if you need enter `ineedfish`\n"
        alias ineedfish 'chsh -s (which fish)'
    end
end

# Web search engines
# TODO: If FF not installed turn to Chromium
function google
    set -l query (string join " " $argv)
    firefox "https://www.google.com/search?q=$query"
end

function youtube
    set -l query (string join " " $argv)
    firefox "https://www.youtube.com/results?search_query=$query"
end

# Get basic system information
function basicinfo
    printf "User@Host: %s@%s\n" $USER (hostname)
    # Get distro name through the file.
    if test -f /etc/os-release
        set distro_name (grep -E "^PRETTY_NAME|^NAME" /etc/os-release | awk -F "=" '{print $2}' | tr -d '"' | head -n1)
        if test -n "$distro_name"
        else
            set distro_name "Other Distro"
        end
    else
        set distro_name "Other Distro"
    end
    printf "Distro: %s\n" $distro_name
    printf "OS Type: %s\n" (uname -sm)
    printf "Kernel Version: %s\n" (uname -r)
    set uptime (uptime -p)
    set uptime (string replace "up " "" $uptime)
    printf "Uptime: %s\n" $uptime
    printf "Shell: %s\n" (basename $SHELL)
    set cpu_name (cat /proc/cpuinfo | grep "model name" | uniq | sed "s/.*: //")
    printf "CPU: %s\n" $cpu_name
    # Get GPU name
    if test (uname -s) = "Linux"
        set gpu_driver (lspci -nnk | awk -F ': ' \
			          '/Display|3D|VGA/{nr[NR+2]}; NR in nr {printf $2 ", "; exit}')
        set gpu_driver (string replace "," "" $gpu_driver)

        if string match -q "nvidia" $gpu_driver
            set gpu_driver (cat /proc/driver/nvidia/version)
            set gpu_driver (string replace --regex ".*Module  " "" $gpu_driver)
            set gpu_driver (string replace --regex "  .*" "" $gpu_driver)
            set gpu_driver "NVIDIA $gpu_driver"
        end
        printf "GPU: %s\n" $gpu_driver
    end
    switch (uname -s)
    case 'Linux'
	    set mem_info (free -h | grep Mem)
	    set total_mem (echo $mem_info | awk '{print $2}')
	    set used_mem (echo $mem_info | awk '{print $3}')
	    echo "Memory: $used_mem / $total_mem"
    case 'FreeBSD'
    case 'NetBSD'
    case 'OpenBSD'
    case 'DragonFly'
        set -l mem_info (vmstat -H)
	    set -l total_mem (echo $mem_info | awk '{print $4}')
	    set -l used_mem (echo $mem_info | awk '{print $3}')
	    echo "Memory: $used_mem / $total_mem"
    case '*'
        :
    end
end
