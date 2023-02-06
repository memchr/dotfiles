# Dns over https using `dog`
function doh() {
	dog -H @https://1.1.1.1/dns-query "$@"
}

function handshake() {
	local usage ip domain curl_opts curl_out
	read -r -d '' usage <<- EOT
	Test tls connectivity

	Usage: 
	    $0 <domain> [ip]
	EOT
	while getopts 'h' opt; do
		case $opt in
		h)
			print -P -- $usage
			return 0
			;;
		*)
			return 2
			;;
		esac
	done
	shift $((OPTIND - 1))
	if (($# < 1)); then
		print -P "%F{red}missing domain name%f"
	fi
	domain=${${1#http(|s)://}%%/*}
	if (($# == 2)); then
		ip=$2
		curl_opts=("--resolve $domain:443:$ip")
	fi
	curl_out=$(curl \
		https://$domain \
		${(z)curl_opts} \
		-Is -o /dev/null -m 4 \
		-w @- <<- EOT
		%{time_total}\n
		EOT
	)
	if [[ $? != 0 ]]; then
		print -P "%F{red}handshake failed%f"
		return 1
	else
		print -P "handshek succeed, time %F{green}%B$curl_out%bms%f"
		
	fi
}

function lat() {
	typeset -a latency
	typeset -i test_count=1
	typeset -E lat_min lat_max lat_avg

	read -r -d '' usage <<- EOT
	Test network latency

	Usage: 
	    $0 [-c count]
	
	Options:
	    -c      stop after count, default is 1 (only test latency once)
	EOT
	while getopts 'hc:' opt; do
		case $opt in
		c)
			test_count=${OPTARG}
			;;
		h)
			print -P -- $usage
			return 0
			;;
		*)
			return 2
			;;
		esac
	done
	shift $((OPTIND - 1))

	for ((i = 0; i < test_count; i++)); do
		local __=$(dig @1.1.1.1 one.one.one.one +timeout=2 +noall +stats)
		if [[ $? != 0 ]]; then
			print -P "%F{red}timeout%f"
		else
			latency+=($( echo $__ | awk '/Query time:/{t=$4 " "}END{printf t}'))
			print -P "seq=%F{yellow}$i%f time=%B%F{green}$latency[-1]%b ms%f"
		fi
	done
	if (( test_count != 1 )); then
		(( lat_max = max(${(pj:,:)latency}) ))
		(( lat_min = min(${(pj:,:)latency}) ))
		(( lat_avg = (sum(${(pj:,:)latency})) / ${#latency} ))
		print -P -f "rtt %s = %s%.2f%s/%s%.2f%s/%s%.2f%s ms\n" \
			"%F{11}min%f/%F{12}avg%f/%F{9}max%f" \
			"%F{11}" $lat_min "%f" "%F{12}" $lat_avg "%f" "%F{9}" $lat_max "%f"
	fi
}

# Percent encode a string
urlencode() {
    local LC_ALL=C char
    for (( i = 1; i <= ${#1}; i++ )); do
        char="${1[i]}"
        case "$char" in
            [a-zA-Z0-9.~_-])
                printf '%s' "$char"
            ;;
            *)
                printf '%%%02X' "'$char"
            ;;
        esac
    done
	term_nl
}

# Percent decode a string
urldecode() {
    # printf '%b\n' "${${1//+/ }//%/\\x}"
	printf ${1//\%/\\x}
	term_nl
}
