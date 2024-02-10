#!/bin/bash

# Check if Oh My Fish is already installed
if [ ! -d "$HOME/.local/share/omf" ]; then
  echo "Installing Oh My Fish..."
  curl -L https://get.oh-my.fish | fish
else
  echo "Oh My Fish is already installed."
fi

# Optionally, you can automatically install themes or plugins here using omf install

