#!/bin/bash
echo "Phase 3 Validation Starting..."
echo "Checking site.yml syntax..."
ansible-playbook --syntax-check site.yml
echo "Validation complete!"
