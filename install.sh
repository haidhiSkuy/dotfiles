#!/bin/bash

# =============================================================================
#  Dotfiles Setup Script
#  Arch Linux · by $(whoami)
# =============================================================================

set -e  # exit on error

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}${BOLD}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}${BOLD}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}${BOLD}[ERROR]${RESET} $*"; exit 1; }
section() { echo -e "\n${CYAN}${BOLD}━━━━━━━━━━━━━━━━━  $*  ━━━━━━━━━━━━━━━━━${RESET}"; }

command_exists() { command -v "$1" &>/dev/null; }

# ── Root check ────────────────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
  error "Do not run this script as root. It will use sudo when needed."
fi

# =============================================================================
#  SYSTEM PACKAGES (pacman)
# =============================================================================
section "System Packages"

PACMAN_PKGS=(
  fastfetch
  base-devel
  git
  zsh
  curl
  wget
  unzip
)

info "Installing pacman packages: ${PACMAN_PKGS[*]}"
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
success "System packages installed."

# =============================================================================
#  FONTS
# =============================================================================
section "Nerd Fonts · CascadiaMono"

FONT_DIR="/usr/share/fonts/CascadiaMono"

if fc-list | grep -qi "CascadiaMono"; then
  warn "CascadiaMono already installed, skipping."
else
  FONT_ZIP="CascadiaMono.zip"
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaMono.zip"

  info "Downloading CascadiaMono..."
  wget -q --show-progress "$FONT_URL" -O "$FONT_ZIP"

  info "Installing to $FONT_DIR..."
  unzip -q "$FONT_ZIP" -d CascadiaMono
  sudo mv CascadiaMono "$FONT_DIR"
  sudo fc-cache -fv &>/dev/null

  rm -f "$FONT_ZIP"
  success "CascadiaMono installed."
fi

# =============================================================================
#  PARU (AUR helper)
# =============================================================================
section "Paru · AUR Helper"

if command_exists paru; then
  warn "paru already installed, skipping."
else
  info "Cloning paru..."
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  pushd /tmp/paru > /dev/null
  makepkg -si --noconfirm
  popd > /dev/null
  rm -rf /tmp/paru
  success "paru installed."
fi

# =============================================================================
#  RUST
# =============================================================================
section "Rust Toolchain"

if command_exists rustup; then
  warn "Rust already installed. Running update instead."
  rustup update
else
  info "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # Source cargo env for the rest of this session
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
  success "Rust installed."
fi

# =============================================================================
#  CARGO TOOLS
# =============================================================================
section "Cargo Packages · eza & bat"

if command_exists eza; then
  warn "eza already installed, skipping."
else
  info "Installing eza (modern ls)..."
  cargo install eza
  success "eza installed."
fi

if command_exists bat; then
  warn "bat already installed, skipping."
else
  info "Installing bat (modern cat)..."
  cargo install bat
  success "bat installed."
fi

# =============================================================================
#  STARSHIP PROMPT
# =============================================================================
section "Starship Prompt"

if command_exists starship; then
  warn "Starship already installed, skipping."
else
  info "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  success "Starship installed."
fi

if [[ -f ".config/starship.toml" ]]; then
  mkdir -p "$HOME/.config"
  cp .config/starship.toml "$HOME/.config/starship.toml"
  success "starship.toml copied."
else
  warn "starship.toml not found in .config/, skipping copy."
fi

# =============================================================================
#  ZSH PLUGINS
# =============================================================================
section "Zsh Plugins"

ZSH_DIR="$HOME/.zsh"
mkdir -p "$ZSH_DIR"

if [[ -d "$ZSH_DIR/zsh-autosuggestions" ]]; then
  warn "zsh-autosuggestions already present, pulling latest."
  git -C "$ZSH_DIR/zsh-autosuggestions" pull
else
  info "Cloning zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_DIR/zsh-autosuggestions"
  success "zsh-autosuggestions cloned."
fi

if [[ -d "$ZSH_DIR/zsh-syntax-highlighting" ]]; then
  warn "zsh-syntax-highlighting already present, pulling latest."
  git -C "$ZSH_DIR/zsh-syntax-highlighting" pull
else
  info "Cloning zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_DIR/zsh-syntax-highlighting"
  success "zsh-syntax-highlighting cloned."
fi

# =============================================================================
#  ZSHRC
# =============================================================================
section "Zsh Config"

if [[ -f "zsh/.zshrc" ]]; then
  if [[ -f "$HOME/.zshrc" ]]; then
    warn "Backing up existing .zshrc → ~/.zshrc.bak"
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi
  cp zsh/.zshrc "$HOME/.zshrc"
  success ".zshrc copied."
else
  warn "zsh/.zshrc not found in dotfiles, skipping."
fi

# =============================================================================
#  SET DEFAULT SHELL TO ZSH
# =============================================================================
section "Default Shell"

if [[ "$SHELL" == "$(command -v zsh)" ]]; then
  warn "zsh is already the default shell."
else
  info "Changing default shell to zsh..."
  chsh -s "$(command -v zsh)"
  success "Default shell set to zsh. Re-login to apply."
fi

# =============================================================================
#  DONE
# =============================================================================
echo -e "\n${GREEN}${BOLD}  All done! Dotfiles installed successfully.${RESET}"
echo -e "${CYAN}  → Re-open your terminal (or run: exec zsh) to apply changes.${RESET}\n"