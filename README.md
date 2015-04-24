# oui.sh
oui.sh Version: 1.3
usage: 
    oui.sh check|force|clean|lookup [MAC]

This script will download a copy of the OUI database from
the IEEE, format it, and search it for MAC address vendors.

The available arguments as of version 1.3 are as follows:

    check      	- Check for and create OUI file
    force      	- Force an update of OUI file
    clean      	- Remove all created files
    lookup [MAC]- Lookup a MAC's vendor
    
MACs can be formatted as either "xx:xx:xx:xx:xx:xx" or "xx-xx-xx-xx-xx-xx".

The MAC is cut to the first 8 characters, then we search the formtated
list of MAC vendors with that string.
