# Lockscreen generator function
# (underscore prefix to prevent auto-loading by import-tree)
# Complex function; so pulled out of module.
{
  monitor, # Quirk element
  lib, # Need this from the invocation
}: let
  # The exported layout's design frame.
  # Each output will receive a instance instead of Noctalia's non-uniform center remap.
  reference = {
    width = 2256.0;
    height = 1504.0;
  };
  widgetNames = [
    "login"
    "clock"
    "visualizer"
    "media"
    "cpu"
    "volume"
    "memory"
    "network"
  ];

  # Output determined from quirk
  outputId = "${monitor.parent}-${monitor.id}";
  width = assert lib.assertMsg
  (monitor.d != null)
  "Monitor ${monitor.parent}/${monitor.id} needs dimensions for the Noctalia lock screen";
    monitor.d.w * 1.0;
  height = monitor.d.h * 1.0;
  scale = lib.min (width / reference.width) (height / reference.height);
  scaled = value: value * scale;
  scaledInteger = value: builtins.floor (scaled value + 0.5);
  centerX = width / 2.0;
  centerY = height / 2.0;

  # Determined from noctalia export
  sizes = {
    login = {
      width = scaled 810.0;
      height = scaled 196.0;
    };
    clock = {
      width = scaled 640.0;
      height = scaled 320.0;
    };
    visualizer = {
      width = scaled 768.0;
      height = scaled 80.0;
    };
    media = {
      width = scaled 640.0;
      height = scaled 272.0;
    };
    sysmon = {
      width = scaled 384.0;
      height = scaled 144.0;
    };
    corner = {
      width = scaled 352.0;
      height = scaled 192.0;
    };
  };

  # Preserve the centered stack's internal gaps independently of aspect ratio.
  mediaY = centerY - scaled 80.0;
  visualizerY =
    mediaY
    + sizes.media.height / 2.0
    + scaled 56.0
    + sizes.visualizer.height / 2.0;
  sysmonY =
    visualizerY
    + sizes.visualizer.height / 2.0
    + scaled 48.0
    + sizes.sysmon.height / 2.0;
  sysmonOffset = (sizes.sysmon.width + scaled 32.0) / 2.0;

  # Main widget noctalia setting block generator
  mkWidget = {
    type,
    cx,
    cy,
    size,
    settings ? null,
  }:
    {
      inherit type cx cy;
      output = monitor.description;
      box_width = size.width;
      box_height = size.height;
      placement_width = width;
      placement_height = height;
      rotation = 0.0;
    }
    // lib.optionalAttrs (settings != null) {inherit settings;};

  # Noctalia config
  widgetsByName = {
    login = mkWidget {
      type = "login_box";
      cx = centerX;
      cy = height - scaled 84.0 - sizes.login.height / 2.0;
      size = sizes.login;
      settings = {
        background_color = "surface_container";
        background_opacity = 0.88;
        background_radius = scaledInteger 12.0;
        center_password_text = false;
        input_opacity = 1.0;
        input_radius = scaledInteger 6.0;
        layout = "regular";
        show_caps_lock = true;
        show_keyboard_layout = true;
        show_login_button = true;
        show_media = true;
        show_password_reveal = true;
        show_session_buttons = true;
        show_unlock_hint = true;
        show_weather = true;
      };
    };

    clock = mkWidget {
      type = "clock";
      cx = centerX;
      cy = scaled 120.0 + sizes.clock.height / 2.0;
      size = sizes.clock;
    };

    visualizer = mkWidget {
      type = "audio_visualizer";
      cx = centerX;
      cy = visualizerY;
      size = sizes.visualizer;
      settings = {
        bands = 32;
        show_when_idle = true;
      };
    };

    media = mkWidget {
      type = "media_player";
      cx = centerX;
      cy = mediaY;
      size = sizes.media;
    };

    cpu = mkWidget {
      type = "sysmon";
      cx = centerX - sysmonOffset;
      cy = sysmonY;
      size = sizes.sysmon;
      settings = {
        display = "graph";
        stat = "cpu_usage";
        stat2 = "cpu_temp";
      };
    };

    volume = mkWidget {
      type = "volume";
      cx = width - scaled 40.0 - sizes.corner.width / 2.0;
      cy = height - scaled 48.0 - sizes.corner.height / 2.0;
      size = sizes.corner;
    };

    memory = mkWidget {
      type = "sysmon";
      cx = centerX + sysmonOffset;
      cy = sysmonY;
      size = sizes.sysmon;
      settings = {
        display = "graph";
        stat = "ram_pct";
        stat2 = "swap_pct";
      };
    };

    network = mkWidget {
      type = "sysmon";
      cx = scaled 40.0 + sizes.corner.width / 2.0;
      cy = height - scaled 48.0 - sizes.corner.height / 2.0;
      size = sizes.corner;
      settings = {
        display = "graph";
        network_speed_compact = true;
        stat = "net_rx";
        stat2 = "net_tx";
      };
    };
  };

  idFor = name:
    if name == "login"
    then "lockscreen-login-box@${outputId}"
    else "lockscreen-widget-${outputId}-${name}";
in {
  order = builtins.map idFor widgetNames;
  widgets = lib.mapAttrs' (name: widget: lib.nameValuePair (idFor name) widget) widgetsByName;
}
