#!/usr/bin/env bash
# Gathers the facts a review starts from and prints them as key=value lines.
#
# Takes no arguments by design: the caller is an agent holding untrusted text
# (branch names, PR titles, ticket bodies), and a script without parameters
# cannot have that text smuggled onto its command line. The single input is
# the optional BCR_BASE environment variable, validated below.
set -euo pipefail

if [ "$#" -ne 0 ]; then
  echo "error=collect-context.sh takes no arguments (set BCR_BASE to name a base ref)" >&2
  exit 2
fi

# Anything that ends up in a path is reduced to this alphabet first. Remote
# URLs and branch names are chosen by whoever pushed them, so they are treated
# as hostile: no slashes, no leading dots or dashes, bounded length.
to_slug() {
  local s
  s=$(printf '%s' "$1" | LC_ALL=C tr -c 'A-Za-z0-9._-' '-' | LC_ALL=C sed -e 's/\.\{2,\}/./g' -e 's/[.-]*-[.-]*/-/g' -e 's/^[.-]*//' -e 's/[.-]*$//')
  s=${s:0:80}
  printf '%s' "${s:-unnamed}"
}

# One root for every skillbox, so connections learned by one skill serve all.
# Not ~/.skillbox: unrelated skill managers already own that folder.
root="$HOME/.skillbox-data"
store="$root/better-code-review"
connections_dir="$root/connections"
mkdir -p "$store/reports" "$store/context/repos" "$connections_dir"
chmod 700 "$root"

list_names() {
  local dir=$1 f out=""
  for f in "$dir"/*.md; do
    [ -e "$f" ] || continue
    out="$out$(basename "$f") "
  done
  printf '%s' "${out% }"
}

echo "now_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "store=$store"
echo "connections_dir=$connections_dir"
echo "connections=$(list_names "$connections_dir")"
if [ -f "$store/context/preferences.md" ]; then
  echo "preferences=$store/context/preferences.md"
else
  echo "preferences=none"
fi

if ! repo_root=$(git rev-parse --show-toplevel 2>/dev/null); then
  # Reviews of remote changes can start outside any checkout.
  echo "mode=no-repo"
  echo "reports_root=$store/reports"
  exit 0
fi
cd "$repo_root"
echo "mode=repo"
echo "repo_root=$repo_root"

# --- identity -------------------------------------------------------------
origin=$(git remote get-url origin 2>/dev/null || true)
host=""
repo_path=""
if [ -n "$origin" ]; then
  rest=${origin#*://}          # drop scheme
  rest=${rest#*@}              # drop user
  rest=${rest%.git}
  rest=${rest%/}
  case "$rest" in
    */*) ;;
    *) rest="" ;;
  esac
  if [ -n "$rest" ]; then
    host=${rest%%[:/]*}
    repo_path=${rest#*[:/]}
    case "$repo_path" in      # ssh://host:2222/owner/repo → drop the port
      [0-9]*/*) port=${repo_path%%/*}; case "$port" in *[!0-9]*) ;; *) repo_path=${repo_path#*/} ;; esac ;;
    esac
  fi
fi
if ! printf '%s' "$host" | LC_ALL=C grep -Eq '^[A-Za-z0-9]([A-Za-z0-9.-]{0,251}[A-Za-z0-9])?$'; then
  host="local"
  repo_path=$(basename "$repo_root")
fi
repo_slug="$(to_slug "$host")__$(to_slug "$repo_path")"
echo "host=$host"
echo "repo_slug=$repo_slug"

if branch=$(git symbolic-ref --short -q HEAD); then :; else branch=""; fi
if ! head_sha=$(git rev-parse --verify -q HEAD); then
  echo "changes=none"
  echo "note=repository has no commits yet"
  exit 0
fi
short_sha=${head_sha:0:10}
if [ -n "$branch" ]; then
  branch_slug=$(to_slug "$branch")
else
  branch_slug="detached-$short_sha"
fi
echo "branch=${branch:-detached}"
echo "head=$head_sha"

# --- base -----------------------------------------------------------------
resolves() { git rev-parse --verify -q "$1^{commit}" >/dev/null 2>&1; }

base=""
if [ -n "${BCR_BASE:-}" ]; then
  if printf '%s' "$BCR_BASE" | LC_ALL=C grep -Eq '^[A-Za-z0-9][A-Za-z0-9._/-]{0,200}$' && resolves "$BCR_BASE"; then
    base=$BCR_BASE
  else
    echo "error=BCR_BASE is not a plain ref name that resolves to a commit" >&2
    exit 2
  fi
