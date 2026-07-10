#!/bin/bash

# Check if a repository name was provided
if [ $# -eq 0 ]; then
    echo "Please provide a repository name as an argument."
    exit 1
fi

# Store the repository name
repo_name=$1

# Create the repository remotely
echo "Creating repository '$repo_name' on GitHub..."
gh repo create "$repo_name" --public

# Initialize the local repository
echo "Initializing local repository..."
git init

# Create README.md if it doesn't exist
if [ ! -f README.md ]; then
    echo "Creating empty README.md..."
    echo "# $repo_name" > README.md
    echo "This is a new repository." >> README.md
fi

# Add all files
echo "Adding all files..."
git add .

# Commit changes
echo "Committing changes..."
git commit -m "Initial commit"

# Get the GitHub username
github_username=$(gh api user -q .login)

# Add the remote origin using SSH
echo "Adding remote origin..."
git remote add origin "git@github.com:$github_username/$repo_name.git"

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin master

echo "Repository created and initial commit pushed successfully!"
