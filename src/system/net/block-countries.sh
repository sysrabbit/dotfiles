#!/usr/bin/env sh

# This script is used to keep entire countries blocked with up-to-date lists of
# ip ranges.

# Ensure the blocklist has been removed as a source for drop
DROP_SOURCES=($(firewall-cmd --zone=drop --list-sources))
for ipset in "${DROP_SOURCES[@]}"; do
    echo drop ipset: $ipset
    if [ $ipset == "country-blocklist" ]; then
        firewall-cmd --permanent --zone=drop --remove-source $ipset
        break;
    fi
done

# Delete existing ipset
IPSETS=($(firewall-cmd --get-ipsets))
for ipset in "${IPSETS[@]}"; do
    echo ipset: $ipset
    if [ $ipset == "country-blocklist" ]; then
        firewall-cmd --permanent --delete-ipset $ipset
        break;
    fi
done

# Reload to write changes
firewall-cmd --reload

# Create a new ipset
firewall-cmd --permanent --new-ipset=country-blocklist --type=hash:net --option=family=inet --option=hashsize=4096 --option=maxelem=200000

# Download list of countries
mapfile -t COUNTRIES < countries.txt

mkdir -p /tmp/zones
for country in ${COUNTRIES[*]}; do
    wget -P /tmp/zones/ http://www.ipdeny.com/ipblocks/data/countries/$country.zone
done

# Add countries to blocklist
for zone in /tmp/zones/*.zone; do
    firewall-cmd --permanent --ipset=country-blocklist --add-entries-from-file=$zone
done

# Direct blocklist to drop zone
firewall-cmd --permanent --zone=drop --add-source ipset:country-blocklist
firewall-cmd --reload
