#!/bin/bash
# Modified from https://github.com/MS3FGX/Bluelog/blob/master/scripts/gen_oui.sh
VER="1.3"

# Location of tmp file
TMPFILE="/tmp/oui.tmp"

# File to write
OUIFILE="oui.txt"
#------------------------------------------------------------------------------#
ErrorMsg () {
[[ $(expr substr "$2" 1 1) == "n" ]] && echo
if [ "$1" == "ERR" ]; then
	echo "  ERROR: ${2#n}"
	exit 1
elif [ "$1" == "WRN" ]; then
	echo "  WARNING: ${2#n}"
fi
exit 1
}

lookup_mac () {
    OUI="$(echo $1 | cut -c1-8)"
    RESULT="$(grep "${OUI}" oui.txt | cut -d ',' -f2-)"
    if [ "${RESULT}" = '' ]; then
        echo "MAC vendor not found..."
    else 
        echo ${RESULT}
    fi
}

get_oui () {
echo -n "Downloading OUI file from IEEE..."
wget -O $TMPFILE http://standards.ieee.org/develop/regauth/oui/oui.txt || \
	ErrorMsg ERR "Unable to contact IEEE server!"

echo "OK"
}

format_file () {
echo -n "Reformatting..."
# Isolate MAC and manufacturer
grep "(hex)" $TMPFILE | awk '{print $1","$3,$4,$5,$6,$7,$8}' | \
	sed 's/ *$//; /^$/d' > $OUIFILE || \
	ErrorMsg ERR "Unable to reformat file! Is awk/sed installed?"

# Use colon in MAC addresses
sed -i 's/-/:/g' $OUIFILE || \
	ErrorMsg ERR "Unable to format MACs!"

# Remove commas from manufacturer names
sed -i 's/,//g2' $OUIFILE || \
	ErrorMsg ERR "Unable to format manufacturers!"

echo "OK"
}

clean_all () {
echo -n "Removing files..."
rm -f $TMPFILE
rm -f $OUIFILE
echo "OK"
}

# Execution Start
case $1 in
'force')
	clean_all
	get_oui
	format_file
;;
'clean')
	clean_all
;;
'lookup')
    if [ -z "$2" ]; then
        echo "You need to provide a MAC..."
        exit 1
    fi
    # If file doesn't exist
    if [ ! -f $OUIFILE ];
    then
	    get_oui
	    format_file
    fi
    lookup_mac $2
;;
'check')
	# If file doesn't exist
	if [ ! -f $OUIFILE ];
	then
		get_oui
		format_file
		echo "Done."
		exit 0
	fi
	
	# If we get here, it does
	echo "OUI file exists, skipping."
;;
*)
	echo "$0 Version: $VER"
	echo "usage: $0 check|force|clean|lookup [MAC]"
	echo
	echo "This script will download a copy of the OUI database from"
	echo "the IEEE, format it, and search it for MAC address vendors."
	echo
	echo "The available arguments as of version $VER are as follows:"
	echo "check      - Check for and create OUI file"
	echo "force      - Force an update of OUI file"
	echo "clean      - Remove all created files"
        echo "lookup	 - Lookup a MAC's vendor"
esac
#EOF
