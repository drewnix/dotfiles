#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════╗
# ║ Steampipe Plugin Installation Script                        ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Installs recommended Steampipe plugins for cloud-native DevOps
# Run this after stowing steampipe dotfiles

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Steampipe Plugin Installation                      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if steampipe is installed
if ! command -v steampipe &> /dev/null; then
    echo -e "${YELLOW}⚠️  Steampipe not installed. Please run bootstrap.sh first.${NC}"
    exit 1
fi

# Start steampipe service if not running
echo -e "${BLUE}==>${NC} Checking Steampipe service status..."
if ! steampipe service status &> /dev/null; then
    echo -e "${BLUE}==>${NC} Starting Steampipe service..."
    steampipe service start
fi

echo ""
echo -e "${BLUE}==>${NC} Installing Steampipe plugins..."
echo ""

# Install plugins from config files
# This reads all .spc files and installs referenced plugins
steampipe plugin install

echo ""
echo -e "${GREEN}==>${NC} Plugin installation complete!"
echo ""

# Show installed plugins
echo -e "${BLUE}Installed plugins:${NC}"
steampipe plugin list

echo ""
echo -e "${GREEN}✅ Steampipe setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Set GITHUB_TOKEN environment variable for GitHub plugin"
echo "  2. Configure AWS credentials (aws configure or aws-vault)"
echo "  3. Configure GCP credentials (gcloud auth login)"
echo "  4. Test queries:"
echo "     - sp-shell              # Interactive shell"
echo "     - sp-aws-security       # Run AWS security audit"
echo "     - sp-k8s-security       # Run K8s security audit"
echo "     - sp-inventory          # View infrastructure inventory"
echo ""
echo "Documentation:"
echo "  - Query library: ~/.steampipe/config/queries/"
echo "  - Config files: ~/.steampipe/config/*.spc"
echo "  - Steampipe docs: https://steampipe.io/docs"
echo ""
