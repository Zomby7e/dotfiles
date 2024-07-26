# Firendly Interactive Shell configure
# Path of this file ~/.config/fish/config.fish
# @zomby7e

# varribles for this file
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
function google
    if test (count $argv) -eq 0
        echo "Usage: google <search term>"
        return 1
    end

    set -l query (string join " " $argv | string replace " " "%20")
    set -l url "https://www.google.com/search?q=$query"
    
    xdg-open $url
end

# YouTube
function youtube
    if test (count $argv) -eq 0
        echo "Usage: youtube <search term>"
        return 1
    end

    set -l query (string join " " $argv | string replace " " "%20")
    set -l url "https://www.youtube.com/results?search_query=$query"

    xdg-open $url
end

# Wikipedia
function wiki
    if test (count $argv) -eq 0
        echo "Usage: wiki <search term>"
        return 1
    end

    set -l query (string join " " $argv | string replace " " "%20")
    set -l url "https://en.wikipedia.org/wiki/Special:Search?search=$query"

    xdg-open $url
end

# Get basic system information
function basicinfo
    printf "User@Host: %s@%s\n" $USER (hostname)
    # Get distro name through the file.
    if test -f /etc/os-release
        set -l distro_name (grep '^NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
        set -l distro_version (grep '^VERSION=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
        echo "Distro: $distro_name $distro_version"
    else
        echo "Unable to retrieve distribution information."
    end
    printf "Kernel Info: %s\n" (uname -sr)
    printf "Platform: %s\n" (uname -m)
    set uptime (uptime -p)
    set uptime (string replace "up " "" $uptime)
    printf "Uptime: %s\n" $uptime
    printf "Shell: %s\n" (basename $SHELL)
    set cpu_name (cat /proc/cpuinfo | grep "model name" | uniq | sed "s/.*: //")

    # Get memory info
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
    #TODO: GPU modal nema, SWAP info, Disk usage
end

# Set Network proxy
function setproxy
    set -l host
    set -l port

    if test (count $argv) -eq 1
        set -l proxy (string split ":" $argv[1])
        set host $proxy[1]
        set port $proxy[2]
    else
        echo "Host name / IP address:"
        read host
        echo "Port:"
        read port
    end

    if test -z "$host" -o -z "$port"
        echo "Invalid input"
        return 1
    end

    set -gx http_proxy "http://$host:$port"
    set -gx https_proxy "http://$host:$port"
    set -gx ftp_proxy "http://$host:$port"
    set -gx no_proxy "localhost,127.0.0.1"

    echo "Network proxy has been set to: $host:$port"
end

# Unset proxy
function unsetproxy
    set -e http_proxy
    set -e https_proxy
    set -e ftp_proxy
    set -e no_proxy

    echo "Network proxy has been unset"
end
