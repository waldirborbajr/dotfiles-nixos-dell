#!/bin/bash
# Script to validate the DevContainer/Codespace environment
# Usage: bash .devcontainer/validate.sh

set -e

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_test() {
    echo -e "🔍 Testing: $1"
}

print_success() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  INFO${NC}: $1"
}

# Banner
clear
echo -e "${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════╗
║                                                  ║
║     NixOS Config DevContainer Validator          ║
║                                                  ║
╚══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# 1. Detect environment
print_header "1️⃣  Environment Detection"

if [ -n "$CODESPACES" ]; then
    print_success "Running on GitHub Codespaces"
    print_info "Codespace name: $CODESPACE_NAME"
elif [ -n "$REMOTE_CONTAINERS" ] || [ -n "$VSCODE_REMOTE_CONTAINERS_SESSION" ]; then
    print_success "Running in DevContainer"
else
    print_warning "Codespace/DevContainer not detected (may be a local environment)"
fi

print_info "User: $(whoami)"
print_info "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
print_info "Architecture: $(uname -m)"

# 2. Validate Nix
print_header "2️⃣  Nix Validation"

print_test "Nix installed"
if command -v nix &> /dev/null; then
    NIX_VERSION=$(nix --version)
    print_success "Nix found: $NIX_VERSION"
else
    print_fail "Nix not found on PATH"
    echo -e "\n${RED}CRITICAL ERROR: Nix not installed. Run: bash .devcontainer/setup.sh${NC}\n"
    exit 1
fi

print_test "Experimental features (flakes)"
if nix flake --help &> /dev/null; then
    print_success "Flakes enabled"
else
    print_fail "Flakes not enabled"
fi

print_test "Nix configuration"
if [ -f ~/.config/nix/nix.conf ]; then
    print_success "Configuration file exists"
    if grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf; then
        print_success "Flakes configured in nix.conf"
    else
        print_warning "Flakes not found in nix.conf"
    fi
else
    print_warning "~/.config/nix/nix.conf does not exist"
fi

# 3. Validate Git
print_header "3️⃣  Git and GitHub CLI Validation"

print_test "Git installed"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_success "$GIT_VERSION"
else
    print_fail "Git not found"
fi

print_test "GitHub CLI installed"
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -n1)
    print_success "$GH_VERSION"
else
    print_warning "GitHub CLI not found (non-critical)"
fi

# 4. Validate Flake
print_header "4️⃣  NixOS Flake Validation"

print_test "flake.nix file exists"
if [ -f flake.nix ]; then
    print_success "flake.nix found"
else
    print_fail "flake.nix not found in the current directory"
fi

print_test "Flake metadata"
if timeout 30 nix flake metadata . &> /dev/null; then
    print_success "Flake metadata loaded successfully"
else
    print_fail "Error loading flake metadata (timeout or error)"
fi

print_test "Syntax check"
if timeout 60 nix flake check --no-build &> /dev/null 2>&1; then
    print_success "Flake check passed (no build)"
else
    print_warning "Flake check failed or took too long (may be normal on first run)"
fi

# 5. Validate Devshells
print_header "5️⃣  Devshell Validation"

print_test "Listing available devshells"
DEVSHELLS=$(nix flake show . 2>&1 | grep -E "devShells\." | wc -l)
if [ "$DEVSHELLS" -gt 0 ]; then
    print_success "Found $DEVSHELLS devshells"
    echo -e "\n${BLUE}Available devshells:${NC}"
    nix flake show . 2>&1 | grep "devShells\." | head -n 10 | sed 's/^/  /'
else
    print_warning "No devshells found (may take longer on the first run)"
fi

print_test "Basic devshell entry test"
if timeout 60 nix develop .#rust --command echo "OK" &> /dev/null; then
    print_success "Rust devshell accessible"
elif timeout 60 nix develop .#go --command echo "OK" &> /dev/null; then
    print_success "Go devshell accessible"
elif timeout 60 nix develop .#nix-dev --command echo "OK" &> /dev/null; then
    print_success "Nix-dev devshell accessible"
else
    print_warning "Could not access devshells (may take longer on the first build)"
fi

# 6. Validate direnv
print_header "6️⃣  direnv Validation"

print_test "direnv installed"
if command -v direnv &> /dev/null; then
    print_success "direnv found"
else
    print_warning "direnv not installed (optional but recommended)"
fi

print_test "direnv hook in bashrc"
if grep -q "direnv hook bash" ~/.bashrc; then
    print_success "direnv hook configured"
else
    print_warning "direnv hook not found in ~/.bashrc"
fi

# 7. Validate optional tools
print_header "7️⃣  Optional Tools"

print_test "nixpkgs-fmt (formatter)"
if nix-shell -p nixpkgs-fmt --run "nixpkgs-fmt --version" &> /dev/null; then
    print_success "nixpkgs-fmt available"
else
    print_warning "nixpkgs-fmt not available (non-critical)"
fi

print_test "nil (language server)"
if command -v nil &> /dev/null; then
    print_success "nil found"
else
    print_warning "nil not installed (VS Code extension can install)"
fi

# 8. Validate project-specific configuration
print_header "8️⃣  Project NixOS Configuration"

print_test "Hosts defined in flake"
HOSTS=$(grep -E "nixosConfigurations\." flake.nix | grep -oP '(?<=\.)[\w-]+(?=\s*=)' 2>/dev/null || true)
if [ -n "$HOSTS" ]; then
    print_success "Hosts found: $(echo $HOSTS | tr '\n' ' ')"
else
    print_warning "No hosts defined in nixosConfigurations"
fi

print_test "Important directories"
for DIR in "hosts" "modules" "hardware"; do
    if [ -d "$DIR" ]; then
        print_success "Directory $DIR/ exists"
    else
        print_warning "Directory $DIR/ not found"
    fi
done

# 9. Performance and cache
print_header "9️⃣  Performance and Cache"

print_test "Disk space"
DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}')
print_info "Disk usage: $DISK_USAGE"

print_test "Nix store"
if [ -d /nix/store ]; then
    STORE_SIZE=$(du -sh /nix/store 2>/dev/null | cut -f1)
    print_success "Nix store exists (size: ${STORE_SIZE:-unknown})"
else
    print_warning "Nix store not found at /nix/store"
fi

# 10. Final summary
print_header "📊 Validation Summary"

TOTAL=$((PASSED + FAILED + WARNINGS))
PASS_RATE=$((PASSED * 100 / TOTAL))

echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Total tests: $TOTAL"
echo -e "Success rate: ${PASS_RATE}%\n"

# Final status
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 DevContainer validated successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${BLUE}📚 Next steps:${NC}"
    echo -e "  • List outputs: ${YELLOW}nix flake show${NC}"
    echo -e "  • Enter devshell: ${YELLOW}nix develop .#rust${NC}"
    echo -e "  • Check configuration: ${YELLOW}nix flake check${NC}"
    echo -e "  • Update inputs: ${YELLOW}nix flake update${NC}\n"
    
    exit 0
elif [ $FAILED -le 2 ] && [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  DevContainer functional with warnings${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "Consider reviewing the warnings above.\n"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ Validation failed - fix the errors above${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${BLUE}💡 Troubleshooting tips:${NC}"
    echo -e "  • Run setup: ${YELLOW}bash .devcontainer/setup.sh${NC}"
    echo -e "  • Reload shell: ${YELLOW}source ~/.bashrc${NC}"
    echo -e "  • See README: ${YELLOW}cat .devcontainer/README.md${NC}\n"
    
    exit 1
fi
