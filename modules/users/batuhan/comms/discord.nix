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
    config = lib.optionalAttrs (lib.hasAttrByPath ["programs" "nixcord"] options) {
      programs.nixcord = {
        # Configuration for vencord
        config.plugins = {
          blurNsfw.enable = true;
          clearUrls.enable = true;
          copyUserUrls.enable = true;
          onePingPerDm.enable = true;
          usrbg.enable = true;
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
          voiceDownload.enable = true;
          voiceMessages.enable = true;
          youtubeAdblock.enable = true;
        };
      };
    };
  };
}
