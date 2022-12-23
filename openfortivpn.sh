#!/usr/bin/env zsh

# <xbar.title>OpenFortiVPN</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Ivan Futivić</xbar.author>
# <xbar.author.github>futa125</xbar.author.github>
# <xbar.desc>Better replacement for FortiClient VPN</xbar.desc>

# Requirements:
#   1. Install openfortivpn
#     - Run 'brew install openfortivpn'
#   2. Install tmux
#     - Run 'brew install tmux'
#   3. Add openfortivpn to sudoers file
#     - Run 'sudo visudo -f /etc/sudoers.d/openfortivpn'
#     - Add following lines to the file (replace USERNAME with your username)
#         Cmnd_Alias OPENFORTIVPN=/opt/homebrew/bin/openfortivpn
#         USERNAME ALL=NOPASSWD:OPENFORTIVPN
#   4. Create config file
#     - Create new file called '.forti-config' in your home directory
#       - Run 'vi ~/.forti-config'
#     - Add following lines to the file (replace USERNAME with your email and PASSWORD with your password)
#         host = ro.vpn.superbet.eu
#         port = 10443
#         username = USERNAME
#         password = PASSWORD
#         pppd-use-peerdns = 1

# Feel free to edit these value if needed
CONFIG_FILE=".forti-config"
TMUX_EXECUTABLE="/opt/homebrew/bin/tmux"
VPN_EXECUTABLE="/opt/homebrew/bin/openfortivpn"
VPN_EXECUTABLE_PARAMS="$HOME/$CONFIG_FILE"
VPN_INTERFACE="ppp0"

# Do not edit
TMUX_SESSION_NAME="forti"
VPN_CONNECT="$TMUX_EXECUTABLE new-session -d -s $TMUX_SESSION_NAME sudo $VPN_EXECUTABLE -c $VPN_EXECUTABLE_PARAMS"
VPN_DISCONNECT="$TMUX_EXECUTABLE send-keys -t $TMUX_SESSION_NAME C-c"
VPN_CONNECTED="ifconfig | grep -q $VPN_INTERFACE"

CONNECT_ARG="connect"
DISCONNECT_ARG="disconnect"

CONNECTED_ICON="iVBORw0KGgoAAAANSUhEUgAAACwAAAAsCAYAAAAehFoBAAAACXBIWXMAABYlAAAWJQFJUiTwAAACKUlEQVRYhe2Y323CMBDGP6pE9lvTCcgIdAM2gE7QjJARygRlhDBBwwbpBGWEdILCm6U8pA9xJTeN7bNjoCA+KRIh9+dHuJwvnrRti0vS3bkBXHUDPrYuDjgKHTDmfK6eN0JUIeNPQnQJCZkDWGhMtgDWIeBHAcecJwAK6EH72gLIGiH2vjm9azjmfAagwjDsuzz6WgCopK+f2rZ1PiLGkoixOmKsVY4qYmw5YLuU11TbOmIs8cntC9wHyAk+ef8HngQ4YizrJc5O4TsGWC2F0sO/VEvD1d/poYs5XwKYytMDgMzjscmkLwBMZUyyXLuEGrz0aU/Sp9TEtMoVeK58LnVGBKm+c53RkMgLh1wkvn7OGyEmLokG4qmJH6j/lsss8avZx5zn6O5O4hADAPboFpx+7P53gxoz/LyO8KUu5X/kUsOpb5KQsUk1LFvP2wggip4aIawPshU45jwFsANwH4ZLqwOAWSNEbTKilESB48NC5ihsRsY7LMfAj3BMJD02Qux0F213OAvLQpIxpw14HgyDLmNOW0mcZVvItIpe3Gv+1QEfLNePIWNOG3AVjoMsY04b8JiZ11fGnLYukQCocZqVDujKITXNxsY7LB3z0FQGvdgGeeq0VgB4DgSl06YRIrMZkdqaDLQZCWQSCRZw6MMy4MoTyKQVFRbw2L2U83GO7vV8arbW6hNdN1jb5t++xm63pnB/dapdIVUF2dA+pa5ulvh3ugEfW99VuFcwHi1SdQAAAABJRU5ErkJggg=="

DISCONNECTED_ICON="iVBORw0KGgoAAAANSUhEUgAAACwAAAAsCAYAAAAehFoBAAAACXBIWXMAABYlAAAWJQFJUiTwAAACIElEQVRYhe2Y0W2DMBCG/1Qg+610gjICnaDZoHSCMgIjJBswQrJBMkHpBE0nKJ2gyZslHugDbososc/GQBPll6wI2+f7Yh3nM7OqqnBKupoawFQX4KF1csCe6wV9zufN51KI3OX6MxdZQkKmAB6OTNkCyFzA9wL2OQ8ArHActK0tgKQUYm/r0xrY5zwCsAFw2zH8In/vO8beUEPvrBxXVWXcPMYCj7HCY6xqtNxjLO6YG8ux5tzCYyyw8W0L3AZICTZp+w+OAuwxlrQcJ2PYfjfjGPY5zwBE8nFXCpEa2m/w+5J+lEKEJvZO0pqJfM5DAO+NrsdSiA3VfvSTrhSiALBudMUm9lMdzc0dnZsYjh4SwM+B89nouqEeJla1hIzDGPXuBIbmewB5qy/q6OuUEbDcmQzAk4ldh6hH+R+RgeVRnAO4tnWmUEidSIphWY092/OQREpvWmAZrzsMs7NNHQBEMu0dFSWtrTA8LKSPlW6Scodl3L66YyLpTlV66nY4cctCktKnDnjuDIMupU9dSEzyWagUYnZs7OSu+WcHfBiFwsCnDjh3x0GW0qcOmHwTcCilT12WCAAUGOekA+pwCFW1sXKHpeHCMZRKC10hT63WVuhfA+u0LoVIdJNIaU0utNbN6yESLGCQh+WCS0sglZZUWMDiEirr4xR1kWL7Mh5Ql5KZrv5tq+/n1ggWl1DrL5eY6JrfR2dXS/w7XYCH1hd/HPJ08CUs5gAAAABJRU5ErkJggg=="

case "$1" in
    "$CONNECT_ARG")
        eval "$VPN_CONNECT"
        until eval "$VPN_CONNECTED"; do true; done
        ;;
    "$DISCONNECT_ARG")
        eval "$VPN_DISCONNECT"
        while eval "$VPN_CONNECTED"; do true; done
        ;;
esac

if eval "$VPN_CONNECTED"; then
    echo "| templateImage=$CONNECTED_ICON"
    echo "---"
    echo "Disconnect VPN | bash='$0' param1=$DISCONNECT_ARG refresh=true"
    echo "---"
    echo "Status: Connected |"
    exit
else
    echo "| templateImage=$DISCONNECTED_ICON"
    echo "---"
    echo "Connect VPN | bash='$0' param1=$CONNECT_ARG refresh=true"
    echo "---"
    echo "Status: Disconnected |"
    exit
fi
