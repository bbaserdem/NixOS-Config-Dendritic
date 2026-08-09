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
                  "codex-group/gpt-5.6-terra".name = "TFY: GPT 5.6 Terra";
                  "openai-group/gpt-5.6-sol".name = "TFY: GPT 5.6 Sol";
                  "openai-group/gpt-5.6-luna".name = "TFY: GPT 5.6 Luna";
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
                  "claude-group/claude-fable-5".name = "TFY: Claude Fable 5";
                  "claude-group/claude-opus-4-8".name = "TFY: Claude Opus 4.8";
                  # X AI
                  "xai-group/grok-4.5".name = "TFY: Grok 4.5";
                  # Perplexity
                  "perplexity-group/sonar-pro".name = "TFY: Perplexity Sonar Pro";
                  # Gemini
                  "gemini-group/gemini-3.1-pro".name = "TFY: Gemini 3.1 Pro";
                  "gemini-group/gemini-3.6-flash".name = "TFY: Gemini 3.6 Flash";
                  # Other
                  "fireworks-group/deepseek-v4-flash-0731".name = "TFY: DeepSeek v4 flash";
                  "fireworks-group/glm-5p2".name = "TFY: GLM 5p2";
                  "fireworks-group/kimi-k3".name = "TFY: Kimi K3";
                  "fireworks-group/kimi-k3-fast".name = "TFY: Kimi K3 Fast";
                  # Claude Pro
                  # "claude-pro-group/claude-haiku".name = "TFY: Claude Pro Haiku 4.5";
                  # "claude-pro-group/claude-sonnet".name = "TFY: Claude Pro Sonnet 4.6";
                  # "claude-pro-group/claude-opus".name = "TFY: Claude Pro Opus 4.8";
                  # "claude-group/claude-haiku".name = "TFY: Claude Pro Haiku 4.5";
                  # "claude-group/claude-sonnet".name = "TFY: Claude Pro Sonnet 4.6";
                  # Gemini
                };
              };
            };
          };
        };
      }
    ]);
  };
}
