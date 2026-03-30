# Document related software suite
{inputs, ...}: {
  flake.modules.homeManager.docs = {pkgs, ...}: {
    # Documents related software

    # Document related modules
    imports = with inputs.self.modules.homeManager; (
      [
        zathura
        foliate
        obsidian
        newsboat
      ]
      ++ (
        if pkgs.stdenv.hostPlatform.isLinux
        then [
          office
        ]
        else if pkgs.stdenv.hostPlatform.isDarwin
        then []
        else []
      )
    );

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
