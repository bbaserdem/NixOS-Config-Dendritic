# Noctalia, desktop shell
{inputs, ...}: {
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  flake.modules.homeManager.waylandShell = {
    lib,
    pkgs,
    config,
    options,
    ...
  }: {
    # Import the hm module from the flake
    imports = [
      inputs.noctalia.homeModules.default
    ];

    config = lib.optionalAttrs (lib.hasAttrByPath ["programs" "noctalia-shell"] options) (
      lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) (let
        noctalia-shell = "${config.programs.noctalia-shell.package}/bin/noctalia-shell";
        noctalia-lock = "${noctalia-shell} ipc call lockScreen lock";
        noctalia-session = "${noctalia-shell} ipc call sessionMenu toggle";
      in
        lib.mkMerge [
          {
            # Enable noctalia shell
            programs.noctalia-shell.enable = true;
          }
          (
            # Auto-start
            lib.mkIf (config.local.waylandShell.default == "noctalia") {
              programs.noctalia-shell.systemd.enable = true;
              # Override targets to auto-launch only in wayland window managers (uwsm)
              systemd.user.services.noctalia-shell = {
                Unit = {
                  After = lib.mkForce [
                    "wayland-session@Hyprland.target"
                  ];
                  PartOf = lib.mkForce [
                    "wayland-session@Hyprland.target"
                    "tray.target"
                  ];
                };
                Install.WantedBy = lib.mkForce [
                  "wayland-session@Hyprland.target"
                ];
              };

              # Hyprland
              # Register us as the lock command
              services.hypridle.settings.general.lock_cmd = noctalia-lock;
              # Register us as the power menu in hyprland
              wayland.windowManager.hyprland.settings.bindl = [
                ", XF86PowerOff, exec, ${noctalia-session}"
              ];
              # Force hyprland to use our colortheme and not stylix
              wayland.windowManager.hyprland.extraConfig = lib.mkOrder 2000 ''
                source=${config.xdg.configHome}/hypr/noctalia/noctalia-colors.conf
              '';

              # TODO: Properly do the theming integration for auto-gen
              # Integrate generated themes, overriding stylix
              # programs.kitty.extraConfig = lib.mkOrder 2000 ''
              #   include ${config.xdg.configHome}/kitty/themes/noctalia.conf
              # '';
              # programs.fuzzel.settings = {
              #   colors = lib.mkForce {};
              #   main.include = "${config.xdg.configHome}/fuzzel/themes/noctalia";
              # };
            }
          )
        ])
    );
  };
}
