# Modern Vim Configuration - Setup Guide

## Quick Start

### 1. Run Bootstrap Script (if you haven't already)

```bash
cd ~/dotfiles
./bootstrap.sh
```

This installs:

- ✅ fzf and ripgrep (essential for Vim fuzzy finding)
- ✅ Git, zsh, stow, and other core tools
- ✅ Cloud tools (kubectl, terraform, aws, gcloud) in full mode

### 2. Install the Vim Config (via Stow)

```bash
cd ~/dotfiles
stow vim
```

This creates symlinks:

- `~/.vimrc` → `~/dotfiles/vim/.vimrc`
- `~/.vim/` → `~/dotfiles/vim/.vim/`

### 3. Install Language Servers & Tools

You have **two options** for LSP server installation:

#### Option A: Automated Installation (Recommended)

Run the included installation script (**no sudo required** for most tools):

```bash
cd ~/dotfiles/vim
./install-lsp-servers.sh
```

This intelligent script will:

- ✅ Detect your OS and package manager
- ✅ Install all available LSP servers and formatters
- ✅ Skip tools already installed
- ✅ Show clear summary of what was installed
- ✅ Work on Fedora, macOS, Ubuntu, Arch Linux
- ✅ Install Node.js packages to `~/.local/bin` (no sudo needed)
- ✅ Install Python packages with `--user` flag (no sudo needed)
- ⚠️ May ask for sudo only for system tools (fzf, ripgrep, shellcheck)

**What it installs:**

- **System tools**: fzf, ripgrep, shellcheck (if not already installed)
- **Python**: pyright, black, isort, flake8, mypy
- **JavaScript/TypeScript**: typescript-language-server, prettier, eslint
- **Go**: gopls, golint
- **Rust**: rustfmt, rust-analyzer
- **Shell**: bash-language-server
- **YAML**: yaml-language-server (for Kubernetes manifests)

#### Option B: Manual Installation

Install only what you need:

```bash
# Python tools
pip3 install --user black isort flake8 mypy
npm install -g pyright

# JavaScript/TypeScript tools
npm install -g typescript typescript-language-server

# Go tools
go install golang.org/x/tools/gopls@latest

# Rust tools
rustup component add rustfmt rust-analyzer

# Shell/YAML tools
npm install -g bash-language-server yaml-language-server
```

**Note**: ALE gracefully handles missing tools - install only what you need for your projects!

#### Project-Specific Tools (Best Practice)

For real projects, install formatters/linters per-project:

```json
// package.json (JavaScript/TypeScript projects)
{
  "devDependencies": {
    "prettier": "^3.0.0",
    "eslint": "^8.0.0"
  }
}
```

```txt
# requirements.txt (Python projects)
black==24.0.0
isort==5.13.0
flake8==7.0.0
```

Vim/ALE will auto-detect and use project-local tools when available!

### 4. First Launch

Open Vim for the first time:

```bash
vim
```

What will happen:

1. vim-plug auto-installs itself
2. All plugins install automatically
3. You may see errors initially (colorscheme not yet installed) - this is normal
4. After `:PlugInstall` completes, restart Vim

### 5. Manual Plugin Installation (if auto-install fails)

If the auto-bootstrap doesn't work, manually install vim-plug:

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Then open Vim and run:

```vim
:PlugInstall
```

## Configuration Structure

```text
~/dotfiles/vim/
├── .vimrc                           # Main configuration
└── .vim/
    └── after/
        └── ftplugin/                # Language-specific settings
            ├── python.vim           # Python: 4 spaces, black, isort
            ├── javascript.vim       # JavaScript: 2 spaces, prettier
            ├── typescript.vim       # TypeScript: 2 spaces, prettier
            ├── go.vim              # Go: tabs, gofmt, goimports
            ├── rust.vim            # Rust: 4 spaces, rustfmt
            ├── terraform.vim       # Terraform: 2 spaces, terraform fmt
            └── yaml.vim            # YAML: 2 spaces, K8s validation
```

## Essential Key Mappings

### Leader Key

- Leader key is `,` (comma)

### Fuzzy Finding (fzf)

- `Ctrl-p` - Find files
- `,b` - Browse buffers
- `,g` - Ripgrep search
- `,l` - Search lines in current buffer
- `,h` - Command history

### Git Operations (fugitive)

- `,gs` - Git status
- `,gc` - Git commit
- `,gp` - Git push
- `,gl` - Git pull
- `,gd` - Git diff
- `,gb` - Git blame
- `]h` / `[h` - Next/previous git hunk
- `,ha` - Stage hunk
- `,hu` - Undo hunk
- `,hp` - Preview hunk

### Linting/Errors (ALE)

- `]e` / `[e` - Next/previous error
- `,d` - Show error details

### Editing

