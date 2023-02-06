() {
local color_term
# ansi color code
typeset -grA AC=(
			black 000				red 001				green 002			 yellow 003
			 blue 004			magenta 005				 cyan 006			  white 007
			 grey 008			 maroon 009				 lime 010			  olive 011
			 navy 012			fuchsia 013				 aqua 014			   teal 014
		   silver 015			  grey0 016			 navyblue 017		   darkblue 018
			blue3 020			  blue1 021			darkgreen 022	   deepskyblue4 025
	  dodgerblue3 026		dodgerblue2 027			   green4 028	   springgreen4 029
	   turquoise4 030	   deepskyblue3 032		  dodgerblue1 033		   darkcyan 036
	lightseagreen 037	   deepskyblue2 038		 deepskyblue1 039			 green3 040
	 springgreen3 041			  cyan3 043		darkturquoise 044		 turquoise2 045
		   green1 046	   springgreen2 047		 springgreen1 048 mediumspringgreen 049
			cyan2 050			  cyan1 051			  purple4 055			purple3 056
	   blueviolet 057			 grey37 059		mediumpurple4 060		 slateblue3 062
	   royalblue1 063		chartreuse4 064    paleturquoise4 066		  steelblue 067
	   steelblue3 068	 cornflowerblue 069		darkseagreen4 071		  cadetblue 073
		 skyblue3 074		chartreuse3 076			seagreen3 078		aquamarine3 079
  mediumturquoise 080		 steelblue1 081			seagreen2 083		  seagreen1 085
   darkslategray2 087			darkred 088		  darkmagenta 091			orange4 094
	   lightpink4 095			  plum4 096		mediumpurple3 098		 slateblue1 099
		   wheat4 101			 grey53 102    lightslategrey 103	   mediumpurple 104
   lightslateblue 105			yellow4 106		 darkseagreen 108	  lightskyblue3 110
		 skyblue2 111		chartreuse2 112		   palegreen3 114	 darkslategray3 116
		 skyblue1 117		chartreuse1 118		   lightgreen 120		aquamarine1 122
   darkslategray1 123		  deeppink4 125   mediumvioletred 126		 darkviolet 128
		   purple 129	  mediumorchid3 133		 mediumorchid 134	  darkgoldenrod 136
		rosybrown 138			 grey63 139		mediumpurple2 140	  mediumpurple1 141
		darkkhaki 143	   navajowhite3 144			   grey69 145	lightsteelblue3 146
   lightsteelblue 147	darkolivegreen3 149		darkseagreen3 150		 lightcyan3 152
	lightskyblue1 153		greenyellow 154   darkolivegreen2 155		 palegreen1 156
	darkseagreen2 157	 paleturquoise1 159				 red3 160		  deeppink3 162
		 magenta3 164		darkorange3 166			indianred 167		   hotpink3 168
		 hotpink2 169			 orchid 170			  orange3 172	   lightsalmon3 173
	   lightpink3 174			  pink3 175				plum3 176			 violet 177
			gold3 178	lightgoldenrod3 179				  tan 180		 mistyrose3 181
		 thistle3 182			  plum2 183			  yellow3 184			 khaki3 185
	 lightyellow3 187			 grey84 188   lightsteelblue1 189			yellow2 190
  darkolivegreen1 192	  darkseagreen1 193			honeydew2 194		 lightcyan1 195
			 red1 196		  deeppink2 197			deeppink1 199		   magenta2 200
		 magenta1 201		 orangered1 202		   indianred1 204			hotpink 206
	mediumorchid1 207		 darkorange 208			  salmon1 209		 lightcoral 210
   palevioletred1 211			orchid2 212			  orchid1 213			orange1 214
	   sandybrown 215	   lightsalmon1 216		   lightpink1 217			  pink1 218
			plum1 219			  gold1 220   lightgoldenrod2 222	   navajowhite1 223
	   mistyrose1 224		   thistle1 225			  yellow1 226	lightgoldenrod1 227
		   khaki1 228			 wheat1 229			cornsilk1 230			grey100 231
			grey3 232			  grey7 233			   grey11 234			 grey15 235
		   grey19 236			 grey23 237			   grey27 238			 grey30 239
		   grey35 240			 grey39 241			   grey42 242			 grey46 243
		   grey50 244			 grey54 245			   grey58 246			 grey62 247
		   grey66 248			 grey70 249			   grey74 250			 grey78 251
		   grey82 252			 grey85 253			   grey89 254			 grey93 255
)
# zsh built-in color map
autoload -U colors && colors

case "$TERM" in
xterm-color | *-256color | *-kitty) typeset -g color_term=1 ;;
esac

# colorize command output
if ((color_term)); then
	alias ls='ls --color=tty'
	alias diff='diff --color'
	# grep
	export GREP_COLORS="mt=31;1"
	# cht.sh
	export CHTSH_QUERY_OPTIONS="style=paraiso-dark"
	# grc
	if (( $+commands[grc] )); then
		cmds=(
			blkid configure cvs df dig du env fdisk findmnt free getfacl id
			ioping ip iptables ip6tables iwconfig last lsattr lsblk lsmod lsof
			lspci mount netstat nmap ping ping6 ps sar sensors ss stat sysctl
			tcpdump ulimit uptime vmstat whois
		)
		for cmd in $cmds ; do
			if (( $+commands[$cmd] )) ; then
				alias $cmd="grc $cmd"
			fi
		done
		unset cmd cmds
	fi
	# Take advantage of $LS_COLORS for completion as well.
	zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# syntax highlighting
if ! zstyle -T ':plugin:fast-syntax-highlighting' theme onedark ; then
	fast-theme -q XDG:onedark
fi

# manpager
if (( ${+commands[bat]} )); then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi
}
