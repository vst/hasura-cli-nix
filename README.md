# Hasura CLI via Nix

This is a Nix function that builds and installs Hasura CLI a la NixOS.

## Problem

Hasura CLI is known to have issues with Nix, particularly with NixOS as far as I am concerned ([1], [2], [3], ...). In
short, Hasura CLI extension system does not work on NixOS.

I understand that there has been various attempts by the community to fix this, but none which I tried worked for me except two:

1. Use Hasura CLI from within a Docker container: This caused more problems then it solved.
2. Use `buildFHSUserEnv`: This solution worked for me and my team for quite some time, but it has its own issues such
   as a half-broken Nix shell where many commands do not work.

Recently, I bumped into the [solution] of [@adamgoose] that worked like a charm, at least for Hasura CLI v2.40.0.

## This Repository

This repository offers [@adamgoose]'s solution as a Nix function that you can use in a Nix expression to build and install
a functioning Hasura CLI.

```nix
{ ... }:

let
  pkgs = import <nixpkgs> { };
  hasura-cli-nix = pkgs.fetchFromGitHub {
    owner = "vst";
    repo = "hasura-cli-nix";
    rev = "98e796e57a37ffe98233cb174e439e3e7657166d";
    sha256 = "sha256-SiOSip48jk1CbtcMmN79+ca6A3slS9XGffhZFTLoWYU=";
  };
  hasura-cli = (pkgs.callPackage hasura-cli-nix { }).cli;
in
pkgs.mkShell {
  buildInputs = [
    hasura-cli
  ];
}
```

Feel free to open an issue or a pull request if you have any suggestions or improvements.

<!-- REFERENCES -->

[1]: https://github.com/NixOS/nixpkgs/issues/113756
[2]: https://github.com/hasura/graphql-engine/issues/6579
[3]: https://github.com/hasura/graphql-engine/issues/8441
[@adamgoose]: https://github.com/adamgoose
[solution]: https://github.com/hasura/graphql-engine/issues/8441#issuecomment-2055727178