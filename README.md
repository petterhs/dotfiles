# NixOS Dotfiles

Personal NixOS configuration with a modular, multi-host setup using flakes and home-manager.

## 🏗️ Architecture

This configuration uses a modular approach with shared common modules and host-specific overrides:

```
dotfiles/
├── modules/
│   ├── common/           # Shared configurations for all hosts
│   │   ├── nix.nix       # Nix settings, flakes, substituters
│   │   ├── system.nix    # System config (bootloader, networking, etc.)
│   │   ├── hyprland.nix  # Hyprland window manager setup
│   │   ├── development.nix # Development tools (Docker, ADB, etc.)
│   │   ├── graphical.nix # File managers, XFCE tools
│   │   ├── teams.nix     # Teams customization
│   │   └── home-manager.nix # Home-manager configuration
│   └── hosts/            # Host-specific configurations
│       ├── nixdesktop.nix
│       ├── nixdesktop-btc.nix # Bitcoin node (nixdesktop only)
│       └── no-kon-lx-016.nix
├── hosts/                # Hardware-specific configurations
│   ├── nixdesktop/
│   └── no-kon-lx-016/
├── home/                 # Home-manager user configurations
│   ├── common.nix        # Shared user packages and programs
│   ├── users/            # User-specific configurations
│   └── programs/         # Program-specific configurations
└── overlays/             # Custom package definitions
```

## 🖥️ Hosts

### nixdesktop
- **Purpose**: Desktop workstation
- **Features**: 
  - NVIDIA graphics support
  - Bitcoin node (Bitcoind + Electrs)
  - LUKS encryption
  - Users: `petter`, `petter-work`

### no-kon-lx-016
- **Purpose**: Laptop/portable workstation
- **Features**:
  - NetworkManager with SSTP VPN support
  - Development tools (Docker, ADB, Wireshark)
  - User: `s27731`

## 🚀 Quick Start

### Build and switch configuration

For nixdesktop:
```bash
sudo nixos-rebuild switch --flake '.#nixdesktop'
```

For no-kon-lx-016:
```bash
sudo nixos-rebuild switch --flake '.#no-kon-lx-016'
```

### Update flake inputs
```bash
nix flake update
```

## 🎨 Features

### Window Manager
- **Hyprland** with custom configuration
- **Greetd** for login management
- **Waybar** for status bar
- **Wofi** for application launcher

### Development Environment
- **Docker** with rootless support
- **ADB** for Android development
- **Wireshark** for network analysis
- **Git** with difftastic integration
- **Neovim** with custom configuration

### Audio & Graphics
- **Pipewire** for audio
- **Bluetooth** support
- **NVIDIA** support (nixdesktop)
- **Portal** support for file dialogs

### Home Manager Configuration
- **Shell**: Fish with custom aliases and zoxide integration
- **Terminal**: Alacritty
- **Editor**: Neovim with custom nixvim configuration
- **File Manager**: Thunar 
- **Development**: Tmux, Git with difftastic, direnv with nix-direnv
- **Productivity**: Starship prompt, fzf, bat, eza, ripgrep
- **System Monitoring**: btop, iotop, iftop, strace, lsof
- **Nix Tools**: nix-output-monitor, nvd, nixpkgs-fmt, devenv
- **Media**: imv (image viewer), vlc (video player)
- **Browsers**: Firefox, Chromium
- **Security**: Bitwarden, ProtonMail desktop client
- **Fonts**: JetBrains Mono, Iosevka, Inconsolata (Nerd Fonts)

### Security & Privacy
- **LUKS** disk encryption (nixdesktop)
- **SSH** access enabled
- **Trusted users** configured per host

## 📦 Package Management

### System Packages
System-level packages are defined in `modules/common/system.nix` and include:
- Audio/system services (pavucontrol, playerctl)
- GUI libraries (gtk3, gtk4, libadwaita)
- Portal support (xdg-desktop-portal-gtk)

### User Packages
User-specific packages are managed by home-manager in `home/common.nix` and include:
- Development tools (vim, git, alacritty)
- Productivity apps (firefox, chromium, vlc)
- System monitoring tools (btop, iotop, strace)
- Nix development tools (nix-output-monitor, nvd)

## 🔧 Custom Packages

### Teams for Linux
Custom package definition in `overlays/teams-for-linux-package.nix` with Wayland support.

### Teams Background Customization
Caddy server configuration for custom Teams backgrounds in `modules/common/teams.nix`.

## 🎯 Theming

- **Catppuccin** theme throughout the system
- **JetBrains Mono** and **Iosevka** fonts
- **Custom cursor** theme
- **4K monitor** support with proper DPI scaling

## 🔐 Security

- **Trusted users** configured per host
- **Firewall** rules for development ports
- **LUKS** encryption on nixdesktop
- **SSH** access enabled

## 📝 Maintenance

### Adding a new host
1. Create hardware configuration in `hosts/new-host/`
2. Create host-specific module in `modules/hosts/new-host.nix`
3. Add configuration to `flake.nix`

### Adding common packages
- System packages: Add to `modules/common/system.nix`
- User packages: Add to `home/common.nix`

### Updating configurations
- Common changes: Modify files in `modules/common/`
- Host-specific changes: Modify files in `modules/hosts/`

## 🐛 Troubleshooting


## 📄 License

MIT License - This configuration is for personal use. Feel free to use parts of it for your own setup.