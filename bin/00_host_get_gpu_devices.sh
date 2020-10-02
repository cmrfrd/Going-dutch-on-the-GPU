#!/usr/bin/env bash

## Filter nvidia gpus from stdin
function filter_nvidia_gpus_pci {
  grep -E -i 'NVIDIA' | grep -v -i 'audio' | awk '{ print $1 }'
}

## Break PCI info into attributes
function break_PCI_info {

  echo "# GPU PCI information of the form"
  echo "# DOMAIN BUS SLOT FUNCTION"
  DELIM="|"
  echo "export DELIM=\"${DELIM}\""

  count=0
  while read pci_info
  do

      local DOMAIN="0x$(echo $pci_info | cut -f1 -d:)"
      local BUS="0x$(echo $pci_info | cut -f2 -d:)"
      local SLOT_FUNCTION="$(echo $pci_info | cut -f3 -d:)"
      local SLOT="0x$(echo $SLOT_FUNCTION | cut -f1 -d.)"
      local FUNCTION="0x$(echo $SLOT_FUNCTION | cut -f2 -d.)"
      (( count++ ))
      echo "export GPU_${count}=\"${DOMAIN}${DELIM}${BUS}${DELIM}${SLOT}${DELIM}${FUNCTION}\""
  done
}

echo "Saving gpu info in PCI_GPUS.env ..."
lspci -D | filter_nvidia_gpus_pci | break_PCI_info > PCI_GPUS.env
