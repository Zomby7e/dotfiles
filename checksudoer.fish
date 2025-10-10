#!/usr/bin/env fish

function checksudoer --description "Check if current user is a sudoer, if not, try to add."
    if not type -q sudo
        echo "[Error] sudo is not installed."
        return 1
    end
    
    # Get current user name
    set current_user (logname 2>/dev/null; or whoami)

    # Check if current user is root
    if test "$current_user" = "root"
        echo "[OK] Using root account."
        return 0
    end

    # Check if current user is a sudoer
    if sudo -n -u $current_user true 2>/dev/null
        echo "[OK] User \"$current_user\" is already a sudoer."
    else if test -e /etc/sudoers.d/$current_user
    	echo "[Error] Seems current user \"$current_user\" is not a sudoer, but the file \"/etc/sudoers.d/$current_user\" is already exists."
    	echo "Please check sudo configuration files."
    	return 2
    else
        read -l -P "Add current user \"$current_user\" to sudoers? [y/N] " confirm
        if test $confirm = "y" ; or test $confirm = "Y"
            echo "Please enter root password below."
            # You can run the following line in `bash`.(Remove the last backslash)
            su -c "u=\$(logname 2>/dev/null || whoami); echo \"\$u ALL=(ALL:ALL) ALL\" > /etc/sudoers.d/\$u && chmod 440 /etc/sudoers.d/\$u" \
            && echo "[OK] File created at: \"/etc/sudoers.d/$current_user\""
        else
            echo "Operation cancelled."
        end
     end
end
