{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cliSettings = (pkgs.formats.json { }).generate "opencode-cli.json" {
    "$schema" = "https://opencode.ai/v2/cli.json";
    theme = {
      name = "system";
      mode = "system";
    };
    scroll = {
      speed = 1;
      acceleration = false;
    };
  };

  mergeCliSettings = pkgs.writeShellApplication {
    name = "merge-opencode-cli-settings";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    text = ''
      target="$1"
      mkdir -p "$(dirname "$target")"
      source=/dev/null
      if [ -e "$target" ]; then
        source="$target"
      fi

      temporary=$(mktemp "$(dirname "$target")/.cli.json.XXXXXX")
      trap 'rm -f "$temporary"' EXIT
      jq -s '
        if all(.[]; type == "object") then
          reduce .[] as $settings ({}; . * $settings)
        else
          error("OpenCode CLI settings must be JSON objects")
        end
      ' "$source" ${cliSettings} > "$temporary"
      chmod 600 "$temporary"
      mv -f "$temporary" "$target"
    '';
  };
in
{
  home.packages = [ inputs.opencode-v2.packages.${pkgs.stdenv.hostPlatform.system}.opencode ];

  # Keep CLI settings writable; rebuilds reapply only the declared preferences.
  # The system theme derives its colors from Noctalia's Ghostty palette.
  home.activation.mergeOpencodeCliSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${lib.getExe mergeCliSettings} ${lib.escapeShellArg "${config.xdg.configHome}/opencode/cli.json"}
  '';
}
