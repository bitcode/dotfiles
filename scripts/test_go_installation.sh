#!/bin/bash

# Test Go Installation on macOS
# This script provides step-by-step manual verification commands for macOS Go installation

set -e

echo "🐹 Go Installation Test Script for macOS"
echo "========================================"
echo ""

# Function to print status with colors
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS") echo "✅ $message" ;;
        "FAIL") echo "❌ $message" ;;
        "WARN") echo "⚠️  $message" ;;
        "INFO") echo "ℹ️  $message" ;;
    esac
}

echo "1. DIAGNOSTIC ANALYSIS"
echo "======================"

# Check if Go is in PATH
echo ""
echo "Checking if Go is available in PATH:"
if command -v go >/dev/null 2>&1; then
    GO_VERSION=$(go version)
    print_status "PASS" "Go found in PATH: $GO_VERSION"
    GO_PATH=$(which go)
    print_status "INFO" "Go binary location: $GO_PATH"
else
    print_status "FAIL" "Go not found in PATH"
fi

# Check Homebrew installation
echo ""
echo "Checking Homebrew Go installation:"
if brew list go >/dev/null 2>&1; then
    print_status "PASS" "Go installed via Homebrew"
    HOMEBREW_GO_VERSION=$(brew list --versions go)
    print_status "INFO" "Homebrew Go version: $HOMEBREW_GO_VERSION"
else
    print_status "WARN" "Go not installed via Homebrew"
fi

# Check standard Go locations
echo ""
echo "Checking standard Go installation locations:"

locations=(
    "/usr/local/go/bin/go"
    "/opt/homebrew/bin/go"
    "/usr/local/bin/go"
)

for location in "${locations[@]}"; do
    if [[ -f "$location" ]]; then
        VERSION=$($location version 2>/dev/null || echo "Unable to get version")
        print_status "PASS" "Found Go at $location: $VERSION"
    else
        print_status "INFO" "No Go found at $location"
    fi
done

# Check PATH environment
echo ""
echo "Current PATH environment:"
echo "$PATH" | tr ':' '\n' | grep -E "(go|homebrew|local)" || print_status "WARN" "No Go-related paths found in PATH"

echo ""
echo "2. INSTALLATION VERIFICATION"
echo "============================"

# Test Go functionality
echo ""
echo "Testing Go functionality:"
if command -v go >/dev/null 2>&1; then
    # Test go version
    print_status "INFO" "Testing 'go version' command..."
    go version
    
    # Test go env
    print_status "INFO" "Testing 'go env' command..."
    echo "GOROOT: $(go env GOROOT)"
    echo "GOPATH: $(go env GOPATH)"
    echo "GOOS: $(go env GOOS)"
    echo "GOARCH: $(go env GOARCH)"
    
    # Test simple Go program
    print_status "INFO" "Testing simple Go program compilation..."
    TEMP_DIR=$(mktemp -d)
    cat > "$TEMP_DIR/hello.go" << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
EOF
    
    if cd "$TEMP_DIR" && go run hello.go >/dev/null 2>&1; then
        print_status "PASS" "Go can compile and run programs"
    else
        print_status "FAIL" "Go cannot compile and run programs"
    fi
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
else
    print_status "FAIL" "Cannot test Go functionality - Go not available"
fi

echo ""
echo "3. GO PACKAGES VERIFICATION"
echo "==========================="

if command -v go >/dev/null 2>&1; then
    # Check if go install works
    print_status "INFO" "Testing 'go install' functionality..."
    
    # Test installing a simple package
    if go install golang.org/x/example/hello@latest >/dev/null 2>&1; then
        print_status "PASS" "go install works correctly"
        
        # Check if the binary was installed
        GOBIN=$(go env GOPATH)/bin
        if [[ -f "$GOBIN/hello" ]]; then
            print_status "PASS" "Go packages install to correct location: $GOBIN"
        else
            print_status "WARN" "Go package binary not found in expected location"
        fi
    else
        print_status "FAIL" "go install does not work"
    fi
    
    # Check Go modules functionality
    print_status "INFO" "Testing Go modules functionality..."
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    if go mod init test-module >/dev/null 2>&1; then
        print_status "PASS" "Go modules work correctly"
    else
        print_status "FAIL" "Go modules do not work"
    fi
    
    # Clean up
    rm -rf "$TEMP_DIR"
else
    print_status "FAIL" "Cannot test Go packages - Go not available"
fi

echo ""
echo "4. MANUAL VERIFICATION COMMANDS"
echo "==============================="

echo ""
echo "Run these commands manually to verify Go installation:"
echo ""
echo "# Check Go version:"
echo "go version"
echo ""
echo "# Check Go environment:"
echo "go env"
echo ""
echo "# Check Go installation path:"
echo "which go"
echo ""
echo "# Test Go compilation:"
echo "echo 'package main; import \"fmt\"; func main() { fmt.Println(\"Hello, Go!\") }' > test.go"
echo "go run test.go"
echo "rm test.go"
echo ""
echo "# Test Go package installation:"
echo "go install golang.org/x/example/hello@latest"
echo "\$(go env GOPATH)/bin/hello"
echo ""

echo ""
echo "5. TROUBLESHOOTING STEPS"
echo "========================"

echo ""
echo "If Go is not working, try these steps:"
echo ""
echo "1. Install via Homebrew:"
echo "   brew install go"
echo ""
echo "2. Add Go to PATH (if manually installed):"
echo "   echo 'export PATH=\"/usr/local/go/bin:\$PATH\"' >> ~/.zshrc"
echo "   source ~/.zshrc"
echo ""
echo "3. Verify Homebrew Go location:"
echo "   ls -la /opt/homebrew/bin/go  # Apple Silicon"
echo "   ls -la /usr/local/bin/go     # Intel"
echo ""
echo "4. Check for conflicting installations:"
echo "   brew uninstall go"
echo "   sudo rm -rf /usr/local/go"
echo "   brew install go"
echo ""

echo ""
echo "🐹 Go Installation Test Complete!"
echo "================================="
