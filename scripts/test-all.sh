#!/usr/bin/env bash
# Local CI Test Runner - Run all CI checks locally before pushing
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

FAILED=0
PASSED=0

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${YELLOW}▶${NC} Running: $test_name"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASSED${NC}: $test_name\n"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}: $test_name\n"
        ((FAILED++))
        return 1
    fi
}

print_header "🔍 NixOS Configuration - Local CI Runner"

echo "This script runs all CI checks locally before pushing."
echo "It may take several minutes depending on your machine."
echo ""

# Test 1: Sanity Checks
print_header "1️⃣  Sanity Checks"
run_test "Flake and structure validation" "./scripts/ci-checks.sh" || true

# Test 2: Flake Check
print_header "2️⃣  Nix Flake Check"
run_test "Full flake validation" "nix flake check --show-trace" || true

# Test 3: Build Configurations
print_header "3️⃣  Build Configurations"
run_test "Build macbook config" "./scripts/ci-build.sh macbook" || true
run_test "Build dell config" "./scripts/ci-build.sh dell" || true

# Test 4: Evaluate Devshells
print_header "4️⃣  Evaluate Devshells"
run_test "Evaluate all devshells" "./scripts/ci-eval.sh" || true

# Test 5: Format Check
print_header "5️⃣  Format Check"
run_test "Nix format validation" "nix fmt -- --check ." || true

# Summary
print_header "📊 Test Summary"

TOTAL=$((PASSED + FAILED))

echo -e "Total tests: ${BLUE}$TOTAL${NC}"
echo -e "Passed:      ${GREEN}$PASSED${NC}"
echo -e "Failed:      ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✅ All tests passed! Safe to push. 🚀${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  ❌ Some tests failed. Fix issues before pushing.${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Check logs in /tmp/ for details:"
    echo "  - /tmp/flake-check.log"
    echo "  - /tmp/build-macbook.log"
    echo "  - /tmp/build-dell.log"
    exit 1
fi
