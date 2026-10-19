# dotfiles

My personal Mac setup, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up configured the same way every time.

Forked from [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles) ([walkthrough video](https://youtu.be/5N-okeDdIuI)).

## Contributing / Using This Repo

These are my personal dotfiles, shared publicly so people can read them, learn from them, and fork them freely.
Feature requests and pull requests are not accepted here, and PRs are auto-closed.
If you find a bug, please open a GitHub Issue using the bug report template.

## What you get

Running the switch builds:

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew CLI tools (`brews` in `configuration.nix`): herdr, awscli, gh, node
- Homebrew apps (`casks` in `configuration.nix`): Slack, Zoom, Claude, Linear, Granola, VS Code, Cursor, browsers, Docker Desktop, and more
- Nix user packages (`home.packages` in `home.nix`): ripgrep, fd, fzf, jq, lazygit, Neovim, uv, duckdb, terraform, terragrunt, Hack Nerd Font
- Shell (zsh, aliases, starship prompt)
- Editor (Neovim config with the rose-pine moon theme)
- Terminal (WezTerm config with the rose-pine moon theme)
- Agent configs (Claude, Codex, opencode all share one AGENTS.md, plus Claude settings and skills)

## New laptop setup, step by step

Plan for about an hour, mostly waiting on downloads.
Apple Silicon is assumed (see "Make it yours" for Intel).

### 1. Get macOS ready

1. Finish the macOS setup assistant and create your user account.
   Using `ruberth` as the account name means no edits are needed, but `bootstrap.sh` can fix a different name for you.
2. Sign in to your Apple ID and run System Settings > General > Software Update.
3. Install Apple's command line tools, which give you `git`:

   ```sh
   xcode-select --install
   ```

   Click "Install" in the popup and wait for it to finish.

### 2. Clone and run the bootstrap

```sh
mkdir -p ~/github/ruberthbarros
cd ~/github/ruberthbarros
git clone https://github.com/ruberthbarros/dotfiles.git
cd dotfiles
./bootstrap.sh
```

`bootstrap.sh` does four things, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles`.
   This has to happen before the first build, because `home.nix` points at config files through `~/.dotfiles`.
3. Checks the `user` configured in `flake.nix` against your actual macOS username, and offers to fix it for you if they differ.
4. Runs the first `darwin-rebuild switch`.
   It fetches the `darwin-rebuild` tool from the nix-darwin 26.05 release branch, then applies this repo's locked flake config.
   This step installs Homebrew and every app in `configuration.nix`, so it takes a while.

It asks for your password more than once (for `sudo`, and for some app installers).
If it fails with `nix: command not found`, open a new terminal window and run `./bootstrap.sh` again.

### 3. Open a new terminal

Quit Terminal and open WezTerm.
The new shell has the zsh config, prompt, and all the tools on its `PATH`.
The first time you run `nvim`, it downloads its plugins (needs network once).

### 4. Log in to things

The config installs apps but cannot log in for you.

1. Set your git identity (this config deliberately does not set it):

   ```sh
   git config --global user.name "Your Name"
   git config --global user.email you@example.com
   ```

2. GitHub CLI, and an SSH key if you push over SSH:

   ```sh
   gh auth login
   ```

   `gh auth login` can create and upload an SSH key for you when it asks about the protocol.
3. AWS: `aws configure sso` (or `aws configure` for access keys).
4. Claude Code: run `claude` and follow the login prompt.
5. Open each app once and sign in: Slack, Zoom, Claude, ChatGPT, Linear, Granola, Chrome, Spotify, and so on.

### 5. Grant macOS permissions

Some apps only work after you allow them in System Settings > Privacy & Security.
Each app usually prompts you on first launch.

- Accessibility: Rectangle, Logi Options+
- Screen & System Audio Recording: Zoom, Slack, Granola, Chrome (for screen sharing)
- Microphone and Camera: Zoom, Slack, Granola, Chrome

Also start Docker Desktop once to accept its terms and finish its setup, and pick your default browser in System Settings > Desktop & Dock.

### 6. Install what the config doesn't cover

- Mac App Store only apps (for example Kindle).
- Work-managed apps (security, VPN, device management) come from your company's IT, not from this repo.

That's it. From now on, use the daily workflow below.

## Validate without applying

Once Nix is installed (`bootstrap.sh` step 1 handles that), you can check that the config builds without touching your system - handy when you have edited something:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

If you renamed the host label in "Make it yours", substitute your label for `mac` in these commands.

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

That's it.
No separate build-and-copy step.

To add an app, find its cask name with `brew search <name>`, add it to `casks` in `configuration.nix`, and run `./rebuild.sh`.
Never install with `brew install` directly - the next rebuild removes it (see the cleanup warning below).

## Make it yours

If you fork this repo, review these before you run `bootstrap.sh`:

- **Username**: run `./bootstrap.sh` (it detects your macOS username and offers to set it) OR change the single `user = "ruberth"` line in `flake.nix`.
  Everything else (`configuration.nix`, `home.nix`, home directory paths) is threaded from that one variable.
- **Host label** `"mac"`, in three places: `flake.nix` (the `darwinConfigurations."mac"` name), `rebuild.sh:5` (the `#mac` at the end of the flake reference), and `bootstrap.sh`'s first-switch command (also `#mac`).
  All three have to match.
- **CPU architecture**: `hostPlatform` in `configuration.nix`.
  For an Intel Mac, set `nixpkgs.hostPlatform = "x86_64-darwin";` (the comment right there tells you the same thing).
- **App list**: trim `brews` and `casks` in `configuration.nix` to what you actually use.

**Git identity:** this config deliberately does not set your git name or email.
If you'd rather manage that declaratively, add this to `home.nix` with your own identity:

```nix
programs.git = {
  enable = true;
  settings.user = {
    name = "Your Name";
    email = "you@example.com";
  };
};
```

**Homebrew cleanup warning:** `configuration.nix` sets `homebrew.onActivation.cleanup = "zap"`.
That means every time you switch, Homebrew removes any package or cask on your machine that isn't listed in the `brews` and `casks` arrays in `configuration.nix`.
"Zap" also deletes that app's settings and data, not just the app.
If you already have Homebrew stuff installed that isn't in that list, the first switch will uninstall it.
Apps you installed outside Homebrew (drag-and-drop or the App Store) are not touched.
Read through `brews` and `casks` before you run `bootstrap.sh` or `rebuild.sh` for the first time, and add anything you want to keep.

**About `herdr`:** it's in the `brews` list.
It's a real public Homebrew formula (`brew info herdr` finds it in homebrew-core, no tap needed), so it will install fine.
If you don't use it, just remove it from `brews` in your copy.

**Heads-up:**

- `home/AGENTS.md` is my personal agent policy, and `home.nix` installs it for Claude, Codex, and opencode.
  If you clone this repo, you'd silently inherit my agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- The `cc` and `co` shell aliases in `home.nix` are high-agency shortcuts: `claude --dangerously-skip-permissions` and `codex --full-auto`.
  They're convenient for me, but know what they do before you use them.

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs, nix-darwin, home-manager, and nix-homebrew, and declares the `mac` machine.
- `configuration.nix` - system-level config: macOS defaults, Homebrew CLI tools and apps.
- `home.nix` - user-level config: shell, Nix packages, prompt, and the symlinks described below.
- `bootstrap.sh` - one-time setup for a fresh Mac.
- `rebuild.sh` - re-applies the config after the first switch.
  Run this every time you make a change.
- `sync-skills.sh` - copies Claude skills installed by `npx mattpocock/skills` into `home/.claude/skills` so they are versioned here.
- `home/` - the actual config files that get symlinked into place (Neovim, WezTerm, herdr, Claude settings, hooks and skills, the shared `AGENTS.md`).

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim` straight at `home/.config/nvim` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list or a system default.

## Notes

The first time you launch `nvim`, it bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) by cloning plugins from GitHub.
That needs network access once; after that it's offline.
Neovim and WezTerm both use the rose-pine moon theme.
Neovim keeps italics off and uses a transparent background on macOS, Windows, and WSL so it matches the terminal setup.

## License

This repo is licensed under MIT No Attribution.
See `LICENSE`.
