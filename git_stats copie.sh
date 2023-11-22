authors=$(git shortlog -sne --all | awk '{print $2}')

if [ -z "$authors" ]; then
  echo "Error: No authors found in the repository."
  exit 1
fi

echo "Available authors:"
echo "$authors"
read -p "Select an author from the list: " selected_author

if ! echo "$authors" | grep -q "$selected_author"; then
  echo "Error: Invalid author selection."
  exit 1
fi

commit_stats=$(git log --author="$selected_author" --pretty=tformat: --numstat | awk '
  { inserted += $1; deleted += $2; delta += $1 - $2; ratio = deleted / inserted }
  END {
    printf "| Lines added (total)   | %s |\n| Lines deleted (total) | %s |\n| Total lines (delta)   | %s |\n| Add./Del. ratio (1:n) | 1 : %s |\n", inserted, deleted, delta, ratio
  }')

commit_summary=$(git log --author="$selected_author" --pretty=format:"| %h | %ai | %s" --shortstat)

delta_time=$(git log --author="$selected_author" --pretty="%at %h" | sort -n | awk '
  NR>1 {
    delta = $1 - prev
    printf "| Delta Time | %dd %02d:%02d:%02d | %s |\n", delta/86400, delta%86400/3600, delta%3600/60, delta%60, $2
  }
  { prev = $1 }'
)

echo -e "\nCommit statistics for author $selected_author:"
echo "$commit_stats"

echo -e "\nCommit summary for author $selected_author:"
echo "$commit_summary"

echo -e "\nDelta Time Between Consecutive Commits (sorted by commit order):"
echo "$delta_time"
