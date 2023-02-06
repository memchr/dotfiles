function qemu() {
	# set hugepages
	local memsize pages

	if [[ "$@" == *"hugepages"* ]]; then
		memsize=$(echo $@ | grep -oP "\-m\s+\K\w+")
		if [[ -n "$memsize" ]]; then
			pages=$(($(numfmt --to-unit=Mi --from=iec $memsize)/2))
		else
			pages=200
		fi
		command sudo sysctl vm/nr_hugepages=$pages
	fi

	qemu-system-x86_64 \
		-device ich9-intel-hda -device hda-duplex \
		-nic user \
		-device nec-usb-xhci,id=xhci \
		-device usb-tablet,bus=xhci.0 \
		-device virtio-balloon \
		-enable-kvm \
		-cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
		$@

	if [[ "$@" == *"hugepages"* ]]; then
		command sudo sysctl vm/nr_hugepages=0
	fi
}

function qemu-uefi() {
	
	_ovmf_code="${HOME}/var/vm/OVMF_CODE.fd"
	if [[ ! -f ${_ovmf_code} ]]; then
		cp /usr/share/ovmf/x64/OVMF_CODE.fd  "${_ovmf_code}"
	fi
	qemu \
		-bios "${_ovmf_code}"\
		$@
}

# with virgl
function qemu-gl() {
	qemu \
		-device virtio-vga-gl \
		-display gtk,gl=on \
		$@
}
