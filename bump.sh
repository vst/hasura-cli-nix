#!/usr/bin/env bash

set -euo pipefail

new_version="${1}"
old_version="$(
  nix eval --raw --impure --expr '
    let
      pkgs = import <nixpkgs> {};
    in
      (pkgs.callPackage ./default.nix {}).version
  '
)"

sed -i "s/${old_version}/${new_version}/g" README.md cli-ext.patch default.nix
