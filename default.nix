{ lib
, stdenv
, buildGoModule
, buildNpmPackage
, fetchFromGitHub
, ...
}:

let
  ## Define the Hasura version:
  ##
  ## Note: If the Hasura version changes, `cli-ext.patch` may need to change, too.
  version = "2.43.0";

  ## Get the OS and architecture:
  os = if stdenv.isDarwin then "darwin" else "linux";
  arch = if stdenv.isAarch64 then "arm64" else "amd64";

  ## Fetch the Hasura source code:
  hasura-src = fetchFromGitHub {
    owner = "hasura";
    repo = "graphql-engine";
    rev = "v${version}";
    sha256 = "sha256-YEvmNqcpRB8MH2ssjaoQVBJ6FlhcVpi/7BqkgQnYNIw=";
  };

  ## Build the Hasura CLI extension:
  hasura-cli-ext = buildNpmPackage {
    inherit version;

    src = hasura-src;
    pname = "cli-ext";
    sourceRoot = "source/cli-ext";
    npmDepsHash = "sha256-CLoPXElfqT4Bbn3L7MkTNAc429JT++HL4/vEyhzgnC4=";

    patches = [ ./cli-ext.patch ];

    npmInstallFlags = [ "--no-optional" ];
    npmBuildScript = "transpile";

    meta = {
      homepage = "https://www.hasura.io";
      license = lib.licenses.asl20;
      description = "Hasura GraphQL Engine cli-ext";
      platforms = with lib.platforms; linux ++ darwin;
    };
  };

  ## Build the Hasura CLI:
  hasura-cli = buildGoModule rec {
    inherit version; 

    src = hasura-src;
    pname = "hasura-cli";

    modRoot = "./cli";
    subPackages = [ "cmd/hasura" ];

    vendorHash = "sha256-riPCH7H1arKP2se2H52R69fL+DyKXK1i/ne5apoS/5w=";

    preBuild = ''
      cp ${hasura-cli-ext}/bin/cli-ext internal/cliext/static-bin/${os}/${arch}/cli-ext
    '';

    ldflags = [
      "-X github.com/hasura/graphql-engine/cli/v2/version.BuildVersion=${version}"
      "-s"
      "-w"
    ];

    doCheck = false;

    postInstall = ''
      mkdir -p $out/share/{bash-completion/completions,zsh/site-functions}
      export HOME=$PWD
      $out/bin/hasura completion bash > $out/share/bash-completion/completions/hasura
      $out/bin/hasura completion zsh > $out/share/zsh/site-functions/_hasura
    '';

    meta = {
      homepage = "https://www.hasura.io";
      license = lib.licenses.asl20;
      description = "Hasura GraphQL Engine CLI";
      platforms = with lib.platforms; linux ++ darwin;
    };
  };

in
{
  cli = hasura-cli;
}

