#!/usr/bin/env bash
STATE=$(cat /proc/acpi/button/lid/LID/state | awk '{print $2}')

if [ "$STATE" = "closed" ]; then
    sudo -u $USER hyprctl dispatch dpms off
else
    sudo -u $USER hyprctl dispatch dpms on
fi

# логирование для отладки
#sudo -u $USER tee -a /tmp/lid_states.log <<< "$STATE"