# Discord config for batuhan
# We need a bit of nix magic to make this robust;
# Only define the attrset when nixcord option is available
{...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    options,
    ...
  }: {
    # Configure vencord plugins, but only if module is defined
    config = lib.mkMerge [
      {
        # Don't do anything by default
      }
      # Only try to append attrset if nixcord options are defined
      (lib.optionalAttrs (builtins.hasAttrPath ["programs" "nixcord"] options) {
        programs.nixcord = {
          # Configuration for vencord
          config = {
            frameless = true;
            transparent = true;
            disableMinSize = true;
            plugins = {
              BlurNSFW.enable = true;
              ClearURLs.enable = true;
              CopyUserURLs.enable = true;
              OnePingPerDM.enable = true;
              USRBG.enable = true;
              alwaysAnimate.enable = true;
              alwaysExpandRoles.enable = true;
              alwaysTrust.enable = true;
              anonymiseFileNames.enable = true;
              betterFolders.enable = true;
              betterGifAltText.enable = true;
              betterRoleContext.enable = true;
              betterRoleDot.enable = true;
              betterSettings.enable = true;
              betterUploadButton.enable = true;
              biggerStreamPreview.enable = true;
              consoleJanitor.enable = true;
              copyFileContents.enable = true;
              fakeNitro.enable = true;
              fixImagesQuality.enable = true;
              noTypingAnimation.enable = true;
              noUnblockToJump.enable = true;
              petpet.enable = true;
              pictureInPicture.enable = true;
              readAllNotificationsButton.enable = true;
              reverseImageSearch.enable = true;
              serverInfo.enable = true;
              showHiddenChannels.enable = true;
              silentTyping.enable = true;
              vencordToolbox.enable = true;
              voiceDownload.enable = true;
              voiceMessages.enable = true;
              youtubeAdblock.enable = true;
            };
          };
        };
      })
    ];
  };
}
