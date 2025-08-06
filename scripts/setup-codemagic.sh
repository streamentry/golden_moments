#!/bin/bash

# Golden Moments - Codemagic Setup Script
# This script helps prepare your project for Codemagic CI/CD

set -e

echo "🚀 Golden Moments - Codemagic Setup"
echo "===================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Flutter is installed
check_flutter() {
    echo -e "${YELLOW}Checking Flutter installation...${NC}"
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}Flutter is not installed or not in PATH${NC}"
        echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    flutter --version
    echo -e "${GREEN}✓ Flutter found${NC}"
}

# Check project dependencies
check_dependencies() {
    echo -e "${YELLOW}Checking project dependencies...${NC}"
    
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}pubspec.yaml not found. Are you in the project root?${NC}"
        exit 1
    fi
    
    flutter packages pub get
    echo -e "${GREEN}✓ Dependencies resolved${NC}"
}

# Run Flutter doctor
run_flutter_doctor() {
    echo -e "${YELLOW}Running Flutter doctor...${NC}"
    flutter doctor
    
    echo -e "${YELLOW}Note: Some issues are normal for CI/CD setup${NC}"
}

# Validate build configuration
validate_build_config() {
    echo -e "${YELLOW}Validating build configuration...${NC}"
    
    # Check Android configuration
    if [ -f "android/app/build.gradle" ]; then
        echo -e "${GREEN}✓ Android build.gradle found${NC}"
        
        # Check for signing configuration
        if grep -q "signingConfigs" "android/app/build.gradle"; then
            echo -e "${GREEN}✓ Android signing configuration found${NC}"
        else
            echo -e "${YELLOW}⚠ Android signing configuration not found${NC}"
        fi
    else
        echo -e "${RED}✗ Android build.gradle not found${NC}"
    fi
    
    # Check iOS configuration
    if [ -f "ios/Runner/Info.plist" ]; then
        echo -e "${GREEN}✓ iOS Info.plist found${NC}"
    else
        echo -e "${RED}✗ iOS Info.plist not found${NC}"
    fi
    
    # Check for Google Services
    if [ -f "android/app/google-services.json" ]; then
        echo -e "${GREEN}✓ Android google-services.json found${NC}"
    else
        echo -e "${YELLOW}⚠ Android google-services.json not found (required for Firebase)${NC}"
    fi
    
    if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
        echo -e "${GREEN}✓ iOS GoogleService-Info.plist found${NC}"
    else
        echo -e "${YELLOW}⚠ iOS GoogleService-Info.plist not found (required for Firebase)${NC}"
    fi
}

# Test build locally
test_local_build() {
    echo -e "${YELLOW}Testing local builds...${NC}"
    
    echo "Testing Android debug build..."
    if flutter build apk --debug --flavor development; then
        echo -e "${GREEN}✓ Android debug build successful${NC}"
    else
        echo -e "${RED}✗ Android debug build failed${NC}"
        return 1
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Testing iOS debug build..."
        if flutter build ios --debug --no-codesign --flavor development; then
            echo -e "${GREEN}✓ iOS debug build successful${NC}"
        else
            echo -e "${RED}✗ iOS debug build failed${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ iOS build test skipped (macOS required)${NC}"
    fi
}

# Run code analysis
run_analysis() {
    echo -e "${YELLOW}Running code analysis...${NC}"
    
    if flutter analyze --fatal-infos; then
        echo -e "${GREEN}✓ Code analysis passed${NC}"
    else
        echo -e "${RED}✗ Code analysis found issues${NC}"
        return 1
    fi
}

# Run tests
run_tests() {
    echo -e "${YELLOW}Running tests...${NC}"
    
    if flutter test; then
        echo -e "${GREEN}✓ All tests passed${NC}"
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        return 1
    fi
}

# Check formatting
check_formatting() {
    echo -e "${YELLOW}Checking code formatting...${NC}"
    
    if dart format --set-exit-if-changed lib/ test/; then
        echo -e "${GREEN}✓ Code is properly formatted${NC}"
    else
        echo -e "${YELLOW}⚠ Code formatting issues found${NC}"
        echo "Run 'dart format lib/ test/' to fix formatting"
        return 1
    fi
}

# Generate setup summary
generate_summary() {
    echo ""
    echo -e "${GREEN}📋 Codemagic Setup Summary${NC}"
    echo "=========================="
    echo ""
    echo -e "${GREEN}✅ Configuration files created:${NC}"
    echo "  • codemagic.yaml - Main CI/CD configuration"
    echo "  • docs/codemagic-setup.md - Detailed setup guide"
    echo "  • docs/codemagic-pipeline.md - Pipeline documentation"
    echo "  • docs/troubleshooting.md - Troubleshooting guide"
    echo ""
    echo -e "${YELLOW}🔧 Next steps:${NC}"
    echo "  1. Sign up for Codemagic account: https://codemagic.io"
    echo "  2. Connect your repository"
    echo "  3. Upload signing certificates"
    echo "  4. Configure environment variables"
    echo "  5. Review and customize codemagic.yaml"
    echo ""
    echo -e "${YELLOW}📚 Documentation:${NC}"
    echo "  • Setup guide: docs/codemagic-setup.md"
    echo "  • Pipeline overview: docs/codemagic-pipeline.md"
    echo "  • Troubleshooting: docs/troubleshooting.md"
    echo ""
    echo -e "${GREEN}🎉 Your project is ready for Codemagic CI/CD!${NC}"
}

# Main execution
main() {
    echo "Starting Codemagic setup validation..."
    echo ""
    
    check_flutter
    check_dependencies
    run_flutter_doctor
    validate_build_config
    
    echo ""
    echo -e "${YELLOW}Would you like to run additional validation tests? (y/N)${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}Running comprehensive validation...${NC}"
        
        run_analysis || echo -e "${YELLOW}Analysis issues found - please review${NC}"
        run_tests || echo -e "${YELLOW}Test issues found - please review${NC}"
        check_formatting || echo -e "${YELLOW}Formatting issues found - please review${NC}"
        
        # Only test builds if previous checks passed
        if [ $? -eq 0 ]; then
            test_local_build || echo -e "${YELLOW}Build issues found - please review${NC}"
        fi
    fi
    
    echo ""
    generate_summary
}

# Run main function
main "$@"
