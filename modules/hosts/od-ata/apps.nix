# Od-ata userspace applications
{inputs, ...}: {
  flake.modules.nixos.od-ata = {...}: {
    # Load modules that configure the system
    imports = with inputs.self.modules.nixos; [
      # Audio
      beets
      # Auth
      gpg
      polkit
      ssh
      yubikey
      # Comms
      firefox
      # Desktop
      gnome
      fonts
      gtk
      keyboard
      language
      qt
      xdg
      # Dev
      vcs
      kitty
      nvim
      # Files
      files
      yazi
      # Firmware
      udisks
      # Utils
      archives
      btop
      tools
    ];
  };
}
