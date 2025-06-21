#!/bin/bash

echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md

tags=($(git tag -l --sort=-version:refname))

for ((i=0; i<${#tags[@]}; i++)); do
    current_tag=${tags[i]}
    next_index=$((i+1))

    tag_date=$(git log -1 --format=%ai "$current_tag" | cut -d' ' -f1)

    echo "## [$current_tag] - $tag_date" >> CHANGELOG.md
    echo "" >> CHANGELOG.md

    if [ $next_index -lt ${#tags[@]} ]; then
        previous_tag=${tags[$next_index]}
        git log --oneline ${previous_tag}..${current_tag} | sed 's/^[a-f0-9]* /- /' >> CHANGELOG.md
    else
        git log --oneline ${current_tag} | sed 's/^[a-f0-9]* /- /' >> CHANGELOG.md
    fi

    echo "" >> CHANGELOG.md
done
