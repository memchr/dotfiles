autoload -Uz zmathfunc && zmathfunc

function 256color() {
	for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

function term_nl() {
	[[ -t 1 ]] && printf "\n"
}
