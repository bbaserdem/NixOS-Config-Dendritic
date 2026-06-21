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
      # Access
      avahi
      ssh
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
        # MultiOS-USB requires a /boot/grub/loopback.cfg file to auto-launch iso
        # However, NixOS doesn't generate this unless systemd initrd is disabled
        # loopback.cfg is slated as deprecated, and will be removed in 26.11
        # TODO; find a way to future-proof this
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

      # User passwords; just force defaults
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

      # Enable ssh root login, and deploy authorized keys
      services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";
      users.users.root.openssh.authorizedKeys.keyFiles = [
        (inputs.self + /assets/kayra-ssh.pub)
      ];
      services.fail2ban.enable = lib.mkForce false;

      # From installation-cd-graphical-gnome
      services.displayManager = {
        gdm.autoSuspend = false;
        autoLogin = {
          enable = true;
          user = "sbp";
        };
      };

      # Useful tools to have on a live-usb
      environment.systemPackages =
        (with pkgs; [
          # System tooling
          nixos-anywhere
          # Encryption
          sops
          ssh-to-age
          age
          mkpasswd
        ])
        ++ (with inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}; [
          disko
          disko-doc
          disko-install
        ]);
    };
  };
}
