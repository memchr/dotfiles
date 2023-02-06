function nv() {
	[[ $# == 0 ]] && echo "wrong number of arguments" && return 2
	typeset -gA __nv_old_env
	typeset -g __nv_stats=${__nv_stats:-off}
	local subcmd=$1 usage
	read -r -d '' usage <<- EOT
	Set environment variables related to NVIDIA GPU

	Usage: $0 [on|off|run]

	Commands:
	    on        Use NVIDIA GPU only
	    off       Stop using NVIDIA GPU only
	    run       Run program using NVIDIA GPU only
	    status    Status
	EOT
	shift
	case $subcmd in
	on)
		if [[ $__nv_stats == off ]]; then
			__nv_old_env[__NV_PRIME_RENDER_OFFLOAD]="$__NV_PRIME_RENDER_OFFLOAD"
			__nv_old_env[__GLX_VENDOR_LIBRARY_NAME]="$__GLX_VENDOR_LIBRARY_NAME"
			__nv_old_env[__VK_LAYER_NV_optimus]="$__VK_LAYER_NV_optimus"
			__nv_old_env[VK_DRIVER_FILES]="$VK_DRIVER_FILES"
			__nv_stats=on
			export \
				__NV_PRIME_RENDER_OFFLOAD=1 \
				__GLX_VENDOR_LIBRARY_NAME=nvidia \
				__VK_LAYER_NV_optimus=NVIDIA_only \
				VK_DRIVER_FILES=/usr/share/vulkan/icd.d/nvidia_icd.json 
		fi
		;;
	off)
		if [[ $__nv_stats == on ]]; then
			for e in ${(k)__nv_old_env}; do
				if [[ -z $__nv_old_env[$e] ]]; then
					unset $e
				else
					export $e=$__nv_old_env[$e]
				fi
			done
		fi
		;;
	run)
		env \
			__NV_PRIME_RENDER_OFFLOAD=1 \
			__GLX_VENDOR_LIBRARY_NAME=nvidia \
			__VK_LAYER_NV_optimus=NVIDIA_only \
			VK_DRIVER_FILES=/usr/share/vulkan/icd.d/nvidia_icd.json \
			$@
		;;
	status)
		if 
			[[ $__GLX_VENDOR_LIBRARY_NAME == nvidia ]] && 
			[[ $__VK_LAYER_NV_optimus == NVIDIA_only ]]
		then
			echo "NVIDIA GPU in use"
		else
			echo "default"
		fi
		;;
	help|-h)
		print -P $usage
		return 0
		;;
	*)
		print -P "%F{red}unknown command $subcmd%f"
		return 2
		;;
	esac
}

function battery_conservation() {
	[[ $# == 0 ]] && echo "wrong number of arguments" && return 2
	local usage subcmd=$1 bc_status
	local switch=(/sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode)
	shift
	read -r -d '' usage <<- EOT
	Limits battery charging to 55-60% of its capacity to improve battery life.

	Usage: $0 <-eds>

	Commands:
	    on        Enable conservation mode
	    off       Disable conservation mode
	    status    Status
	EOT
	
	if [[ ! -e $switch ]]; then
		print -P "%F{red}conservation mode is not supported%f"
		return
	fi

	case $subcmd in
	on)
		echo 1 | sudo tee $switch >/dev/null &&
			print -P "conservation mode %F{green}enabled%f"
		;;
	off)
		echo 0 | sudo tee $switch >/dev/null &&
			print -P "conservation mode %F{red}disabled%f"
		;;
	status)
		read -r bc_status < $switch
		if [[ $bc_status == 0 ]]; then
			print -P "conservation mode %F{red}disabled%f"
		else
			print -P "conservation mode %F{green}enabled%f"
		fi
		;;
	*)
		print -P "%F{red}unknown command $subcmd%f"
		return 2
	esac

}

# sort package by size
function pacsize() {
	pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h
}

# sort files in package by size
function pacblame() {
	if [[ -z $1 ]]; then
		echo "list files in package by size"
		echo "Usage: pacblame package"
		return 1
	fi
	pacman -Qlq $1 | grep -v '/$' | xargs -r du -h | sort -h
}

