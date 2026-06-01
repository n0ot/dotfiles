# shellcheck shell=bash
# GitHub CLI helpers — aliases and functions that prefer --json over grepping UX output.

# --- PR info (current branch or specific PR number) ---

# Copy the PR URL to clipboard.
# Usage: pru [<number>]
pru() {
	gh pr view "$@" --json url -q .url | tr -d '\n' | pbcopy
	echo "Copied: $(pbpaste)"
}

# Show reviewers requested and their login names.
# Usage: prrev [<number>]
prrev() {
	gh pr view "$@" --json reviewRequests \
		-q '.reviewRequests[].login // .reviewRequests[].name // empty'
}

# Show the review decision (APPROVED, CHANGES_REQUESTED, REVIEW_REQUIRED, etc.)
# Usage: prrd [<number>]
prrd() {
	gh pr view "$@" --json reviewDecision -q .reviewDecision
}

# Show PR state (OPEN, CLOSED, MERGED).
# Usage: prst [<number>]
prst() {
	gh pr view "$@" --json state -q .state
}

# Show PR labels.
# Usage: prla [<number>]
prla() {
	gh pr view "$@" --json labels -q '.labels[].name'
}

# Quick one-liner PR summary: number, state, review decision, title.
# Usage: prinfo [<number>]
prinfo() {
	gh pr view "$@" --json number,state,reviewDecision,title,url,isDraft \
		-q '"#\(.number) [\(.state)] review=\(.reviewDecision) draft=\(.isDraft)\n\(.title)\n\(.url)"'
}

# --- PR checks ---

# Show CI check status as a compact table (name, state, bucket).
# Usage: prck [<number>]
prck() {
	local args=()
	# Pass through any PR number argument, but always add --json
	[[ $# -gt 0 ]] && args+=("$@")
	gh pr checks "${args[@]}" --json name,state,bucket \
		-q '.[] | "\(.bucket)\t\(.name)\t\(.state)"' |
		sort | column -ts $'\t'
}

# Show only failing checks.
# Usage: prckf [<number>]
prckf() {
	gh pr checks "$@" --json name,state,bucket,link \
		-q '.[] | select(.bucket == "fail") | "\(.name)\t\(.state)\t\(.link)"' |
		column -ts $'\t'
}

# Watch checks until they finish, with a 30s refresh.
# Usage: prckw [<number>]
alias prckw='gh pr checks --watch --interval 30'

# --- PR diff ---

# Save a PR diff to a file (defaults to "f" to match your habit).
# Usage: prd [<number>] [<file>]
prd() {
	local pr_num="" outfile="f"
	while [[ $# -gt 0 ]]; do
		case "$1" in
			[0-9]*) pr_num="$1" ;;
			*) outfile="$1" ;;
		esac
		shift
	done
	if [[ -n $pr_num ]]; then
		gh pr diff "$pr_num" >"$outfile"
	else
		gh pr diff >"$outfile"
	fi
	echo "Saved diff to $outfile ($(wc -l < "$outfile") lines)"
}

# --- PR workflow ---

alias prl='gh pr list'
alias prv='gh pr view'
alias prvw='gh pr view -w'
alias prc='gh pr create'
alias pre='gh pr edit'
alias prm='gh pr merge'
alias pra='gh pr review -a'

# Rerun failed CI jobs for the current branch.
alias rerun='gh run rerun --failed'

# Checkout a PR by number.
# Usage: prco <number>
alias prco='gh pr checkout'
