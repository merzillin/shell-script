#!/bin/bash

main() {

  # Validate commit message
  if [ -z "$1" ]; then
    echo "Commit message is required"
    exit 1
  fi

  # Ensure inside git repo
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Not a git repository"
    exit 1
  }

  read -p "Have you taken a pull? (y/n): " answer

  if [ "$answer" = "y" ]; then

    git add .
    git commit -m "$1"
  
    branchName=$(git branch --show-current)
    createdOn=$(date +"%d-%m-%Y %I:%M:%S %p")

    {
      echo "--------------------"
      echo "Message   : $1"
      echo "Branch    : $branchName"
      echo "Timestamp : $createdOn"
    } >> commit.txt

    echo "Commit logged successfully."

  else
    echo "Please take a pull before committing."
  fi
}

main "$1"
