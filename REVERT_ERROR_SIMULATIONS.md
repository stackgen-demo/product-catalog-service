# Reverting Error Simulation Branches

This document explains how to revert the error simulation branches back to the main branch state.

## Quick Revert

### Revert All Branches

Run the provided script to revert all error simulation branches:

```bash
cd /Users/leander/Documents/product-catalog-service
./revert-error-simulations.sh
```

### Revert a Specific Branch

To revert only one branch:

```bash
./revert-error-simulations.sh feature/nil-pointer-searchproducts
./revert-error-simulations.sh feature/index-out-of-bounds
./revert-error-simulations.sh feature/memory-exhaustion
```

## Manual Revert Process

If you prefer to revert manually, follow these steps for each branch:

### 1. Revert `feature/nil-pointer-searchproducts`

```bash
cd /Users/leander/Documents/product-catalog-service

# Checkout the branch
git checkout feature/nil-pointer-searchproducts

# Reset to main
git reset --hard main

# Force push to remote
git push origin feature/nil-pointer-searchproducts --force-with-lease
```

### 2. Revert `feature/index-out-of-bounds`

```bash
git checkout feature/index-out-of-bounds
git reset --hard main
git push origin feature/index-out-of-bounds --force-with-lease
```

### 3. Revert `feature/memory-exhaustion`

```bash
git checkout feature/memory-exhaustion
git reset --hard main
git push origin feature/memory-exhaustion --force-with-lease
```

## What Gets Reverted

### `feature/nil-pointer-searchproducts`
- ✅ Removes the product with `null` name from `products.json`
- ✅ Restores original `SearchProducts()` function without error simulation

### `feature/index-out-of-bounds`
- ✅ Removes the index-based lookup logic from `GetProduct()`
- ✅ Restores original sequential search implementation

### `feature/memory-exhaustion`
- ✅ Removes the 1000+ test products from `products.json`
- ✅ Restores original product catalog (10 products)
- ✅ Removes memory exhaustion comment from `ListProducts()`

## Verification

After reverting, verify the branches match main:

```bash
# Check differences
git checkout feature/nil-pointer-searchproducts
git diff main

git checkout feature/index-out-of-bounds
git diff main

git checkout feature/memory-exhaustion
git diff main
```

If there are no differences (or only expected differences), the revert was successful.

## Alternative: Create Revert Commits

If you want to preserve the error simulation history but create a revert commit:

```bash
# For each branch
git checkout feature/nil-pointer-searchproducts
git revert HEAD~1..HEAD  # Revert last commit(s)
git push origin feature/nil-pointer-searchproducts
```

However, the `git reset --hard main` approach is cleaner as it completely removes the error simulation code.

## Restoring Error Simulations

If you need to restore the error simulations after reverting:

1. **Option 1**: Re-apply the changes from the original commits
   ```bash
   git checkout feature/nil-pointer-searchproducts
   git cherry-pick <original-commit-hash>
   ```

2. **Option 2**: Re-create the branches from scratch using the original process

## Safety Notes

⚠️ **Warning**: The revert script uses `--force-with-lease` to push changes. This is safe because:
- It only updates the remote branch if no one else has pushed changes
- The branches are feature branches, not main/master
- The changes are intentional error simulations meant to be reverted

If you encounter conflicts:
1. Check if someone else has pushed to the branch
2. Review the remote branch: `git fetch origin && git log origin/feature/<branch-name>`
3. Resolve conflicts manually if needed

## Script Usage

The `revert-error-simulations.sh` script:

- ✅ Fetches latest from remote
- ✅ Checks if branches exist
- ✅ Resets each branch to main
- ✅ Force-pushes with `--force-with-lease` for safety
- ✅ Provides colored output for clarity
- ✅ Shows status after completion

### Script Options

```bash
# Revert all branches (with confirmation prompt)
./revert-error-simulations.sh

# Revert specific branch
./revert-error-simulations.sh feature/nil-pointer-searchproducts

# Show help (if branch name is invalid)
./revert-error-simulations.sh invalid-branch
```

## Troubleshooting

### "Branch does not exist locally"
- Fetch from remote: `git fetch origin`
- Checkout the branch: `git checkout -b feature/<name> origin/feature/<name>`

### "Failed to push"
- Check your authentication: `git remote -v`
- Verify you have push permissions
- Try manual push: `git push origin <branch> --force-with-lease`

### "Not a git repository"
- Ensure you're in the product-catalog-service directory
- Run: `cd /Users/leander/Documents/product-catalog-service`

## Summary

The revert process:
1. ✅ Resets error simulation branches to match main
2. ✅ Removes all error simulation code
3. ✅ Restores original functionality
4. ✅ Updates remote branches safely

After reverting, the branches will be identical to main and can be used for normal development or deleted if no longer needed.

