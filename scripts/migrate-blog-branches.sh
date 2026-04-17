#!/usr/bin/env bash
#
# Migrate legacy blog-post branches to the feat/blog/<slug> convention.
#
# Usage:
#   bash scripts/migrate-blog-branches.sh            # dry-run, write report only
#   bash scripts/migrate-blog-branches.sh --execute  # perform remote renames
#
# Classification (per remote branch, excluding master):
#   - MERGED:        git cherry master origin/<branch> shows zero + lines
#                    (all commits already in master via patch-id equivalence)
#   - BLOG_UNMERGED: not merged AND every changed path is under content/
#                    AND at least one changed path is under content/post/
#   - LEGACY:        BLOG_UNMERGED but >20 commits ahead and >50 commits
#                    behind master (huge drift, needs manual review)
#   - OTHER:         everything else (infra, theme, garden, renovate, fixes)
#
# Rename map for BLOG_UNMERGED is hardcoded below. Branches not in the map
# fall through to an auto-derived name based on the post file path, or are
# skipped and reported for manual handling.
#
# Open PRs are checked via the GitHub CLI if available (`gh pr list`).
# Branches with open PRs are never renamed by this script.

set -euo pipefail

EXECUTE=0
if [[ "${1:-}" == "--execute" ]]; then
  EXECUTE=1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

REPORT="scratch/branch-migration-report.md"
mkdir -p scratch

# Hardcoded rename map (old branch -> new branch).
# Keep in sync with the plan; empty string = skip (manual handling).
declare -A RENAME_MAP=(
  [add_blog_about_cursor_and_azure_cli_tool]="feat/blog/cursor-azure-cli-agent"
  [blog/add-terrance-gore-tribute]="feat/blog/terrance-gore-tribute"
  [blog/resurrecting_a_13_year_old_oss_project_for_13_bucks]="feat/blog/resurrecting-oss-project"
  [blog/why-moneyball-is-such-a-tricky-movie-to-talk-about-as-a-baseball-fan]=""
  [claude/plan-flink-blog-post-JTtFU]="feat/blog/flink"
  [feat/add-being-human-in-the-age-of-genai-post]="feat/blog/being-human-genai"
  [feat/add-blog-about-ma]="feat/blog/ma-kurosawa-ai-slop"
  [feat/add-fosdem-2026-blog-post]="feat/blog/fosdem-2026"
  [feat/add-from-prompting-to-agentic-flows]="feat/blog/prompting-to-agentic-flows"
  [feat/add-new-blogpost-about-msf-tracing]="feat/blog/msf-distributed-tracing"
  [feat/add-rip-terrance-gore-post]="feat/blog/rip-terrance-gore"
  [feat/add-testcon-2025-trip-report]="feat/blog/testcon-2025"
  [feat/blog/moneyball-movie-blog]="feat/blog/moneyball-problem"
  [feat/discuss-blog-upgrades]="feat/blog/blog-upgrades"
  [feat/website-update-and-future-planning-post]="feat/blog/refocusing-2026"
  [petems/blog-post-claude-skills-review]="feat/blog/claude-skills-review"
  [petems/feat/meta-first-run-PAL-mcp-blog-post]="feat/blog/pal-mcp-consensus"
)

# Fetch latest remote state so classification is accurate.
git fetch --prune origin >/dev/null 2>&1 || true

have_gh() { command -v gh >/dev/null 2>&1; }

open_pr_for() {
  local branch="$1"
  if ! have_gh; then
    echo "UNKNOWN"
    return
  fi
  local n
  n="$(gh pr list --repo petems/petersouter.xyz --head "$branch" --state open --json number --jq '.[0].number' 2>/dev/null || true)"
  if [[ -n "$n" ]]; then
    echo "$n"
  else
    echo ""
  fi
}

