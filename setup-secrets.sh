#!/usr/bin/env bash
# setup-secrets.sh
# Automated SOPS secrets setup for NixOS
# This script sets up SOPS encryption and configures SSH key secrets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}SOPS Secrets Setup Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Generate Age key from SSH key
echo -e "${YELLOW}Step 1/6: Generating Age key from SSH key...${NC}"
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo -e "${RED}Error: SSH key ~/.ssh/id_ed25519 not found!${NC}"
    echo "Please generate an SSH key first: ssh-keygen -t ed25519"
    exit 1
fi

mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
echo -e "${GREEN}✓ Age key generated and saved to ~/.config/sops/age/keys.txt${NC}"
echo ""

# Step 2: Get public Age key
echo -e "${YELLOW}Step 2/6: Getting your public Age key...${NC}"
AGE_PUBLIC_KEY=$(ssh-to-age < ~/.ssh/id_ed25519.pub)
echo -e "${GREEN}✓ Your Age public key: ${BLUE}${AGE_PUBLIC_KEY}${NC}"
echo ""

# Step 3: Create .sops.yaml with your public key
echo -e "${YELLOW}Step 3/6: Creating .sops.yaml configuration...${NC}"
if [ -f .sops.yaml ]; then
    echo -e "${YELLOW}Warning: .sops.yaml already exists. Creating backup...${NC}"
    cp .sops.yaml .sops.yaml.backup
fi

cat > .sops.yaml << EOF
# .sops.yaml - SOPS configuration file
# See SECRETS-MANAGEMENT.md for complete documentation

keys:
  # Your Age public key (auto-generated from SSH key)
  - &admin_borba ${AGE_PUBLIC_KEY}

creation_rules:
  # Common secrets - encrypted with admin key
  - path_regex: secrets/common/[^/]+\\.yaml\$
    key_groups:
    - age:
      - *admin_borba
  
  # MacBook-specific secrets
  - path_regex: secrets/macbook/[^/]+\\.yaml\$
    key_groups:
    - age:
      - *admin_borba
  
  # Dell-specific secrets
  - path_regex: secrets/dell/[^/]+\\.yaml\$
    key_groups:
    - age:
      - *admin_borba
EOF

echo -e "${GREEN}✓ .sops.yaml created with your Age public key${NC}"
echo ""

# Step 4: Create secrets file with SSH keys
echo -e "${YELLOW}Step 4/6: Creating encrypted secrets file with your SSH keys...${NC}"

# Create secrets directory if it doesn't exist
mkdir -p secrets/common

# Read SSH keys
echo -e "${BLUE}Reading your SSH keys from ~/.ssh/${NC}"
SSH_PRIVATE_KEY=$(cat ~/.ssh/id_ed25519)
SSH_PUBLIC_KEY=$(cat ~/.ssh/id_ed25519.pub)

# Create temporary unencrypted file with proper YAML format
cat > secrets/common/secrets.yaml << 'EOF'
ssh_private_key: |
EOF

# Append private key with proper indentation
awk '{print "  " $0}' ~/.ssh/id_ed25519 >> secrets/common/secrets.yaml

# Append public key
echo "" >> secrets/common/secrets.yaml
echo -n "ssh_public_key: " >> secrets/common/secrets.yaml
cat ~/.ssh/id_ed25519.pub >> secrets/common/secrets.yaml

echo -e "${GREEN}✓ SSH keys added to secrets file${NC}"
echo ""

# Encrypt the file with SOPS
echo -e "${BLUE}Encrypting secrets file with SOPS...${NC}"
sops --encrypt --in-place secrets/common/secrets.yaml

echo -e "${GREEN}✓ Secrets file encrypted successfully${NC}"
echo ""

# Optional: Show encrypted content to verify
echo -e "${BLUE}Verifying encryption (showing encrypted content):${NC}"
head -5 secrets/common/secrets.yaml
echo "..."
echo ""

# Step 5: Enable secrets module in macbook.nix
echo -e "${YELLOW}Step 5/6: Enabling secrets module in hosts/macbook.nix...${NC}"

# Check if the line is already uncommented
if grep -q "^  system-config.secrets.enable = true;" hosts/macbook.nix; then
    echo -e "${GREEN}✓ Secrets module already enabled${NC}"
elif grep -q "^  # system-config.secrets.enable = true;" hosts/macbook.nix; then
    # Uncomment the line
    sed -i 's/^  # system-config.secrets.enable = true;/  system-config.secrets.enable = true;/' hosts/macbook.nix
    echo -e "${GREEN}✓ Secrets module enabled in hosts/macbook.nix${NC}"
else
    echo -e "${RED}Warning: Could not find secrets.enable line in hosts/macbook.nix${NC}"
    echo -e "${YELLOW}Please manually uncomment: system-config.secrets.enable = true;${NC}"
fi
echo ""

# Step 6: Rebuild system
echo -e "${YELLOW}Step 6/6: Committing changes and rebuilding NixOS system...${NC}"

# Add and commit changes
echo -e "${BLUE}Adding changes to git...${NC}"
git add .sops.yaml secrets/common/secrets.yaml hosts/macbook.nix

echo -e "${BLUE}Committing changes...${NC}"
git commit -m "feat: add encrypted SSH keys with SOPS

- Configure SOPS with Age encryption
- Add encrypted SSH private and public keys
- Enable secrets module in macbook.nix
- Auto-restore SSH keys on rebuild"

echo -e "${GREEN}✓ Changes committed${NC}"
echo ""

echo -e "${BLUE}Rebuilding NixOS system...${NC}"
echo -e "${BLUE}This will apply all changes and deploy your secrets.${NC}"
echo ""

sudo nixos-rebuild switch --flake .#macbook

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Your SSH keys are now encrypted and will be restored on every rebuild.${NC}"
echo ""
echo -e "${YELLOW}Important reminders:${NC}"
echo -e "  ${RED}✗${NC} Never commit: ${BLUE}.sops.yaml${NC} (use .sops.yaml.example instead)"
echo -e "  ${RED}✗${NC} Never commit: ${BLUE}~/.config/sops/age/keys.txt${NC}"
echo -e "  ${GREEN}✓${NC} Safe to commit: ${BLUE}secrets/common/secrets.yaml${NC} (it's encrypted!)"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  ${BLUE}sops secrets/common/secrets.yaml${NC}     - Edit secrets"
echo -e "  ${BLUE}sops -d secrets/common/secrets.yaml${NC}  - View decrypted secrets"
echo -e "  ${BLUE}ls -la ~/.ssh/${NC}                       - Check deployed SSH keys"
echo ""
