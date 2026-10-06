# Direnv setup
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.development
      ];

      provides.development = {
        host,
        user,
      }: {
        name = "wolframite/development(${user.userName}@${host.name})";
        homeManager = {lib, ...}: {
          imports = with inputs.self.modules.homeManager; [
            wolframite-neovim
            wolframite-vcs
            wolframite-mcp
            wolframite-claude
          ];
          config = {
            # Direnv permission list
            programs.direnv.config.whitelist = {
              prefix =
                [
                  (
                    if (user.mediaDirs ? projects)
                    then "${user.homeDirectory}/${user.mediaDirs.projects.location}/Code"
                    else "~/Projects/Code"
                  )
                ]
                ++ (
                  lib.optional
                  (user.mediaDirs ? work)
                  "${user.homeDirectory}/${user.mediaDirs.work.location}"
                );
              exact = [];
            };
          };
        };
      };
    };
  };
}
