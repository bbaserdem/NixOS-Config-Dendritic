# Document related software
{...}: {
  flake.modules.homeManager.docs = {
    pkgs,
    lib,
    ...
  }: {
    # Install these apps to userspace
    config = lib.mkMerge [
      {
        home.packages = with pkgs; [
          calibre # Book library organizer
          zotero # Reference manager
        ];
      }
      (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        home.packages = with pkgs; [
          kdePackages.okular
        ];
      })
    ];
  };
}
