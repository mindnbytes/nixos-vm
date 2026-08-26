{ cosmicLib, ... }:

let
  mkRON = cosmicLib.cosmic.mkRON;

  ronFloat = value: mkRON "raw" value;

  rgb =
    red: green: blue:
    mkRON "optional" {
      red = ronFloat red;
      green = ronFloat green;
      blue = ronFloat blue;
    };

  rgba =
    red: green: blue: alpha:
    mkRON "optional" {
      red = ronFloat red;
      green = ronFloat green;
      blue = ronFloat blue;
      alpha = ronFloat alpha;
    };
in
{
  wayland.desktopManager.cosmic = {
    enable = true;

    # Preserve COSMIC-managed settings that are intentionally not represented here.
    resetFiles = false;

    appearance = {
      theme = {
        mode = "dark";

        dark = {
          # #7aa2f7
          accent = rgb "0.47843137" "0.6352942" "0.96862745";

          active_hint = 3;

          # #24283b
          bg_color = rgba "0.14117648" "0.15686275" "0.23137255" "1.0";

          # #fda1a0
          destructive = rgb "0.99215686" "0.6313726" "0.627451";

          # Outer and inner window gaps.
          gaps = mkRON "tuple" [
            0
            8
          ];

          is_frosted = false;

          # #414868
          neutral_tint = rgb "0.25490198" "0.28235292" "0.40784314";

          # #1f2335
          primary_container_bg = rgba "0.12156863" "0.13725491" "0.20784314" "1.0";

          # #92cf9c
          success = rgb "0.57254905" "0.8117647" "0.6117647";

          # #c0caf5
          text_tint = rgb "0.7529412" "0.7921569" "0.9607843";

          # #f7e062
          warning = rgb "0.96862745" "0.8784314" "0.38431373";

          # #bb9af7
          window_hint = rgb "0.7333334" "0.6039216" "0.96862745";
        };
      };

      toolkit = {
        apply_theme_global = true;

        interface_font = {
          family = "Fira Sans";
          weight = mkRON "enum" "Normal";
          stretch = mkRON "enum" "Normal";
          style = mkRON "enum" "Normal";
        };

        monospace_font = {
          family = "FiraCode Nerd Font Mono";
          weight = mkRON "enum" "Normal";
          stretch = mkRON "enum" "Normal";
          style = mkRON "enum" "Normal";
        };
      };
    };

    applets = {
      app-list.settings.favorites = [
        "com.system76.CosmicFiles"
        "com.system76.CosmicSettings"
        "com.mitchellh.ghostty"
      ];

      time.settings = {
        # 0 means Monday.
        first_day_of_week = 0;
        military_time = true;
      };
    };

    compositor = {
      autotile = true;
      autotile_behavior = mkRON "enum" "PerWorkspace";
    };
  };
}
