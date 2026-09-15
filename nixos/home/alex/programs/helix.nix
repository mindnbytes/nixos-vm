{ pkgs, ... }:

let
  localFlake = "(builtins.getFlake (builtins.toString ./.))";
in
{
  programs.helix = {
    enable = true;

    # Set EDITOR and VISUAL to "hx".
    defaultEditor = true;

    # These tools are on Helix's PATH, not the interactive shell's PATH.
    extraPackages = [
      pkgs.nixd
      pkgs.nixfmt

      pkgs.ruff
      pkgs.ty

      pkgs.lua-language-server
      pkgs.marksman

      # Provides clangd and clang-format for C development.
      pkgs.llvmPackages_22.clang-tools
    ];

    # Generates ~/.config/helix/config.toml
    settings = {
      theme = "tokyonight_storm";

      editor.file-picker.hidden = false;
    };

    # Generates ~/.config/helix/languages.toml
    languages = {
      language-server = {
        ruff = {
          command = "ruff";
          args = [ "server" ];
        };

        ty = {
          command = "ty";
          args = [ "server" ];
        };

        nixd = {
          command = "nixd";
          args = [ "--semantic-tokens=true" ];

          config.nixd = {
            formatting.command = [ "nixfmt" ];

            nixpkgs.expr = "import ${localFlake}.inputs.nixpkgs { }";

            options = {
              nixos.expr = "${localFlake}.nixosConfigurations.vm.options";
              home-manager.expr = "${localFlake}.nixosConfigurations.vm.options.home-manager.users.type.getSubOptions []";
            };
          };
        };
      };

      language = [
        {
          name = "c";
          file-types = [
            "c"
            "h"
          ];
          auto-format = true;
        }

        {
          name = "python";

          language-servers = [
            {
              name = "ruff";
              only-features = [
                "diagnostics"
                "code-action"
              ];
            }
            {
              name = "ty";
              except-features = [ "format" ];
            }
          ];

          auto-format = true;

          formatter = {
            command = "ruff";
            args = [
              "format"
              "-"
            ];
          };
        }

        {
          name = "nix";
          language-servers = [ "nixd" ];
        }
      ];
    };
  };
}
