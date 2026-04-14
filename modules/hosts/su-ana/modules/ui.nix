# Su-ana applications
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # Darwin modules to import
    imports = with inputs.self.modules.darwin; [
      # Desktop
      fonts
      keyboard
      language
    ];
  };
}
