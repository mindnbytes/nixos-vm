{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "mindnbytes";
        username = "mindnbytes";
        email = "mindnbytes@gmail.com";
      };
      init.defaultBranch = "master";
      color.ui = "auto";
      push.autoSetupRemote = true;
      pull.ff = "only";
    };
  };
}
