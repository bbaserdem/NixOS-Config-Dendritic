# DevShell for JoeyMJProj — Electron + Node 22 + npm (better-sqlite3 native)
{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    devShells.workNode22 = pkgs.mkShell {
      packages = with pkgs; [
        # Full Node 22 (NOT nodejs-slim: the repo needs npm on PATH).
        # package.json declares engines >=22.12 <23, and the delivery
        # channel is npm + package-lock.json (START.command runs `npm ci`)
        # — deliberately no pnpm here, it would diverge the lockfile.
        nodejs_22
        pnpm
        # node-gyp fallback if a better-sqlite3 Electron-ABI prebuild
        # fetch ever fails (scripts/ensure-native-modules.cjs normally
        # downloads the prebuilt binding without compiling anything)
        python3
        # Tooling for agents
        ripgrep
        shellcheck
        nixd
        bash-language-server
        socat
      ];
      shellHook = ''
        # First entry into the repo: install pinned deps, then self-heal
        # the native runtime pieces (Electron binary + better-sqlite3
        # binding) that ignore-scripts=true npm configs skip.
        if [ -f package-lock.json ] && [ ! -d node_modules ]; then
          echo "Installing npm dependencies (npm ci)..."
          npm ci
        fi
        if [ -d node_modules ] && [ -f scripts/ensure-native-modules.cjs ]; then
          node scripts/ensure-native-modules.cjs || echo "WARN: native module self-heal failed; run it manually"
        fi
      '';
    };
  };
}