else
  default_ref=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || true)
  for candidate in "$default_ref" origin/main origin/master origin/develop main master develop; do
    [ -n "$candidate" ] || continue
    if resolves "$candidate"; then base=$candidate; break; fi
  done
fi

if [ -n "$base" ] && merge_base=$(git merge-base HEAD "$base" 2>/dev/null); then
  :
else
  # No usable base: only uncommitted work can be reviewed.
  base="HEAD"
  merge_base=$head_sha
fi
echo "base=$base"
echo "merge_base=$merge_base"

# --- the change -----------------------------------------------------------
workdir=$(mktemp -d "${TMPDIR:-/tmp}/bcr-XXXXXX")
# External diff drivers and textconv filters are repo-configurable programs;
# a review must not execute them.
diff_opts=(--no-ext-diff --no-textconv --no-color -M)

git diff "${diff_opts[@]}" "$merge_base" -- >"$workdir/change.diff"
git diff "${diff_opts[@]}" --name-status "$merge_base" -- >"$workdir/files.txt"
git log --no-color --format='--- %h %an %ad%n%s%n%n%b' --date=short "$merge_base..HEAD" >"$workdir/commits.txt"

: >"$workdir/untracked.txt"
: >"$workdir/untracked-withheld.txt"
while IFS= read -r -d '' f; do
  lower=$(printf '%s' "${f##*/}" | LC_ALL=C tr 'A-Z' 'a-z')
  case "$lower" in
    .env|.env.*|*.pem|*.key|*.p12|*.pfx|*.jks|*.keystore|id_rsa*|id_ed25519*|id_ecdsa*|.netrc|.npmrc|.pypirc|credentials|credentials.*|secrets.*|*.tfvars)
      printf '%s\n' "$f" >>"$workdir/untracked-withheld.txt" ;;
    *)
      printf '%s\n' "$f" >>"$workdir/untracked.txt" ;;
  esac
done < <(git ls-files --others --exclude-standard -z)

added=0
removed=0
while read -r a r _; do
  case "$a" in *[!0-9]*|'') a=0 ;; esac
  case "$r" in *[!0-9]*|'') r=0 ;; esac
  added=$((added + a))
  removed=$((removed + r))
done < <(git diff "${diff_opts[@]}" --numstat "$merge_base" --)

tracked_files=$(wc -l <"$workdir/files.txt" | tr -d ' ')
untracked_files=$(wc -l <"$workdir/untracked.txt" | tr -d ' ')
withheld_files=$(wc -l <"$workdir/untracked-withheld.txt" | tr -d ' ')
commits=$(git rev-list --count "$merge_base..HEAD")
total_files=$((tracked_files + untracked_files))
total_lines=$((added + removed))

if [ "$total_files" -eq 0 ]; then
  rm -rf "$workdir"
  echo "changes=none"
  exit 0
fi

if [ "$total_lines" -le 150 ] && [ "$total_files" -le 5 ]; then
  size=small
elif [ "$total_lines" -gt 1000 ] || [ "$total_files" -gt 30 ]; then
  size=large
else
  size=medium
fi

if [ -n "$(git status --porcelain 2>/dev/null | head -n 1)" ]; then uncommitted=yes; else uncommitted=no; fi

echo "changes=present"
echo "commits=$commits"
echo "files_changed=$tracked_files"
echo "files_untracked=$untracked_files"
echo "files_withheld=$withheld_files"
echo "lines_added=$added"
echo "lines_removed=$removed"
echo "uncommitted=$uncommitted"
echo "size=$size"
echo "workdir=$workdir"

# Tracker keys in the branch name are only hints; the orchestrator confirms.
hints=$(printf '%s' "$branch" | LC_ALL=C grep -Eo '[A-Z][A-Z0-9]{1,9}-[0-9]{1,7}' | sort -u | tr '\n' ' ' || true)
echo "ticket_hints=${hints% }"

# --- where the report goes ------------------------------------------------
report_dir="$store/reports/$repo_slug/$branch_slug"
mkdir -p "$report_dir"
previous=none
for f in "$report_dir"/*.md; do
  [ -e "$f" ] || continue
  previous=$f              # glob order is lexical, and names start with a UTC stamp
done
echo "previous_report=$previous"
echo "report_path=$report_dir/$(date -u +%Y%m%dT%H%M%SZ)-$short_sha.md"

repo_context="$store/context/repos/$repo_slug.md"
echo "repo_context_path=$repo_context"
if [ -f "$repo_context" ]; then echo "repo_context=present"; else echo "repo_context=absent"; fi
