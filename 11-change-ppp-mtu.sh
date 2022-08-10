#!/bin/bash
# Which PPP interfaces to monitor?
# You can list multiple interfaces like this
# MINTERFACES="(ppp0|ppp1|ppp10)"
MINTERFACES="(ppp0)"
# Desired MTU of PPP interfaces
PTARGET=1500

function check_mtu {
    ip link list | grep -E $MINTERFACES | grep 'mtu '$PTARGET > /dev/null
}

while true; do
    if check_mtu; then
      echo "PPP MTU is configured at "$PTARGET > /dev/null
    else
      # An interface has the wrong MTU, or doesnt exist/isnt up! To the batcave...
      echo "Checking interfaces as no correctly configured PPP interface exists" > /dev/null
      # Start by getting all ppp interfaces configured in the system
      pinterfaces=$(ls /etc/ppp/peers/)
      for pinterface in $pinterfaces
      do
        # Check to see if this is an interface we should be monitoring for MTU
        if [[ $pinterface =~ $MINTERFACES ]]; then
          # Check to see if we need to update the config file
          pmtu=$(grep $(($PTARGET-8)) /etc/ppp/peers/$pinterface)
          if [[ $pmtu ]]; then
            echo Updating config file for $pinterface > /dev/null
            # We will be making some changes, set this flag
            changes="true"
            # Update MTU in ppp interface config file
            sed -i 's/ '$(($PTARGET-8))'/ '$PTARGET'/g' /etc/ppp/peers/$pinterface
          fi
          # Determine eth interface associated with ppp interface
          einterface=$(sed -n 's/plugin rp-pppoe.so \(.*\)/\1/p' /etc/ppp/peers/$pinterface)
          # Check if we need to change the ethernet MTU instead of just blindly taking interfaces up and down
          emtu=$(ip link show $einterface | head -n1 |sed 's/.*mtu \([0-9]\{4\}\).*/\1/')
          # Current ethernet MTU is incorrect so needs changing
          if [[ $emtu -lt $(($PTARGET+8)) ]] ; then
            # Use +12 in above command if PPPoE over VLAN
            echo Reconfiguring ethernet MTU to $(($PTARGET+8)) for $einterface > /dev/null
            # We will be making some changes, set this flag
            changes="true"
            # Set eth interface MTU to ppp interface MTU + 8
            # This works for straight PPPoE as used in UK broadband
            ip link set dev $einterface mtu $(($PTARGET+8))
            # Maybe your PPPoE is over a VLAN and you need this instead, like in Norway
            # ip link set dev $einterface mtu $(($PTARGET+12)) && ip link set dev $einterface.6 mtu $(($PTARGET+8))
            # Bring interface down and up to apply changes
            ip link set $einterface down && ip link set $einterface up
          fi
        fi
      done
      if [[ $changes == "true" ]]; then
        # If we made any changes to config files, send signal to pppd to apply changes
        # This does take down existing ppp links but as pppd comes straight back up, so should the links
        echo Sending SIGHUP to pppd > /dev/null
        killall -SIGHUP pppd
      fi
    fi
  sleep 5
done
