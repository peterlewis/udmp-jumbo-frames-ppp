#!/bin/sh
# Which PPP interfaces to monitor?
# You can list multiple interfaces like this
# MINTERFACES="^(ppp0|ppp1|ppp10)$"
MINTERFACES="^(ppp0)$"
# Desired MTU of PPP interfaces
PTARGET=1500
function check_mtu {
    ip link list | grep -E 'ppp.:|ppp..:' | grep 'mtu '$PTARGET > /dev/null;
}
while true; do
  if check_mtu; then
    echo "PPP MTU is configured at "$PTARGET > /dev/null
  else
    echo "Reconfiguring PPP MTU to "$PTARGET > /dev/null
    pinterfaces=$(ls /etc/ppp/peers/)
    for pinterface in $pinterfaces
    do
      if [[ $pinterfaces =~ $MINTERFACES ]]; then
        changes=true
        sed -i 's/ '$(($PTARGET-8))'/ '$PTARGET'/g' /etc/ppp/peers/$pinterface
        einterface=$(grep 'plugin rp-pppoe.so' /etc/ppp/peers/$pinterface | sed 's/plugin rp-pppoe.so //')
        ip link set dev $einterface mtu $(($PTARGET+8))
        # Maybe your PPPoE is over a VLAN and you need this instead
        # ip link set dev $einterface mtu $(($PTARGET+12)) && ip link set dev $einterface.6 mtu $(($PTARGET+8))
        ifconfig $einterface down && ifconfig $einterface up
      fi
    done
    if [[ $changes == "true" ]]; then
      killall pppd
    fi
  fi
  sleep 5
done
