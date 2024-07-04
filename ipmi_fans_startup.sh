#!/bin/bash
#clearLog=true
#noParity=false

# Startup companion script for ipmi_fans_auto.sh
#
# This separate script must run on startup and sets the fan speed mode to "Full Speed Mode"
# Add this to "User Scripts" and set to run 'At Startup of Array'
#
####################
# VERY IMPORTANT: SuperMicro boards -REQUIRE- the fan mode be set to "Full Speed Mode"
# for ipmitool to be able to control fan speeds. If you try to put the required commands 
# from this script at the beginning of ipmi_fans_auto.sh, then your fans will ramp to 
# max speed for a second every single time the script runs to check temperatures.
# That will cause a bunch of annoying sound level changes and prematurely wear out fans.

# Script tailored to work with Supermicro X10SLM-F motherboard, with HDD and Chassis fans connected
# to FAN1234 and CPU fan connected to FANA
# HDD and chassis fans are Scythe KazeFlex II PWM fans - specs: max 1800 RPM +- 10% | min 300 rpm +- 20%
####################
#

# cold reset BMC and wait until it is back online
echo "BMC cold reset to clear any previous state"
ipmitool mc reset cold
#sleep 60

# Wait for the BMC to complete the reset
echo "Waiting for BMC to complete the reset..."
RESET_COMPLETE=false
while ! $RESET_COMPLETE; do
    sleep 30  # Wait 30 seconds before checking the status again
    if ipmitool mc info &> /dev/null; then
        RESET_COMPLETE=true
    else
        echo "BMC is still resetting, please wait..."
    fi
done

echo "BMC reset completed."

# Set IPMI fan mode to "Full Speed Mode"
ipmitool raw 0x30 0x45 0x01 0x01
sleep 5

# Set both fan zones to 50% duty cycle to lower noise
# until the auto script runs to determine final fan speeds
#
# HDD/Chassis Fan Zone duty cycle to 50% - FAN1234
ipmitool raw 0x30 0x70 0x66 0x01 0x00 50
sleep 2
# CPU Fan Zone duty cycle to 50% - FANA
ipmitool raw 0x30 0x70 0x66 0x01 0x01 50

echo "Starting process concluded. In 15 seconds the automatic fan control will be initiated."
sleep 15

