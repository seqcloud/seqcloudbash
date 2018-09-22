# Require admin account.
# if [[ "$(whoami)" != "admin" ]]; then
#     echo "This script must be run as admin"
#     return 1
# fi

# Homebrew
brew update
echo "Upgrading Homebrew..."
brew upgrade
echo "Upgrading Homebrew Casks..."
brew cask outdated | xargs brew cask reinstall

# Mac App Store
if [[ -n "$(command -v mas)" ]]; then
    echo "Upgrading Mac App Store Apps..."
    mas upgrade
fi
