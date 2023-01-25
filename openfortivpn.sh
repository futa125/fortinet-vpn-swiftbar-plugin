#!/usr/bin/env bash

# <bitbar.title>Openconnect VPN</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Ivan Futivić</bitbar.author>
# <bitbar.author.github>futa125</bitbar.author.github>
# <bitbar.desc>A better alternative to the FortiClient VPN app on MacOS.</bitbar.desc>
# <bitbar.dependencies>openconnect,tmux</bitbar.dependencies>

# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>
# <swiftbar.schedule>* * * * *</swiftbar.schedule>
# <swiftbar.refreshOnOpen>true</swiftbar.refreshOnOpen>

# Feel free to edit these value if needed
TMUX_EXECUTABLE="/opt/homebrew/bin/tmux"
VPN_EXECUTABLE="/opt/homebrew/bin/openconnect"
EMAIL=""
PASSWORD=""
SERVER=""
DNS_SERVERS=""

# Do not edit
TMUX_SESSION_NAME="forti"

VPN_CONNECT="$TMUX_EXECUTABLE new-session -d -s $TMUX_SESSION_NAME '{ echo \"$PASSWORD\"; echo "" } | sudo $VPN_EXECUTABLE --prot=fortinet $SERVER -u $EMAIL --passwd-on-stdin'"
VPN_DISCONNECT="$TMUX_EXECUTABLE send-keys -t $TMUX_SESSION_NAME C-c"

VPN_CONNECTING="$TMUX_EXECUTABLE list-sessions | grep -q $TMUX_SESSION_NAME"
VPN_CONNECTED="grep -q -E '$DNS_SERVERS' /etc/resolv.conf"

START_FILE="$HOME/.forti-start-time"
START_TIME="$(cat "$START_FILE")"

IP_ADDRESS_FILE="$HOME/.forti-public-ip"
IP_ADDRESS="$(cat "$IP_ADDRESS_FILE")"

CONNECT_ARG="connect"
DISCONNECT_ARG="disconnect"
REFRESH_ARG="refresh"

CONNECTED_ICON="lock.shield.fill"
DISCONNECTED_ICON="xmark.shield.fill"

connect_vpn() {
    rm "$START_FILE"
    eval "$VPN_CONNECT"
    until eval "$VPN_CONNECTED"; do true; done
    date +%s > "$START_FILE"
}

disconnect_vpn() {
    eval "$VPN_DISCONNECT"
    while eval "$VPN_CONNECTED"; do true; done
}

update_ip () {
    curl ifconfig.me > "$IP_ADDRESS_FILE"
}

if eval "$VPN_CONNECTING && ! $VPN_CONNECTED"; then
    echo "| sfimage=$DISCONNECTED_ICON"
    echo "---"
    echo "Status: Connecting..."
    exit
fi

case "$1" in
    "$CONNECT_ARG")
        disconnect_vpn
	    connect_vpn
        sleep 1
        update_ip
        exit
        ;;
    "$DISCONNECT_ARG")
        disconnect_vpn
        sleep 1
        update_ip
        exit
        ;;
    "$REFRESH_ARG")
        update_ip
        exit
        ;;
esac

if eval "$VPN_CONNECTED"; then
    echo "| sfimage=$CONNECTED_ICON"
    echo "---"
    echo "Disconnect Fortinet VPN | shell=$0 param1=$DISCONNECT_ARG terminal=false refresh=true"
    echo "---"
    echo "Status: Connected"
else
    echo "| sfimage=$DISCONNECTED_ICON"
    echo "---"
    echo "Connect Fortinet VPN | shell=$0 param1=$CONNECT_ARG terminal=false refresh=true"
    echo "---"
    echo "Status: Disconnected"
fi

echo "Public IP: $IP_ADDRESS"

if eval "$VPN_CONNECTED"; then
    seconds=$(($(date +%s) - START_TIME))
    printf 'Connection Time: %02dh:%02dm:%02ds\n' $((seconds / 3600)) $((seconds % 3600 / 60)) $((seconds % 60))
fi

echo "---"
echo "Refresh Connection Details | shell=$0 param1=$REFRESH_ARG terminal=false refresh=true"
