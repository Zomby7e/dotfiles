# Fish configure
# Path: ~/.config/fish/config.fish
# User: @zomby7e

# Editors config
if type -q kate
	set -x VISUAL "kate"
end

if type -q vim
	set -x EDITOR "vim"
	abbr -a vi vim
end

if status is-interactive
	# Varribles when it's interactive
	set translate_manual_to "zh_TW" # First language for man

	# less with code hilight (need install source-hilight)
	if type -q src-hilite-lesspipe.sh
		set -Ux LESSOPEN "| src-hilite-lesspipe.sh %s"
	end
	set -Ux LESS -R

	# LS Delux (better ls)
	if type -q lsd
		abbr -a ls 'lsd --icon never'
		abbr -a ll 'lsd -l --icon never'
		abbr -a la 'lsd -la --icon never'
		abbr -a lt 'lsd --tree --icon never'
	end

	# Use btop instead of top
	if type -q btop
		abbr -a top btop
	end

	# Better cat
	if type -q bat
		abbr -a cat bat
	else if type -q batcat
		abbr -a cat batcat
	end

	# Fish config
	function fish_greeting
		echo -n "Fish opened @ "
		set_color brgreen
		echo (date "+%H:%M %m/%d/%Y")
		set_color normal
		if not test (basename $SHELL) = "fish"
			printf "It looks like your default shell is not fish. Run `usefish` if you'd like to make fish your default.\n"
			abbr --add usefish 'chsh -s (which fish)'
		end
	end

	# mkdir then cd
	function mkcd
		if test (count $argv) -eq 0
			echo "Usage: mkcd <directory>"
			return 1
		end

		set dir $argv[1]

		if not test -d "$dir"
			mkdir -p "$dir"
		end

		cd "$dir"
	end

	# Show alias/abbr, or executable file location
	function whichcmd
		functions $argv[1]; and return
		type -a $argv[1]
	end

	# List the ports the system is listening on
	function ports
		if type -q ss
			ss -tuln
		else if type -q netstat
			netstat -tuln
		else
			echo "No netstat or ss available."
		end
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

	# Translated manual
	function tman
		if man -M /usr/share/man/$translate_manual_to "$argv[1]" > /dev/null 2>&1
			man -M /usr/share/man/$translate_manual_to "$argv"
		else
			man "$argv"
		end
	end

end
