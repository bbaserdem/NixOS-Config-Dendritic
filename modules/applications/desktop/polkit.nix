# Policy kit config
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.desktop = {
      # Auto include us
      includes = [
        den.aspects.desktop._.polkit
      ];
      # Our aspect
      provides.polkit = {
        # Nixos policy kit settings
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.polkit-settings
          ];
        };
      };
    };
  };

  # Module
  flake.modules.nixos.polkit-settings = {...}: {
    key = "polkit-settings#nixos";
    config = {
      security.polkit = {
        enable = true;
        # Enable users group to boot the system
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (
              subject.isInGroup("users")
                && (
                  action.id == "org.freedesktop.login1.reboot" ||
                  action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                  action.id == "org.freedesktop.login1.power-off" ||
                  action.id == "org.freedesktop.login1.power-off-multiple-sessions"
                )
            )
            {
              return polkit.Result.YES;
            }
          })
        '';
      };
    };
  };
}
