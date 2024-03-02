#!/usr/bin/env bash

check() {
	command -v &>/dev/null
}

notify() {
	check notify-send && notify-send "$@" || echo "$@"
}

[ -f "$HOME/.config/github/notifications.token" ] || {
	notify "Ensure you have placed token"
	cat <<EOF
  {"text":"NaN","tooltip":"Token was not found"}
EOF
	exit 1
}

token=$(cat ${HOME}/notifications.token)
count=$(curl -u bitcode:${token} https://api.github.com/notifications | jq '. | length')

if [[ "$count" != "0" ]]; then
	cat <<EOF
{"text":" $count  ","tooltip":"$tooltip"}
EOF
else
	cat <<EOF
{"text":"","tooltip":"$tooltip"}
EOF
fi
