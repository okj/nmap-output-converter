#!/bin/bash
# Gets unique hosts and ports from nmap files to be used in other tools
# Written by github.com/okj

# Default values
files=()
output="unique"
spaces=false

# Get arguments
while getopts "f:o::h:s" option; do
	case $option in
		h) echo "Help:    -f [nmap file] -o [output file] -s"
		   echo "         -s    Use spaces instead of commas"
		   exit;;
		f) files+=($OPTARG);; # Add to list of files
		o) output=$OPTARG;;
		s) spaces=true;;
	esac
done

for file in ${files}; do
	# Grep keyword -> Remove unnecessary text -> Save to staging file
	cat $file | grep " open " | sed "s/\/.* $PARTITION_COLUMN.*//" >> $output-ports-stage.txt
	cat $file | grep "Nmap scan report for " | sed "s/Nmap scan report for //g" >> $output-hosts-stage.txt
done

# Determine output type
if $spaces; then
	# Get unique lines and save to output
	sort -u $output-ports-stage.txt > $output-ports.txt
	# Print total count
	c=$(wc -l $output-ports.txt | awk '{ print $1 }')
	echo "Created $output-ports.txt with $c unique ports"

	sort -u $output-hosts-stage.txt > $output-hosts.txt
	c=$(wc -l $output-hosts.txt | awk '{ print $1 }')
	echo "Created $output-hosts.txt with $c unique hosts"
else
	# Get unique lines -> Replace newlines with comma  -> Save to output
    sort -u $output-ports-stage.txt | tr '\n' ',' > $output-ports.txt
	# Print total count
	c=$(cat $output-ports.txt | grep -o "," | wc -l)
	echo "Created $output-ports.txt with $c unique ports"
	# Remove trailing comma
	sed -i 's/\(.*\),/\1/' $output-ports.txt

        sort -u $output-hosts-stage.txt | tr '\n' ','  > $output-hosts.txt
        c=$(cat $output-hosts.txt | grep -o "," | wc -l)
        echo "Created $output-hosts.txt with $c unique hosts"
        # Remove trailing comma
        sed -i 's/\(.*\),/\1/' $output-hosts.txt
fi

# Remove staging files
rm $output-ports-stage.txt $output-hosts-stage.txt
