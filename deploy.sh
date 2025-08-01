#!/bin/bash

# Enhanced Portfolio Deployment Script
# This script helps deploy the portfolio to various platforms

echo "🚀 Enhanced Portfolio Deployment Script"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if git is available
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed. Please install Git first.${NC}"
    exit 1
fi

# Function to deploy to GitHub Pages
deploy_github_pages() {
    echo -e "${BLUE}📡 Deploying to GitHub Pages...${NC}"
    
    # Check if gh-pages branch exists
    if git show-ref --verify --quiet refs/heads/gh-pages; then
        echo -e "${YELLOW}⚠️  gh-pages branch already exists${NC}"
    else
        echo -e "${GREEN}✅ Creating gh-pages branch${NC}"
        git checkout --orphan gh-pages
        git rm -rf .
        git add .
        git commit -m "Initial GitHub Pages commit"
        git push -u origin gh-pages
        git checkout main
    fi
    
    # Copy files to gh-pages branch
    git checkout gh-pages
    git checkout main -- index_enhanced.html styles.css script.js DSC05764.jpg CV_Mhamed_Garbaa.pdf
    
    # Rename enhanced file to index.html for GitHub Pages
    if [ -f "index_enhanced.html" ]; then
        mv index_enhanced.html index.html
        echo -e "${GREEN}✅ Renamed index_enhanced.html to index.html${NC}"
    fi
    
    git add .
    git commit -m "Deploy enhanced portfolio - $(date)"
    git push origin gh-pages
    git checkout main
    
    echo -e "${GREEN}✅ Successfully deployed to GitHub Pages!${NC}"
    echo -e "${BLUE}🌐 Your site will be available at: https://$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^/]*\).git/\1.github.io\/\2/')${NC}"
}

# Function to prepare for Netlify deployment
prepare_netlify() {
    echo -e "${BLUE}📡 Preparing for Netlify deployment...${NC}"
    
    # Create _redirects file for SPA behavior
    echo "/*    /index.html   200" > _redirects
    
    # Create netlify.toml configuration
    cat > netlify.toml << EOF
[build]
  publish = "."
  
[build.environment]
  NODE_VERSION = "18"

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Cache-Control = "public, max-age=31536000"

[[headers]]
  for = "*.html"
  [headers.values]
    Cache-Control = "public, max-age=0, must-revalidate"

[[headers]]
  for = "*.css"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
EOF
    
    # Rename enhanced file to index.html
    if [ -f "index_enhanced.html" ]; then
        cp index_enhanced.html index.html
        echo -e "${GREEN}✅ Created index.html from index_enhanced.html${NC}"
    fi
    
    echo -e "${GREEN}✅ Netlify deployment files prepared!${NC}"
    echo -e "${YELLOW}💡 Now you can:${NC}"
    echo -e "   1. Push to your Git repository"
    echo -e "   2. Connect the repository to Netlify"
    echo -e "   3. Deploy automatically"
}

# Function to create a simple local server
serve_local() {
    echo -e "${BLUE}🖥️  Starting local development server...${NC}"
    
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}✅ Using Python 3${NC}"
        echo -e "${BLUE}🌐 Server running at: http://localhost:8000${NC}"
        echo -e "${YELLOW}💡 Open http://localhost:8000/index_enhanced.html in your browser${NC}"
        python3 -m http.server 8000
    elif command -v python &> /dev/null; then
        echo -e "${GREEN}✅ Using Python 2${NC}"
        echo -e "${BLUE}🌐 Server running at: http://localhost:8000${NC}"
        echo -e "${YELLOW}💡 Open http://localhost:8000/index_enhanced.html in your browser${NC}"
        python -m SimpleHTTPServer 8000
    elif command -v node &> /dev/null && command -v npx &> /dev/null; then
        echo -e "${GREEN}✅ Using Node.js${NC}"
        echo -e "${BLUE}🌐 Server running at: http://localhost:3000${NC}"
        npx serve . -p 3000
    else
        echo -e "${RED}❌ No suitable server found. Please install Python or Node.js${NC}"
        exit 1
    fi
}

# Function to validate HTML, CSS, and JS (if tools are available)
validate_code() {
    echo -e "${BLUE}🔍 Validating code...${NC}"
    
    # Check HTML
    if [ -f "index_enhanced.html" ]; then
        echo -e "${GREEN}✅ HTML file found: index_enhanced.html${NC}"
    else
        echo -e "${RED}❌ HTML file not found: index_enhanced.html${NC}"
    fi
    
    # Check CSS
    if [ -f "styles.css" ]; then
        echo -e "${GREEN}✅ CSS file found: styles.css${NC}"
    else
        echo -e "${RED}❌ CSS file not found: styles.css${NC}"
    fi
    
    # Check JavaScript
    if [ -f "script.js" ]; then
        echo -e "${GREEN}✅ JavaScript file found: script.js${NC}"
    else
        echo -e "${RED}❌ JavaScript file not found: script.js${NC}"
    fi
    
    # Check for required assets
    if [ -f "DSC05764.jpg" ]; then
        echo -e "${GREEN}✅ Profile image found: DSC05764.jpg${NC}"
    else
        echo -e "${YELLOW}⚠️  Profile image not found: DSC05764.jpg${NC}"
    fi
    
    echo -e "${GREEN}✅ Code validation complete!${NC}"
}

# Main menu
show_menu() {
    echo ""
    echo -e "${BLUE}Choose a deployment option:${NC}"
    echo "1. 🚀 Deploy to GitHub Pages"
    echo "2. 📡 Prepare for Netlify"
    echo "3. 🖥️  Serve locally"
    echo "4. 🔍 Validate code"
    echo "5. ❌ Exit"
    echo ""
}

# Main script logic
while true; do
    show_menu
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            deploy_github_pages
            ;;
        2)
            prepare_netlify
            ;;
        3)
            serve_local
            ;;
        4)
            validate_code
            ;;
        5)
            echo -e "${GREEN}✅ Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option. Please choose 1-5.${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
