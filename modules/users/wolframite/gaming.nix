# Apply gaming factory function
{inputs, ...}: {
  flake.modules = inputs.self.factory.gaming {user = "wolframite";};
}
