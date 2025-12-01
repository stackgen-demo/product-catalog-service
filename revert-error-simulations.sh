#!/bin/bash

# Script to revert error simulation branches back to main
# Usage: ./revert-error-simulations.sh [branch-name]
#   If branch-name is provided, only that branch will be reverted
#   If no branch-name is provided, all error simulation branches will be reverted

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error simulation branches
BRANCHES=(
    "feature/nil-pointer-searchproducts"
    "feature/index-out-of-bounds"
    "feature/memory-exhaustion"
)

# Function to revert a branch to main
revert_branch() {
    local branch=$1
    
    echo -e "${YELLOW}🔄 Reverting branch: ${branch}${NC}"
    
    # Check if branch exists
    if ! git show-ref --verify --quiet refs/heads/"$branch"; then
        echo -e "${RED}❌ Branch ${branch} does not exist locally${NC}"
        return 1
    fi
    
    # Get current branch
    CURRENT_BRANCH=$(git branch --show-current)
    
    # Checkout the branch to revert
    git checkout "$branch" 2>/dev/null || {
        echo -e "${RED}❌ Failed to checkout ${branch}${NC}"
        return 1
    }
    
    # Get the main branch commit hash (the commit before error simulation)
    MAIN_COMMIT=$(git merge-base main "$branch")
    
    # Reset the branch to main
    echo -e "${YELLOW}   Resetting ${branch} to main (commit: ${MAIN_COMMIT:0:7})${NC}"
    git reset --hard main
    
    # Force push to update remote
    echo -e "${YELLOW}   Pushing reverted branch to remote...${NC}"
    if git push origin "$branch" --force-with-lease 2>/dev/null; then
        echo -e "${GREEN}✅ Successfully reverted ${branch}${NC}"
    else
        echo -e "${RED}❌ Failed to push ${branch}. You may need to push manually.${NC}"
        echo -e "${YELLOW}   Run: git push origin ${branch} --force-with-lease${NC}"
    fi
    
    # Return to original branch if it exists
    if [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "$branch" ]; then
        git checkout "$CURRENT_BRANCH" 2>/dev/null || true
    fi
    
    echo ""
}

# Function to show current status
show_status() {
    echo -e "${YELLOW}📊 Current branch status:${NC}"
    git branch -a | grep -E "(feature/nil-pointer|feature/index-out|feature/memory)" || echo "No error simulation branches found"
    echo ""
}

# Main execution
main() {
    echo -e "${GREEN}🔄 Error Simulation Reverter${NC}"
    echo -e "${GREEN}============================${NC}"
    echo ""
    
    # Ensure we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}❌ Not a git repository${NC}"
        exit 1
    fi
    
    # Fetch latest from remote
    echo -e "${YELLOW}📥 Fetching latest from remote...${NC}"
    git fetch origin main 2>/dev/null || echo -e "${YELLOW}⚠️  Could not fetch from remote. Continuing with local main...${NC}"
    echo ""
    
    # If specific branch provided, revert only that branch
    if [ -n "$1" ]; then
        if [[ " ${BRANCHES[@]} " =~ " ${1} " ]]; then
            revert_branch "$1"
        else
            echo -e "${RED}❌ Invalid branch: ${1}${NC}"
            echo -e "${YELLOW}Valid branches:${NC}"
            for branch in "${BRANCHES[@]}"; do
                echo -e "  - ${branch}"
            done
            exit 1
        fi
    else
        # Revert all branches
        echo -e "${YELLOW}⚠️  This will revert ALL error simulation branches to main${NC}"
        echo -e "${YELLOW}Branches to revert:${NC}"
        for branch in "${BRANCHES[@]}"; do
            echo -e "  - ${branch}"
        done
        echo ""
        read -p "Continue? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Aborted${NC}"
            exit 0
        fi
        echo ""
        
        for branch in "${BRANCHES[@]}"; do
            revert_branch "$branch"
        done
    fi
    
    show_status
    
    echo -e "${GREEN}✅ Reversion complete!${NC}"
    echo ""
    echo -e "${YELLOW}ℹ️  Note: The error simulation code has been removed from these branches.${NC}"
    echo -e "${YELLOW}   They now match the main branch.${NC}"
}

# Run main function
main "$@"

