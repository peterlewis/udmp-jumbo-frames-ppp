# UDMP Monitor PPP MTU

UDMP Monitor PPP MTU is a shell script that checks the PPP WAN interfaces on a UDM Pro and sets the MTU to 1508 (or higher as configured). This effectively adds support for RFC4638 (baby jumbo frames) as used by many DSL ISPs in Europe. The script is forked from UDMP Monitor MTU at https://github.com/kalenarndt/udmp-jumbo-frames. This runs every 5 seconds but can be modified if you change the sleep values in the script.

The script is persistent, so the MTU changes should stay in place despite configuration changes from the GUI or system reboots. It can cope with PPPoE delivered over a VLAN, and can handle multiple PPP interfaces with differing MTU as required.

## Pre-Requisites
UDMP Monitor PPP MTU has to have the Boot script installed from this repo https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script


## Installation

1. Place the 10-monitor-ppp-mtu.sh in /mnt/data/on_boot.d/ folder and mark it as executable
2. Customise the 11-change-ppp-mtu.sh script to reflect your configuration - the defaults work well if all your PPP interfaces are FTTC and FTTP in the UK.
3. Place the 11-change-ppp-mtu.sh in the /mnt/data folder and mark it as exectable

```bash
mkdir -p /mnt/data/change-ppp-mtu
curl -Lo /mnt/data/on_boot.d/10-monitor-ppp-mtu.sh https://raw.githubusercontent.com/TotalGriffLock/udmp-jumbo-frames-ppp/main/10-monitor-ppp-mtu.sh
curl -Lo /mnt/data/change-ppp-mtu/11-change-ppp-mtu.sh https://raw.githubusercontent.com/TotalGriffLock/udmp-jumbo-frames-ppp/main/11-change-ppp-mtu.sh
chmod +x /mnt/data/on_boot.d/10-monitor-ppp-mtu.sh
chmod +x /mnt/data/change-ppp-mtu/11-change-ppp-mtu.sh
```
The change will take effect on reboot, or you can kick it off by running:
```
/mnt/data/on_boot.d/10-monitor-ppp-mtu.sh
```
## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
