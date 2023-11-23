# turbo-micromanagement-9000

## Disclaimer
The tool was created exclusively for analytical purposes and not for exposing or discriminating against coworkers.

## Mac
### Step 1
Go to your bin folder in usr/local/bin

![image](https://github.com/Markol17/turbo-micromanagement-9000/assets/19934640/0851d736-6edd-4d80-ae6d-3d02929e457d)

### Step 2
Create a file called git_stats.sh:
```bash touch git_stats.sh```

### Step 3
Copy paste this code in the ```git_stats.sh``` file
```bash
authors=$(git shortlog -sne --all | awk '{print $2}')

if [ -z "$authors" ]; then
  echo "Error: No authors found in the repository."
  exit 1
fi

echo "Available authors:"
echo "$authors"
read -p "Select an author from the list: " selected_author

if ! echo "$authors" | grep -q "$selected_author"; then
  echo "Error: Invalid author selection"
  exit 1
fi

commit_stats=$(git log --author="$selected_author" --pretty=tformat: --numstat | awk '
  { inserted += $1; deleted += $2; delta += $1 - $2; ratio = deleted / inserted; files_changed += NF / 3; }
  END {
    printf "| Lines added (total)      | %s |\n", inserted
    printf "| Lines deleted (total)    | %s |\n", deleted
    printf "| Total lines (delta)      | %s |\n", delta
    printf "| Add./Del. ratio (1:n)    | 1 : %s |\n", ratio
    printf "| Total files changed      | %s |\n", files_changed
  }')

commit_summary=$(git log --author="$selected_author" --pretty=format:"| %h | %ai | %s" --shortstat)

delta_time=$(git log --author="$selected_author" --pretty="%at %h" | sort -n | awk '
  NR>1 {
    delta = $1 - prev
    printf "| %dd %02d:%02d:%02d   | %s |\n", delta/86400, delta%86400/3600, delta%3600/60, delta%60, $2
  }
  { prev = $1 }'
)

file_types_changed=$(git log --author="$selected_author" --pretty=tformat: --numstat | awk '
  NF==3 {
    total_changes += 1;
    split($3, parts, ".");
    extension = parts[length(parts)];
    file_changes[extension] += 1;
  }
  END {
    printf "|   Total Files Changed     | %s |\n", total_changes;
    printf "|   Files Changed by Type       | \n";
    for (type in file_changes) {
      printf "|   %-23s | %s |\n", type, file_changes[type];
    }
  }
')

commits_per_day=$(git log --author="$selected_author" --pretty="%ad" --date=short | sort | uniq -c | awk '{printf "| %s |        %s        |\n", $2, $1}')

echo "\nCommit summary for author $selected_author:"
echo "$commit_summary"

echo "\nCommit statistics for author $selected_author:"
echo "-----------------------------------"
echo "$commit_stats"
echo "-----------------------------------"

echo "\nDelta Time Between Consecutive Commits (sorted by commit order):"
echo "________________________________"
echo "|  Time Elapsed  | Commit Hash |"
echo "---------------------------------"
echo "$delta_time"
echo "---------------------------------"

echo "\nCommits per Day:"
echo "---------------------------------"
echo "|    Date    | Number of Commit |"
echo "---------------------------------"
echo "$commits_per_day"
echo "---------------------------------"

echo "\nAdditional Stats:"
echo "-----------------------------------"
echo "$file_types_changed"
echo "-----------------------------------"
```

### Step 4
Run this command 
```bash 
chmod +x git_stats.sh
```

### Step 5

Now you can run git_stats.sh in any git repo with this command:
```bash
git_stats.sh
```
![image](https://github.com/Markol17/turbo-micromanagement-9000/assets/19934640/7e731934-f5a4-4d0b-8f6c-6982d7eb3925)
