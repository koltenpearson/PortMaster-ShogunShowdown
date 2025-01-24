#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

GAMEDIR="/$directory/ports/shogun-showdown"


cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

$ESUDO $GAMEDIR/splash "splash.png" 30000 &

# Make sure uinput is accessible so we can make use of the gptokeyb controls
$ESUDO chmod 666 /dev/uinput

export MESA_GL_VERSION_OVERRIDE=3.2
export BOX64_DYNAREC_STRONGMEM=1
export SDL_VIDEODRIVER=x11
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

#use keyboard controls because the xbox360 controls cause slowdowns and invert up/down dpad
$GPTOKEYB "ShogunShowdown.x86_64" -c "./shogun-showdown.gptk" &
box64 "./data/ShogunShowdown.x86_64"

$ESUDO kill -9 $(pidof gptokeyb)
