#!/usr/bin/env bash

# Dotfiles setup script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create symbolic links
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ -L "$target" ]]; then
        print_warning "Symlink already exists: $target"
        return 0
    fi
    
    if [[ -e "$target" ]]; then
        print_warning "File exists, backing up: $target"
        mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    print_success "Created symlink: $target -> $source"
}

# Function to set fish as default shell
setup_fish() {
    print_status "Setting up fish shell..."
    
    # Check if fish is installed
    if ! command -v fish &> /dev/null; then
        print_error "Fish shell is not installed. Please install it first."
        return 1
    fi
    
    # Get fish path
    local fish_path=$(which fish)
    
    # Check if fish is in /etc/shells
    if ! grep -q "$fish_path" /etc/shells; then
        print_status "Adding fish to /etc/shells..."
        echo "$fish_path" | sudo tee -a /etc/shells
    fi
    
    # Set fish as default shell
    if [[ "$SHELL" != "$fish_path" ]]; then
        print_status "Setting fish as default shell..."
        chsh -s "$fish_path"
        print_success "Fish set as default shell. Please log out and log back in for changes to take effect."
    else
        print_success "Fish is already the default shell."
    fi
    
    # Install fisher if not already installed
    if ! fish -c "type -q fisher" &> /dev/null; then
        print_status "Installing fisher plugin manager..."
        fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
        print_success "Fisher installed successfully."
    else
        print_success "Fisher is already installed."
    fi
    
    # Install fish plugins
    if [[ -f "$HOME/.config/fish/fish_plugins" ]]; then
        print_status "Installing fish plugins..."
        fish -c "fisher update"
        print_success "Fish plugins installed/updated."
    fi
}

# Function to setup dotfiles
setup_dotfiles() {
    local dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    print_status "Setting up dotfiles from: $dotfiles_dir"
    
    # Create symlinks for config files
    create_symlink "$dotfiles_dir/.config/niri" "$HOME/.config/niri"
    create_symlink "$dotfiles_dir/.config/waybar" "$HOME/.config/waybar"
    create_symlink "$dotfiles_dir/.config/foot" "$HOME/.config/foot"
    create_symlink "$dotfiles_dir/.config/fuzzel" "$HOME/.config/fuzzel"
    create_symlink "$dotfiles_dir/.config/yazi" "$HOME/.config/yazi"
    create_symlink "$dotfiles_dir/.config/swaync" "$HOME/.config/swaync"
    create_symlink "$dotfiles_dir/.config/swaybg" "$HOME/.config/swaybg"
    create_symlink "$dotfiles_dir/.config/fish" "$HOME/.config/fish"
    create_symlink "$dotfiles_dir/.config/gtk-3.0" "$HOME/.config/gtk-3.0"
    create_symlink "$dotfiles_dir/.config/gtk-4.0" "$HOME/.config/gtk-4.0"
    create_symlink "$dotfiles_dir/.config/starship.toml" "$HOME/.config/starship.toml"
    create_symlink "$dotfiles_dir/.config/mimeapps.list" "$HOME/.config/mimeapps.list"
    create_symlink "$dotfiles_dir/.local/share/applications" "$HOME/.local/share/applications"
    
    # Create wallpaper directory
    mkdir -p "$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME/Pictures/Screenshots"
    
    print_success "Dotfiles setup completed!"
}

# Function to enable services
enable_services() {
    print_status "Enabling system services..."
    
    # Enable ly display manager
    if systemctl list-unit-files | grep -q "ly.service"; then
        sudo systemctl enable ly.service
        print_success "Enabled ly display manager"
    else
        print_warning "ly.service not found, skipping..."
    fi
    
    # Enable NetworkManager
    if systemctl list-unit-files | grep -q "NetworkManager.service"; then
        sudo systemctl enable NetworkManager.service
        print_success "Enabled NetworkManager"
    fi
    
    # Enable Bluetooth
    if systemctl list-unit-files | grep -q "bluetooth.service"; then
        sudo systemctl enable bluetooth.service
        print_success "Enabled Bluetooth"
    fi
    
    # Enable time synchronization
    if systemctl list-unit-files | grep -q "systemd-timesyncd.service"; then
        sudo systemctl enable systemd-timesyncd.service
        print_success "Enabled time synchronization"
    fi
    
    # Enable SSD trim (if available)
    if systemctl list-unit-files | grep -q "fstrim.timer"; then
        sudo systemctl enable fstrim.timer
        print_success "Enabled SSD trim timer"
    fi
}

# Function to configure user groups and permissions
configure_user() {
    print_status "Configuring user groups and permissions..."
    
    # Add user to required groups
    sudo usermod -a -G audio,video,input,wheel "$USER" 2>/dev/null || true
    print_success "Added user to audio, video, input, wheel groups"
    
    # Make swaybg script executable
    if [[ -f "$HOME/.config/swaybg/start.sh" ]]; then
        chmod +x "$HOME/.config/swaybg/start.sh"
        print_success "Made swaybg start script executable"
    fi
    
    # Make niri scripts executable
    if [[ -d "$HOME/.config/niri/scripts" ]]; then
        chmod +x "$HOME/.config/niri/scripts/"*.sh 2>/dev/null || true
        print_success "Made niri scripts executable"
    fi
}

# Main execution
main() {
    print_status "Starting dotfiles setup..."
    
    setup_dotfiles
    setup_fish
    enable_services
    configure_user
    
    print_success "Setup completed!"
    print_warning "Please log out and log back in for all changes to take effect."
    print_warning "You may also want to reboot to ensure all services are properly started."
}

# Run main function
main "$@"