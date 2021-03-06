
#!/bin/sh -e
set -x
cd ../../../../utils
    .        ./sys_info.sh
             ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

# display version
swapon -V
print_info $? version

# enable all swaps
swapon -a
print_info $? swapon

# enable swap discards
swapon -d
print_info $? discards

# silently skip devices that do not exist
swapon -s
print_info $? silent

# display summary about used swap devices
swapon -s
print_info $? summary

# setup the priority
swapon -p -2
print_info $? priority

# off the swap
swapoff -a
print_info $? swapoff

# display this help and exit
swapon --help
print_info $? help

