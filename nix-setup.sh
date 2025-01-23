#!/bin/bash

# Install required dependencies
apt-get update && apt-get install -y curl xz-utils

# Create nix directory with correct permissions
mkdir -m 0755 /nix && chown $USER /nix

# Download and run the Nix installer
curl -L https://nixos.org/nix/install | sh

# Source nix into current shell
. ~/.nix-profile/etc/profile.d/nix.sh

# Add Nix to shell configuration
echo '. ~/.nix-profile/etc/profile.d/nix.sh' >> ~/.bashrc
echo '. ~/.nix-profile/etc/profile.d/nix.sh' >> ~/.profile

# Verify installation
nix --version
export NIXPKGS_ALLOW_UNFREE=1
nix-shell --run $SHELL


