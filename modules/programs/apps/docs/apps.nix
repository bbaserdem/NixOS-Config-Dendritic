# Document related software
{...}: {
  flake.modules.homeManager.docs = {pkgs, ...}: {
    # Install these apps to userspace
    config = {
      home.packages = with pkgs; (
        [
          calibre # Book library organizer
          zotero # Reference manager
        ]
        ++ (
          if pkgs.stdenv.hostPlatform.isLinux
          then [
            kdePackages.okular
          ]
          else if pkgs.stdenv.hostPlatform.isDarwin
          then []
          else []
        )
      );
    };
  };
}
