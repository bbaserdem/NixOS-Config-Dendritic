# Kayra; live-usb configuration
{inputs, ...}: {
  flake.modules.nixos.kayra = {
    modulesPath,
    pkgs,
    lib,
    ...
  }: {
    # System configuration

    # Load modules that configure the system
    imports = with inputs.self.modules.nixos; [
      # Base module for live iso; we build our gui on top
      (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
      # User
      sbp
      # System
      stylix
      gnome
      shell
      # Desktop
      fonts
      keyboard
      language
      gtk
      qt
      xdg
      # Tooling
      networkmanager
      yubikey
      ssh
      gpg
      polkit
      vcs
      udisks
      archives
      btop
      tools
      # Hardware
      bluetooth
      printing
      sound
      power
      # Applications
      chromium
      kitty
      nvim
      yazi
    ];

    config = {
      # Iso file settings; defineds in iso-image.nix
      isoImage = {
        # Need the raw iso
        compressImage = false;
        edition = "Kayra";
        configurationName = "Kayra";
      };

      boot.initrd = {
        systemd.enable = lib.mkForce false;
        supportedFilesystems = {
          exfat = true;
          vfat = true;
          ext4 = true;
        };
        availableKernelModules = [
          "exfat"
          "uas"
          "usb_storage"
          "sd_mod"
        ];
      };

      # Gnome; power management wants ppd
      local.powerManagement.backend = "ppd";

      # From installation-cd-graphical-base; whitelist wheel users
      # Whitelist wheel users to do anything
      # This is useful for things like pkexec
      #
      # WARNING: this is dangerous for systems
      # outside the installation-cd and shouldn't
      # be used anywhere else.
      security = {
        sudo.wheelNeedsPassword = false;
        polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (subject.isInGroup("wheel")) {
              return polkit.Result.YES;
            }
          });
        '';
      };

      # User passwords
      users.users = {
        root = {
          hashedPassword = lib.mkForce null;
          hashedPasswordFile = lib.mkForce null;
          initialPassword = lib.mkForce null;
          initialHashedPassword = lib.mkForce null;
          password = lib.mkForce "nixos";
        };
        sbp = {
          hashedPassword = lib.mkForce null;
          hashedPasswordFile = lib.mkForce null;
          initialPassword = lib.mkForce null;
          initialHashedPassword = lib.mkForce null;
          password = lib.mkForce "nixos";
        };
      };

      # From installation-cd-graphical-gnome
      services.displayManager = {
        gdm.autoSuspend = false;
        autoLogin = {
          enable = true;
          user = "sbp";
        };
      };

      # Useful tools to have on a live-usb
      environment.systemPackages = with pkgs; [
        # System tooling
        nixos-anywhere
        disko
        # Encryption
        sops
        ssh-to-age
        age
        mkpasswd
      ];
    };
  };
}
