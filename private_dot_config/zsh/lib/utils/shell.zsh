# Show most used command
function history_stats() {
	fc -l 1 \
	| awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' \
	| grep -v "./" | sort -nr | head -40 | column -c3 -s " " -t | nl
}


