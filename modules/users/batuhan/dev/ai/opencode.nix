# Configuring OpenCode; provider
{...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    config,
    ...
  }: {
    config = let
      tfyName = "truefoundry-gateway";
      tfyTitle = "TrueFoundry Gateway";
    in (lib.mkMerge [
      {
        # Set up secrets
        programs.opencode.settings.provider = let
          cfg = {
            baseURL =
              if (lib.hasAttrByPath ["sops" "secrets" "truefoundry/url"] config)
              then "{file:${config.sops.secrets."truefoundry/url".path}}"
              else "{env:TFY_GATEWAY_URL}";
            apiKey =
              if (lib.hasAttrByPath ["sops" "secrets" "truefoundry/api"] config)
              then "{file:${config.sops.secrets."truefoundry/api".path}}"
              else "{env:TFY_API_KEY}";
          };
        in {
          "${tfyName}".options = cfg;
          "${tfyName}-openai".options = cfg;
        };
      }
      {
        programs.opencode = {
          settings = {
            provider = {
              "${tfyName}-openai" = {
                npm = "@ai-sdk/openai";
                name = "${tfyTitle} (OpenAI)";
                options = {
                  headers = {
                    application = "opencode";
                  };
                };
                models = {
                  "codex-group/gpt-5.3-codex".name = "TFY: GPT 5.3 Codex";
                  "openai-group/gpt-5.5".name = "TFY: GPT 5.5";
                  "openai-group/gpt-4o".name = "TFY: GPT 4o";
                  "openai-group/gpt-5.4-mini".name = "TFY: GPT 5.4 Mini";
                };
              };
              "${tfyName}" = {
                npm = "@ai-sdk/openai-compatible";
                name = "${tfyTitle}";
                options = {
                  headers = {
                    application = "opencode";
                  };
                };
                models = {
                  # Claude
                  "claude-group/claude-opus-4-8".name = "TFY: Claude Opus 4.8";
                  "claude-group/claude-opus-4-7".name = "TFY: Claude Opus 4.7";
                  "claude-group/claude-opus-4-6".name = "TFY: Claude Opus 4.6";
                  "claude-group/claude-haiku-4-5".name = "TFY: Claude Haiku 4.5";
                  "claude-group/claude-sonnet-4-6".name = "TFY: Claude Sonnet 4.6";
                  # Claude Pro
                  "claude-pro-group/claude-haiku".name = "TFY: Claude Pro Haiku 4.5";
                  "claude-pro-group/claude-sonnet".name = "TFY: Claude Pro Sonnet 4.6";
                  "claude-pro-group/claude-opus".name = "TFY: Claude Pro Opus 4.8";
                  "claude-group/claude-haiku".name = "TFY: Claude Pro Haiku 4.5";
                  "claude-group/claude-sonnet".name = "TFY: Claude Pro Sonnet 4.6";
                  # Gemini
                  "gemini-group/gemini-3.1-pro".name = "TFY: Gemini 3.1 Pro Preview";
                };
              };
            };
          };
        };
      }
    ]);
  };
}
