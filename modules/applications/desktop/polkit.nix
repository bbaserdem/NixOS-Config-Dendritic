# Policy kit config
{
  inputs,
  den,
  ...
}: {
  den = {
    # Always load this aspect
    schema.host = {
      includes = [
        den.aspects.desktop._.polkit
      ];
    };
    # Our aspect
    aspects.desktop = {
      provides.polkit = {
        name = "desktop/polkit";
        # Nixos policy kit settings
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.desktop-polkit
          ];
        };
      };
    };
  };

  # Module
  flake.modules.nixos.desktop-polkit = {...}: {
    key = "desktop-polkit#nixos";
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
