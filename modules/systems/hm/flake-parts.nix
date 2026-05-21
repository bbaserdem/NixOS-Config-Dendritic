# Home-Manager setup
{inputs, ...}: {
  # Import the flake-parts modules for home-manager
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];
}
