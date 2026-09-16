#! /usr/bin/env bash

# -- User configurable settings --
ROMENTR=$HOME/gtools/hpentr.a
RPLCOMP=rplcomp
SASM=sasm

# Check to make sure we have entries table
if [ ! -e $ROMENTR ]; then
        echo "$0": Error - No $ROMENTR found
        exit
fi

umask 077

echo Assembling rpl..
$RPLCOMP tsync.s __tsync.a __tsync.ext

echo Assembling code..
cat > __tmp.a << EOT
	NIBASC	/HPHP48-R/
	INCLUDE	$ROMENTR
	SETLIST	INCLUDE
	INCLUDE	__tsync.a
	CLRLIST INCLUDE
EOT
if (( $# >= 1 )); then
	$SASM -EH __tmp
	mv __tmp.l __listing
else
	$SASM -EHN __tmp
fi

mv __tmp.o tsync

echo "Cleaning up.."
rm __tsync.a __tmp.a
