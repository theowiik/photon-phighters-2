{
  description = "Project Epic Footsies 2";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      appsFor =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          pythonEnv = pkgs.python3.withPackages (ps: [
            ps.lark
            ps.setuptools
          ]);

          format = pkgs.writeShellScriptBin "format" ''
            set -e
            ${pkgs.gdtoolkit_4}/bin/gdformat .
          '';

          check = pkgs.writeShellScriptBin "check" ''
            set -e
            ${pkgs.gdtoolkit_4}/bin/gdformat . --check
            ${pkgs.gdtoolkit_4}/bin/gdlint .
            PYTHONPATH=${pkgs.gdtoolkit_4}/${pkgs.python3.sitePackages} ${pythonEnv}/bin/python3 validate_gdscript.py
          '';

          officialGodotMacos = pkgs.fetchzip {
            url = "https://github.com/godotengine/godot/releases/download/${pkgs.godot.version}/Godot_v${pkgs.godot.version}_macos.universal.zip";
            hash = "sha256-OQmJ4n0nxIhpGJqGZlAvzRbW66sMGsAsIjWaXCXjCtg=";
          };

          runGodot =
            if pkgs.stdenv.hostPlatform.isDarwin then
              "${officialGodotMacos}/Contents/MacOS/Godot"
            else
              "${pkgs.godot}/bin/godot4";

          run = pkgs.writeShellScriptBin "run" ''
            set -e
            ${runGodot} --headless --path . --import
            ${runGodot} --path .
          '';

          build = pkgs.writeShellScriptBin "build" ''
            set -e
            export XDG_DATA_HOME="${pkgs.godot-export-templates-bin}/share"
            export HOME="$(mktemp -d)"
            trap 'rm -rf "$HOME"' EXIT
            mkdir -p "$HOME/Library/Application Support/Godot"
            ln -s "$XDG_DATA_HOME/godot/export_templates" "$HOME/Library/Application Support/Godot/export_templates"
            mkdir -p build/linux build/windows
            ${pkgs.godot}/bin/godot4 --headless --export-release "game-linux" ./build/linux/project-epic-footsies-2.x86_64
            ${pkgs.godot}/bin/godot4 --headless --export-release "game-windows" ./build/windows/project-epic-footsies-2.exe
          '';
        in
        {
          format.type = "app";
          format.program = "${format}/bin/format";
          check.type = "app";
          check.program = "${check}/bin/check";
          run.type = "app";
          run.program = "${run}/bin/run";
          build.type = "app";
          build.program = "${build}/bin/build";
        };
    in
    {
      apps = nixpkgs.lib.genAttrs systems appsFor;
    };
}
