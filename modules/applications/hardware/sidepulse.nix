# Sidepulse setup
{...}: {
  # Modules
  # TODO: Actually do sidepulse as a derivation; and hook it up properly.
  flake.modules.homeManager.sidepulse-claude = {
    pkgs,
    lib,
    config,
    ...
  }: {
    key = "sidepulse-claude#homeManager";
    config = lib.mkMerge [
      (
        lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          # Claude code hooks
          programs.claude-code.settings.hooks =
            lib.genAttrs
            [
              "SessionStart"
              "UserPromptSubmit"
              "PreToolUse"
              "PostToolUse"
              "PostToolUseFailure"
              "PermissionRequest"
              "Notification"
              "PreCompact"
              "PostCompact"
              "SubagentStop"
              "Stop"
              "SessionEnd"
            ]
            (
              _: [
                {
                  matcher = "*";
                  hooks = [
                    {
                      type = "command";
                      command = ''
                        sidepulse hook-log \
                          --provider claude \
                          --log "${config.xdg.stateHome}/sidepulse/agent-monitor/claude.jsonl" ; true
                      '';
                    }
                  ];
                }
              ]
            );
        }
      )
    ];
  };
}
