#!/usr/bin/env bash
source ProgressBar.sh

mapfile -t files < <(find /usr/local/sources -type f)

ProgressBar.init --initial 0 --total ${#files[@]} --speed normal

dest=/tmp
for i in "${!files[@]}"; do
  ProgressBar.setProgress "$i Copiando ${files[$i]}"
  cp "${files[$i]}" "$dest"
done &
main_pid=$!
ProgressBar.run
