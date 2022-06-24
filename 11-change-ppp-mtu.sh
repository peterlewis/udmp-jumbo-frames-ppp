#!/bin/sh
# Which PPP interfaces to monitor?
# You can list multiple interfaces like this
# MINTERFACES="(ppp0|ppp1|ppp10)"
MINTERFACES="(ppp0)"
# Desired MTU of PPP interfaces
PTARGET=1500
function check_mtu {
    ip link list | grep -E $MINTERFACES | grep 'mtu '$PTARGET > /dev/null;
}
while true; do
  if check_mtu; then
    echo "PPP MTU is configured at "$PTARGET > /dev/null
  else
    # An interface has the wrong MTU! To the batcave...
    echo "Reconfiguring PPP MTU to "$PTARGET > /dev/null
    # Start by getting all ppp interfaces configured in the system
    pinterfaces=$(ls /etc/ppp/peers/)
    for pinterface in $pinterfaces
    do
      # Check to see if this is an interface we should be monitoring for MTU
      if [[ $pinterfaces =~ $MINTERFACES ]]; then
        # We will be making some changes, set this flag
        changes=true
        # Update MTU in ppp interface config file
        sed -i 's/ '$(($PTARGET-8))'/ '$PTARGET'/g' /etc/ppp/peers/$pinterface
        # Determine eth interface associated with ppp interface
        einterface=$(sed -n 's/plugin rp-pppoe.so \(.*\)/\1/p' /etc/ppp/peers/ppp0)
        # Set eth interface MTU to ppp interface MTU + 8
        # This works for straight PPPoE as used in UK broadband
        ip link set dev $einterface mtu $(($PTARGET+8))
        # Maybe your PPPoE is over a VLAN and you need this instead, like in Norway
        # ip link set dev $einterface mtu $(($PTARGET+12)) && ip link set dev $einterface.6 mtu $(($PTARGET+8))
        # Bring interface down and up to apply changes
        ifconfig $einterface down && ifconfig $einterface up
      fi
    done
    if [[ $changes == "true" ]]; then
      # If we made any changes to config files, kill pppd to apply changes (it gets restarted automatically)
      # This does take down existing ppp links but as pppd comes straight back up, so should the links
      killall pppd
    fi
  fi
  sleep 5
done
