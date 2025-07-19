#!/usr/bin/env bash
# Function to install yay if not installed
install_yay() {
    if ! command -v yay &>/dev/null; then
        echo "Installing yay..."
        sudo pacman -S --needed git base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay || exit
        makepkg -si --noconfirm
        cd .. || exit
        rm -rf yay
        echo "yay installed successfully!"
    else
        echo "yay is already installed."
    fi
}

# Function to check if a package exists in official repositories
check_pacman_package() {
    pacman -Si "$1" &>/dev/null
}

# Function to check if a package exists in AUR
check_aur_package() {
    if command -v yay &>/dev/null; then
        yay -Si "$1" &>/dev/null
    elif command -v paru &>/dev/null; then
        paru -Si "$1" &>/dev/null
    else
        echo "Warning: No AUR helper found (yay or paru)"
        return 1
    fi
}

# Function to install packages
install_packages() {
    local pacman_packages=()
    local aur_packages=()
    local failed_packages=()

    echo "Checking packages..."
    
    for package in "${packages[@]}"; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue
        
        if check_pacman_package "$package"; then
            pacman_packages+=("$package")
            echo "✓ Found in official repos: $package"
        elif check_aur_package "$package"; then
            aur_packages+=("$package")
            echo "✓ Found in AUR: $package"
        else
            failed_packages+=("$package")
            echo "✗ Package not found: $package"
        fi
    done

    # Install official packages
    if [[ ${#pacman_packages[@]} -gt 0 ]]; then
        echo ""
        echo "Installing official packages..."
        sudo pacman -S --needed "${pacman_packages[@]}"
    fi

    # Install AUR packages
    if [[ ${#aur_packages[@]} -gt 0 ]]; then
        echo ""
        echo "Installing AUR packages..."
        if command -v yay &>/dev/null; then
            yay -S --needed "${aur_packages[@]}"
        elif command -v paru &>/dev/null; then
            paru -S --needed "${aur_packages[@]}"
        else
            echo "Error: No AUR helper found. Please install yay or paru first."
        fi
    fi

    # Report failed packages
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        echo ""
        echo "The following packages could not be found:"
        printf "  - %s\n" "${failed_packages[@]}"
    fi

    echo ""
    echo "Package installation completed!"
}

packages=(
    # Wayland compositor
    niri
    
    # Display manager
    ly
    
    # Status bar and widgets
    waybar
    
    # Application launcher
    fuzzel
    
    # Terminal emulator
    foot
    
    # Shell
    fish
    starship
    
    # Notifications
    swaync

    # Wallpaper
    swaybg

    # Power management
    swayidle
    
    # Input method
    fcitx5-im
    fcitx5-rime
    rime-ice-git
    
    # Text editor
    neovim
    
    # Audio system
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    playerctl
    pavucontrol
    
    # File manager
    yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide imagemagick
    resvg
    bat
    eza
    trash-cli
    curl
    
    # Media player
    mpv
    
    # Image viewer
    imv
    
    # Screenshot utility
    grim
    slurp
    swappy
    
    # Clipboard manager
    wl-clipboard
    cliphist
    wtype
    
    # Brightness control
    brightnessctl
    
    # Portal utilities
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    gnome-keyring
    polkit-kde-agent

    # Lock screen
    swaylock

    # PDF viewer
    zathura
    zathura-pdf-mupdf

    # Fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    maplemono-nf-cn-unhinted

    
    # Themes and icons
    papirus-icon-theme
    adwaita-qt5
    adwaita-qt6
    
    # Network manager
    networkmanager
    nm-connection-editor
    openssh
    
    # Bluetooth
    bluez
    bluez-utils
    blueman

    # System monitoring
    htop

    # Browser
    firefox
)

# Check if script is being executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Starting package installation..."
    echo "This script will install packages using pacman and AUR helpers (yay/paru)"
    echo ""
    
    # Ask for confirmation
    read -p "Do you want to proceed with the installation? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_yay
        install_packages
    else
        echo "Installation cancelled."
        exit 0
    fi
fi