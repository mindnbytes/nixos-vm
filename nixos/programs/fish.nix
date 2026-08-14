{
  ...
}:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_greeting
      set -gx COLORTERM truecolor
    '';

    functions.la = {
      description = "List all files with details and icons";
      wraps = "eza";
      body = ''
        eza -lah --icons $argv
      '';
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
