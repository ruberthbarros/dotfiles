{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  # Some casks (zoom, docker-desktop, adopting a root-owned app) call sudo themselves.
  # sudo runs each command in its own pseudo-terminal, so the default per-terminal
  # password cache never reaches those nested calls and every one prompts again.
  # A per-user cache lets the one password typed for rebuild.sh cover them all.
  security.sudo.extraConfig = ''
    Defaults:${user} timestamp_type=global
  '';
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    autoMigrate = true;  # adopt the pre-existing /opt/homebrew install instead of erroring
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "herdr"
      "awscli"
      "gh"
      "node"
    ];
    casks = [
      # terminals + editors
      "wezterm"
      "visual-studio-code"
      # ai
      "claude-code@latest"
      "claude"
      "chatgpt"
      # work + chat
      "slack"
      "zoom"
      "linear"
      "granola"
      "obsidian"
      # dev tools
      "docker-desktop"
      "postman"
      # utilities
      "rectangle"
    ];
  };
}
