# Get size of github repo
gh_reposize() {
	[[ -z $1 ]] && echo "Usage: $0 owner/reponame" && return 1
	curl -s https://api.github.com/repos/$1 | jq '.size' | numfmt --to=iec --from-unit=1024
}

# Convert git clone to use ssh. Suitable for github and gitlab
git_http2ssh() {
	[[ -e "$1" ]] || return 1
	local origin ssh_url
	origin=$(git -C "$1" remote get-url origin)
	ssh_url=$(echo "$origin" | sed -E 's#\.git/?$##' | sed -En 's#^https?://([^/]*)/([^/]*)/([^/]*)/*$#git@\1:\2/\3.git#p')
	[[ -n $ssh_url ]] && git -C "$1" remote set-url origin "$ssh_url" || return 2
}

# pull every git repository in current directory
git_pullall() {
	echo * | xargs -P100 -I{} git -C {} pull
}