# browse pacman packages with fzf
function pacfzf() {
	local pacman_args=() fzf_args=() install_cmd remove_cmd pv packages
	local remove_cmd="sudo pacman -Rns {} || read -sk \$'?Press any key to continue.\n'"
	local install_cmd="sudo pacman -S {} && read -sk \$'?Press any key to continue.\n'"
	local asdep_cmd="sudo pacman -D --asdeps {}"
	local asexp_cmd="sudo pacman -D --asexplicit {}"
	OPTINT=1
	usage() {
		printf "%s" "\
Browse pacman packages with fzf

Usage: 
	pacfzf <pacman options> [package|group|regex]
	pacfzf < list_of_packages
	command | pacfzf
	
These pacman arguments are supported
  	-Q:	list locally installed packages
  	-S:	list all available packages
  	-s	Search
 	-e	installed explicitly
 	-d	installed as dependencies
 	-t	packages not required by any package
 	-m	foreign packages
 	-n	packages found in syncdb
 	-u	upgradable
 	-g	all member of a group
 	-l	list files
"
	}
	# usage
	# return

	# Parse options
	declare -A flags=(
		# Options
		[local]=0		# -Q
		[remote]=0		# -S
		[search]=0		# -s
		[explicit]=0	# -e
		[deps]=0		# -d
		[nodep]=0		# -t
		[foreign]=0		# -m
		[syncdb]=0		# -n
		[upgrade]=0		# -u
		[group]=0		# -g
		[list]=0		# -l
		[print]=0		# -p
		[pipe]=0
	)
	if ((! $# )); then
		# get list of packages from pipe
		if [[ -t 0 ]]; then
			err "no option provided\n"
			usage
			return 1
		fi
		packages=$(</dev/stdin)
		flags[pipe]=1
	else
		while getopts ':QSsedtmuglpqnh' opt; do
			case "${opt}" in
			Q) 
				flags[local]=1
				pacman_args+=(-Qq);;
			S)
				flags[remote]=1 
				pacman_args+=(-Sq) ;;
			s) 
				flags[search]=1
				pacman_args+=(-s) ;;
			e)
				flags[explicit]=1
				pacman_args+=(-e);;
			d)
				flags[deps]=1 
				pacman_args+=(-d);;
			t)
				flags[nodep]=1
				pacman_args+=(-t);;
			m)
				flags[foreign]=1
				pacman_args+=(-m);;
			n)
				flags[syncdb]=1
				pacman_args+=(-n);;
			g)
				flags[group]=1 
				pacman_args+=(-g);;
			u)
				flags[upgrade]=1
				pacman_args+=(-u);;
			l)
				flags[list]=1 
				pacman_args+=(-l);;
			p)
				flags[print]=1
				pacman_args+=(-p --print-format "%n");;
			q) ;;
			h) usage ; return 0;;
			?) 
				err "invalid option\n"
				usage
				return 1
				;;
			esac
		done
		shift $((OPTIND-1))
	
		# append rest of arguments
		if ((flags[search] || flags[group] || flags[list] || flags[print])); then
			pacman_args+=(${=@})
			if (((flags[print] || flags[group])&& $# == 0)); then
				err "targets required"
				return 1
			fi
		elif (($#)); then
			err "redundant arguments"
			return 1
		fi
	fi
	
	# previewer
	pv='setopt nullglob
		word={}
		if ((group)); then word="${word##* }"; fi
		if ((list && local)); then
			prv $word $COLUMNS $LINES
		elif ((! local)); then
			localf=(/var/lib/pacman/local/{}(-[^-]#)(#c2))
			if [[ -n "${localf[1]}" ]]; then
				echo "\033[36;1m[installed]\033[0m"
				pacman --color=always -Qil $word
			else
				pacman --color=always -Sii $word
			fi
		else
			pacman --color=always -Qil $word
		fi'

	pv="local=${flags[local]}
		group=${flags[group]}
		list=${flags[list]}
		$pv"

	if ((! flags[pipe])); then
		packages=$(pacman ${=pacman_args})
		if (($?)); then
			err "no result"
			return 1
		fi
	fi
	if [[ -z $packages ]]; then
		err "empty package list"
		return 1
	fi

	echo $packages | fzf \
		--reverse \
		--bind "enter:execute($pv | less)" \
		--bind "alt-i:execute($install_cmd)" \
		--bind "alt-r:execute($remove_cmd)" \
		--bind "alt-d:execute($asexp_cmd)" \
		--bind "alt-e:execute($asexp_cmd)" \
		--preview "COLUMNS=\$FZF_PREVIEW_COLUMNS LINES=\$FZF_PREVIEW_LINES $pv"

	# cleanup
	unset flags
}

function proxy_env() {
	[[ $# == 0 ]] && echo "wrong number of arguments" && return 2
	local subcmd=$1
	shift
	case $subcmd in
	set)
		local proxy_host=$1
		if [[ $proxy_host =~ [0-9]* ]]; then
			proxy_host=socks5://127.0.0.1:$proxy_host
		fi
		export \
			http_proxy=$proxy_host \
			HTTP_PROXY=$proxy_host \
			https_proxy=$proxy_host \
			HTTPS_PROXY=$proxy_host \
			all_proxy=$proxy_host \
			ALL_PROXY=$proxy_host \
			no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,192.168.0.0/16,10.0.0.0/8"
		;;
	unset)
		unset \
			http_proxy \
			HTTP_PROXY \
			https_proxy \
			HTTPS_PROXY \
			all_proxy \
			ALL_PROXY \
			no_proxy
		;;
	status)
		if [[ -n $http_proxy ]]; then
			print -P "proxy set to %F{yellow}$http_proxy%f"
		else
			print -P "no proxy"
		fi
		;;
	esac
}


