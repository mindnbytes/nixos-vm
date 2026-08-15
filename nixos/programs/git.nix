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
      url."git@github-ad.com:ademyanchuk/".insteadOf = "git@github.com:ademyanchuk/";
      init.defaultBranch = "master";
      color.ui = "auto";
      push.autoSetupRemote = true;
      pull.ff = "only";
    };
  };
}
