# UDMP Monitor PPP MTU

UDMP Monitor PPP MTU is a shell script that checks the PPP WAN interfaces on a UDM Pro and sets the MTU to 1508. This effectively adds support for RFC4638 (baby jumbo frames) as used by many DSL ISPs in Europe. The script is forked from UDMP Monitor MTU at https://github.com/kalenarndt/udmp-jumbo-frames. This runs every 5 seconds but can be modified if you change the sleep values in the script.

## Pre-Requisites
UDMP Monitor PPP MTU has to have the Boot script installed from this repo https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script


## Installation

1. Place the 10-monitor-ppp-mtu.sh in /mnt/data/on_boot.d/ folder and mark it as executable
2. Customise the 11-change-ppp-mtu.sh script to reflect your configuration - the defaults work well if all your PPP interfaces are FTTC and FTTP in the UK.
3. Place the 11-change-ppp-mtu.sh in the /mnt/data folder and mark it as exectable

```bash
chmod +x /mnt/data/on_boot.d/10-monitor-ppp-mtu.sh
chmod +x /mnt/data/11-change-ppp-mtu.sh
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
