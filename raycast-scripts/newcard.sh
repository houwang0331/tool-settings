#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title newcard
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.description create a new card

set -e

folder="$HOME/Library/Mobile Documents/com~apple~CloudDocs/cards"
file="$folder/$(date +%Y_%m_%d_%H_%M).md"

mkdir -p "$folder"
touch "$file"
open -a typora "$file"
