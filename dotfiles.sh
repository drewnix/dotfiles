
PACKAGES=(
	zsh
    ranger
)

# Check if 'stow' command exists in the user's path
if ! command -v stow &> /dev/null; then
    echo "GNU Stow is required"
    exit 1
fi

for PKG in ${PACKAGES[@]}; do
	CONFLICTS=$(stow --no --verbose $PKG 2>&1 | awk '/\* existing target is/ {print $NF}')
    if [ -n "$CONFLICTS" ]; then
        echo "Conflicts found with package $PKG: $CONFLICTS"
        continue
    fi

	stow --no-folding --verbose $PKG
done