- `gcc` - Toggle line comment
- `gc{motion}` - Comment using motion (e.g., `gcap` comments paragraph)
- `cs"'` - Change surrounding " to ' (vim-surround)
- `ds"` - Delete surrounding "
- `ys{motion}{char}` - Surround with char (e.g., `ysiw"` surrounds word with ")

### Vimrc Management

- `,ev` - Edit vimrc
- `,rv` - Reload vimrc

### Quick Actions

- `,w` - Save file
- `,q` - Quit

## Colorscheme Options

Default is **Gruvbox** (warm, retro). To switch:

Edit `~/.vimrc` and uncomment one of these lines (around line 117):

```vim
" colorscheme tokyonight-storm    " Modern clean aesthetic
" colorscheme catppuccin-mocha    " Soothing pastels
```

Or add to `~/.vimrc.local`:

```vim
colorscheme tokyonight-storm
let g:lightline = {'colorscheme': 'tokyonight'}
```

## Customization

### Machine-Specific Settings

Create `~/.vimrc.local` for personal customizations that shouldn't be in your dotfiles:

```vim
" Example ~/.vimrc.local
colorscheme tokyonight-storm
set number!              " Disable line numbers
let g:ale_fix_on_save = 0  " Disable auto-fix
```

### Disable Auto-Formatting

If you don't want auto-fix on save:

```vim
" In ~/.vimrc.local
let g:ale_fix_on_save = 0
```

### Language-Specific Tweaks

Edit the appropriate ftplugin file:

- Python: `~/.vim/after/ftplugin/python.vim`
- JavaScript: `~/.vim/after/ftplugin/javascript.vim`
- Go: `~/.vim/after/ftplugin/go.vim`
- etc.

## Plugin Management

### Install/Update Plugins

```vim
:PlugInstall    " Install missing plugins
:PlugUpdate     " Update all plugins
:PlugUpgrade    " Upgrade vim-plug itself
:PlugClean      " Remove unused plugins
:PlugDiff       " Review changes from last update
```

### Check Plugin Status

```vim
:PlugStatus
```

## Troubleshooting

### Plugins won't install

1. Check internet connectivity
2. Manually install vim-plug (see step 4 above)
3. Run `:PlugInstall` manually
4. Check `:messages` for errors

### Colorscheme errors on first launch

This is normal - the colorscheme plugin isn't installed yet. After `:PlugInstall` completes and you restart Vim, it will work.

### ALE shows errors for missing linters

ALE only uses linters that are installed. Either:

- Install the missing linter (see step 2 above)
- Ignore the message (ALE will skip unavailable linters)

### Formatting doesn't work

1. Ensure the formatter is installed (e.g., `black`, `prettier`, `gofmt`)
2. Check `:ALEInfo` to see what's configured
3. Test manually: `:ALEFix`

### Check what's running

```vim
:ALEInfo       " Show ALE configuration and diagnostics
:version       " Show Vim version and features
:PlugStatus    " Show plugin status
```

### Slow startup

Profile startup time:

```bash
vim --startuptime startup.log +qall
less startup.log
```

Look for plugins taking >50ms and consider lazy-loading them.

## Performance Tips

### For SSH/Remote Editing

The config is already optimized for SSH:

- ALE lints only on save (not on every keystroke)
- Swap/backup files disabled
- Lazy redrawing enabled

### Disable Features Temporarily

```vim
:ALEDisable          " Disable linting
:GitGutterDisable    " Disable git diff indicators
:set norelativenumber " Disable relative line numbers
```

## Going Further

### Learn the New Tools

- **fzf.vim**: `:help fzf-vim`
- **ALE**: `:help ale`
- **fugitive**: `:help fugitive`
- **vim-surround**: `:help surround`

### Add More Plugins

Edit `~/.vimrc`, add between `call plug#begin()` and `call plug#end()`:

```vim
Plug 'author/plugin-name'
```

Then run `:PlugInstall`.

### Explore Alternatives

The config includes multiple colorschemes. Try them:

```vim
:colorscheme tokyonight-storm
:colorscheme catppuccin-mocha
:colorscheme gruvbox
```

## LSP Server Management

### Check What's Installed

```vim
:ALEInfo    " Show detected linters and fixers for current file
```

### Re-run Installation Script

The installation script is idempotent - safe to run multiple times:

```bash
cd ~/dotfiles/vim
./install-lsp-servers.sh
```

It will skip already-installed tools and only install what's missing.

### Update Tools

```bash
# Update Node.js LSP servers
npm update -g pyright typescript-language-server bash-language-server yaml-language-server

# Update Go tools
go install golang.org/x/tools/gopls@latest

# Update Rust components
rustup update
```

### Complete Installation Workflow

```bash
# 1. Bootstrap system tools
cd ~/dotfiles
./bootstrap.sh

# 2. Install Vim config
stow vim

# 3. Install LSP servers (optional but recommended)
cd vim
./install-lsp-servers.sh

# 4. Open Vim (plugins auto-install)
vim

# Done! 🎉
```

Happy Vimming! 🎉
