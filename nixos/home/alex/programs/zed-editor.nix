{ pkgs, ... }:
let
  localFlake = "(builtins.getFlake (builtins.toString ./.))";
in
{
  programs.zed-editor = {
    enable = true;
    extraPackages = [
      pkgs.nixd
      pkgs.nixfmt
      pkgs.dockerfile-language-server
      pkgs.lua-language-server
      pkgs.luau-lsp
    ];
    extensions = [
      "nix"
      "dockerfile"
      "lua"
      "zed-luau"
      "catppuccin"
      "catppuccin-icons"
    ];
    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "ctrl-w t" = "terminal_panel::ToggleFocus";
        };
      }
    ];
    userSettings = {
      helix_mode = true;

      # Appearance
      theme = "Catppuccin Frappé";
      icon_theme = "Catppuccin Frappé";
      ui_font_family = ".ZedSans";
      ui_font_weight = 400;
      ui_font_size = 16;
      agent_ui_font_size = 18;
      agent_buffer_font_size = 15;
      buffer_font_family = "JetBrainsMono Nerd Font Mono";
      buffer_font_size = 15;
      buffer_font_weight = 400;
      buffer_line_height = "comfortable";

      # Editing
      cursor_blink = false;
      cursor_shape = "bar";
      autosave = "on_focus_change";
      colorize_brackets = true;

      # AI agents and edit predictions
      agent = {
        default_model = {
          provider = "openai-subscribed";
          model = "gpt-5.6-luna";
          enable_thinking = true;
          effort = "high";
        };

        auto_compact = {
          enabled = true;
          threshold = "90%";
        };
      };

      # Show edit predictions only when requested manually.
      edit_predictions = {
        provider = "zed";
        mode = "subtle";
      };
      show_edit_predictions = false;

      file_finder = {
        modal_max_width = "medium";
        include_ignored = "smart";
      };

      # Terminal
      terminal = {
        dock = "right";
        default_width = 320;
        blinking = "off";
        cursor_shape = "bar";

        font_family = "JetBrainsMono Nerd Font";
        font_size = 13;
        line_height = "comfortable";

        shell = "system";
        env = {
          EDITOR = "zed --wait";
          TERM = "ghostty";
        };
      };

      # Languages and language servers
      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
          formatter = {
            external = {
              command = "nixfmt";
            };
          };
          format_on_save = "on";
        };
      };

      lsp = {
        nixd = {
          settings = {
            nixd = {
              formatting.command = [ "nixfmt" ];

              nixpkgs.expr = "import ${localFlake}.inputs.nixpkgs { }";

              options = {
                nixos.expr = "${localFlake}.nixosConfigurations.vm.options";
                home-manager.expr = "${localFlake}.nixosConfigurations.vm.options.home-manager.users.type.getSubOptions []";
              };

              diagnostic.suppress = [ "sema-extra-with" ];
            };
          };
        };
      };
    };
  };
}