classify() {
  local ref="$1"
  local branch="${ref#origin/}"
  if [[ "$branch" == "master" || "$branch" == "HEAD" ]]; then
    echo "SKIP"
    return
  fi
  # Branches already matching the target convention are correctly named.
  if [[ "$branch" == feat/blog/* || "$branch" == feat/garden/* ]]; then
    echo "OTHER"
    return
  fi
  # Branches with no common ancestor to master are treated as legacy.
  if ! git merge-base master "$ref" >/dev/null 2>&1; then
    echo "LEGACY"
    return
  fi
  local unique_count
  unique_count="$(git cherry master "$ref" 2>/dev/null | grep -c '^+' || true)"
  if [[ "$unique_count" == "0" ]]; then
    echo "MERGED"
    return
  fi
  local diff_paths
  diff_paths="$(git diff --name-only master..."$ref" 2>/dev/null || true)"
  if [[ -z "$diff_paths" ]]; then
    echo "OTHER"
    return
  fi
  local has_post=0
  local has_code=0
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    if [[ "$p" == content/post/* ]]; then has_post=1; fi
    # "Content-like" paths: post/garden markdown + images/files referenced from posts.
    if [[ "$p" != content/* && "$p" != static/images/* && "$p" != static/files/* ]]; then
      has_code=1
    fi
  done <<<"$diff_paths"
  if [[ "$has_post" == "1" && "$has_code" == "0" ]]; then
    local ahead behind
    ahead="$(git rev-list --count master.."$ref" 2>/dev/null || echo 0)"
    behind="$(git rev-list --count "$ref"..master 2>/dev/null || echo 0)"
    if (( ahead > 20 )) && (( behind > 50 )); then
      echo "LEGACY"
    else
      echo "BLOG_UNMERGED"
    fi
    return
  fi
  echo "OTHER"
}

last_commit_date() {
  git log -1 --format=%cs "$1" 2>/dev/null || echo "?"
}

ahead_count() {
  git rev-list --count master.."$1" 2>/dev/null || echo 0
}

# Collect branches by category.
declare -a MERGED_BRANCHES=()
declare -a BLOG_BRANCHES=()
declare -a LEGACY_BRANCHES=()
declare -a OTHER_BRANCHES=()

mapfile -t REMOTE_BRANCHES < <(git for-each-ref --format='%(refname:short)' refs/remotes/origin/ | sort)

for ref in "${REMOTE_BRANCHES[@]}"; do
  cat="$(classify "$ref")"
  case "$cat" in
    MERGED)        MERGED_BRANCHES+=("$ref") ;;
    BLOG_UNMERGED) BLOG_BRANCHES+=("$ref") ;;
    LEGACY)        LEGACY_BRANCHES+=("$ref") ;;
    OTHER)         OTHER_BRANCHES+=("$ref") ;;
    SKIP) ;;
  esac
done

# Build the report.
{
  echo "# Blog Branch Migration Report"
  echo
  echo "_Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)_"
  echo
  echo "Run \`bash scratch/migrate-blog-branches.sh --execute\` to perform the renames."
  echo

  echo "## Merged but undeleted"
  echo
  if (( ${#MERGED_BRANCHES[@]} == 0 )); then
    echo "_None._"
  else
    echo "| Branch | Last commit | Recommended action |"
    echo "|---|---|---|"
    for ref in "${MERGED_BRANCHES[@]}"; do
      b="${ref#origin/}"
      echo "| \`$b\` | $(last_commit_date "$ref") | \`git push origin --delete $b\` |"
    done
  fi
  echo

  echo "## Blog branches to rename"
  echo
  if (( ${#BLOG_BRANCHES[@]} == 0 )); then
    echo "_None._"
  else
    echo "| Old branch | New branch | Status | Open PR |"
    echo "|---|---|---|---|"
    for ref in "${BLOG_BRANCHES[@]}"; do
      b="${ref#origin/}"
      new="${RENAME_MAP[$b]:-}"
      if [[ -z "$new" ]]; then
        new_cell="_(skip: no rename mapping, manual review)_"
        status="needs mapping"
      elif git show-ref --verify --quiet "refs/remotes/origin/$new"; then
        new_cell="\`$new\`"
        status="renamed; delete old: \`git push origin --delete $b\`"
      else
        new_cell="\`$new\`"
        status="pending"
      fi
      pr="$(open_pr_for "$b")"
      if [[ -z "$pr" ]]; then
        pr_cell="none"
      elif [[ "$pr" == "UNKNOWN" ]]; then
        pr_cell="?"
      else
        pr_cell="#$pr (blocks rename)"
      fi
      echo "| \`$b\` | $new_cell | $status | $pr_cell |"
    done
  fi
  echo

  echo "## Legacy branches (needs manual review)"
  echo
  if (( ${#LEGACY_BRANCHES[@]} == 0 )); then
    echo "_None._"
  else
    echo "Long-lived blog branches with significant drift from master. Consider renaming, archiving, or deleting."
    echo
    echo "| Branch | Ahead | Behind |"
    echo "|---|---|---|"
    for ref in "${LEGACY_BRANCHES[@]}"; do
      b="${ref#origin/}"
      ahead="$(git rev-list --count master.."$ref" 2>/dev/null || echo 0)"
      behind="$(git rev-list --count "$ref"..master 2>/dev/null || echo 0)"
      echo "| \`$b\` | $ahead | $behind |"
    done
  fi
  echo

  echo "## Left alone (not blog posts)"
  echo
  for ref in "${OTHER_BRANCHES[@]}"; do
    b="${ref#origin/}"
    echo "- \`$b\`"
  done
} >"$REPORT"

echo "Report written to $REPORT"

if (( EXECUTE == 0 )); then
  echo "Dry-run complete. Re-run with --execute to perform the renames."
  exit 0
fi

# Execute renames.
echo
echo "Executing renames..."
declare -i renamed=0
declare -i skipped=0
declare -a PENDING_DELETES=()

for ref in "${BLOG_BRANCHES[@]}"; do
  old="${ref#origin/}"
  new="${RENAME_MAP[$old]:-}"
  if [[ -z "$new" ]]; then
    echo "  SKIP  $old (no rename mapping)"
    skipped+=1
    continue
  fi
  pr="$(open_pr_for "$old")"
  if [[ -n "$pr" && "$pr" != "UNKNOWN" ]]; then
    echo "  SKIP  $old -> $new (open PR #$pr)"
    skipped+=1
    continue
  fi
  if git show-ref --verify --quiet "refs/remotes/origin/$new"; then
    echo "  SKIP  $old -> $new (destination already exists)"
    skipped+=1
    continue
  fi
  echo "  MOVE  $old -> $new"
  # Create local ref pointing at the old remote commit, then push as new remote branch.
  git update-ref "refs/heads/$new" "refs/remotes/origin/$old"
  if ! git push -u origin "$new"; then
    echo "    push of $new failed, skipping delete"
    skipped+=1
    continue
  fi
  # Delete may be blocked depending on remote permissions. If so, leave the
  # old branch alone and record it for manual cleanup.
  if git push origin --delete "$old" 2>/dev/null; then
    renamed+=1
  else
    echo "    delete of $old failed — leave a note for manual cleanup"
    PENDING_DELETES+=("$old")
    renamed+=1
  fi
done

echo
echo "Done. Renamed $renamed, skipped $skipped."
if (( ${#PENDING_DELETES[@]} > 0 )); then
  echo
  echo "The following old branches still exist and need to be deleted manually:"
  for b in "${PENDING_DELETES[@]}"; do
    echo "  git push origin --delete $b"
  done
fi
echo "Re-run the dry-run to refresh $REPORT."
