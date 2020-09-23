### - STP_Topology_Change (DataSource)

> Retrieves the last TCN (Topology Change) per vlan
> Supports SNMPv2/v3

###### Making use of the MIBs below:
- BRIDGE-MIB (dot1dStpTimeSinceTopologyChange OID)
- ciscoVtpMIB (vtpVlanEntry OID)

##### NOTES:
- When monitoring a SNMPv3 device, 'vlan-' context needs to be allowed for the user/group in question - example below 
    ```
    - Cisco device:
        snmp-server group <group> v3 <authType> context vlan- match prefix
    ```        
    [WIKI](https://community.cisco.com/t5/network-management/multiple-snmp-v3-command-to-type-at-one-time/m-p/1475610#M70892) - Extracted from there


##### Future Developments:

  - Develop compatibility with non-Cisco devices (since we're using Cisco MIBs as of now - for the VLANs)