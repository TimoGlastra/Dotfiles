#!/usr/bin/env bash

# ~/.macos — Based on https://mths.be/macos

function is_set() {
    [ ! -z $1 ]
}

function is_true() {
    [ "$1" = true ] || [ "$1" = 1 ] || [ "$1" = "y" ] || [ "$1" = "yes" ]
}

# Load user config
ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $ABSOLUTE_PATH/.env

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Set computer name (as done via System Preferences → Sharing)
is_set $COMPUTER_NAME && sudo scutil --set ComputerName "$COMPUTER_NAME"
is_set $COMPUTER_HOST_NAME && sudo scutil --set HostName "$COMPUTER_HOST_NAME"
is_set $COMPUTER_HOST_NAME && sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_HOST_NAME"
is_set $COMPUTER_LOCAL_HOST_NAME && sudo scutil --set LocalHostName "$COMPUTER_LOCAL_HOST_NAME"

# Set standby delay to 24 hours (default is 1 hour)
sudo pmset -a standbydelay 86400

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Set the highlight color
if is_set $HIGHLIGHT_COLOR
then
    HIGHLIGHT_COLOR_BLUE="" # Blue is default
    HIGHLIGHT_COLOR_PURPLE="0.968627 0.831373 1.000000 Purple"
    HIGHLIGHT_COLOR_PINK="1.000000 0.749020 0.823529 Pink"
    HIGHLIGHT_COLOR_RED="1.000000 0.733333 0.721569 Red"
    HIGHLIGHT_COLOR_ORANGE="1.000000 0.874510 0.701961 Orange"
    HIGHLIGHT_COLOR_YELLOW="1.000000 0.937255 0.690196 Yellow"
    HIGHLIGHT_COLOR_GREEN="0.752941 0.964706 0.678431 Green"
    HIGHLIGHT_COLOR_GRAPHITE="0.847059 0.847059 0.862745 Graphite"

    HIGHLIGHT_COLOR_VARIABLE="HIGHLIGHT_COLOR_$HIGHLIGHT_COLOR"
    HIGHLIGHT_COLOR_VALUE=${!HIGHLIGHT_COLOR_VARIABLE}

    # only set if correct value was passed (one of above colors)
    if is_set $HIGHLIGHT_COLOR_VALUE
    then
        defaults write -g AppleHighlightColor -string "$HIGHLIGHT_COLOR_VALUE"
    fi
fi

# Set the accent color
if is_set $ACCENT_COLOR
then
    ACCENT_COLOR_BLUE=-10 # Blue is default, -10 doesn't exist so default is set
    ACCENT_COLOR_PURPLE=5
    ACCENT_COLOR_PINK=6
    ACCENT_COLOR_RED=0
    ACCENT_COLOR_ORANGE=1
    ACCENT_COLOR_YELLOW=2
    ACCENT_COLOR_GREEN=3
    ACCENT_COLOR_GRAPHITE=-1

    ACCENT_COLOR_VARIABLE="ACCENT_COLOR_$ACCENT_COLOR"
    ACCENT_COLOR_VALUE=${!ACCENT_COLOR_VARIABLE}

    # only set if correct value was passed (one of above colors)
    if is_set $ACCENT_COLOR_VALUE
    then
        # TODO: make AquaColor 6 (graphite) when ACCENT_COLOR=1 (graphite), otherwise 1
        defaults write -g AppleAquaColorVariant -int 6
        defaults write -g AppleAccentColor -int "$ACCENT_COLOR_VALUE"
    fi
fi

# Set interface style (light or dark)
if is_set $DARK_INTERFACE
then
    is_true $DARK_INTERFACE && APPLE_INTERFACE_STYLE="Dark" || APPLE_INTERFACE_STYLE="Light"
    defaults write -g AppleInterfaceStyle -string "$APPLE_INTERFACE_STYLE"
fi
