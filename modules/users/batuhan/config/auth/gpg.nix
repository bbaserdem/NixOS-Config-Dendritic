# GPG configuration for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {pkgs, ...}: {
    services.gpg-agent = {
      pinentry.package = pkgs.pinentry-gnome3;
    };
  };
}
