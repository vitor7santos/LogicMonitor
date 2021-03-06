### - Tegile_IntelliFlash_Disks_API (DataSource)

> Gets Tegile storage disks (API doesn't allow to get their HEALTH status) - Just collecting those for visibility

### - Tegile_IntelliFlash_Events_API (DataSource)

> Fetching events from Tegile Management Array console
> Scope period: Past 24 hours
> Check period: 15 minutes
> Severity: Critical
###### NOTE: This datasource will not be applied until a event is generated by Tegile & any event detected will be active on the console 24 hours

### - Tegile_IntelliFlash_FCStats_API (DataSource)

> Monitors Tegile Fibre Channel IOPS, data throughput and latency.

### - Tegile_IntelliFlash_FCTargets_API (DataSource)

> Monitors Tegile Fibre Channel target(s) status.

### - Tegile_IntelliFlash_Interfaces_API (DataSource)

> Monitors Tegile interface data throughput.

### - Tegile_IntelliFlash_iSCSITargets_API (DataSource)

> Monitors Tegile iSCSI target IOPS, data throughput and latency.

### - Tegile_IntelliFlash_Performance_API (DataSource)

> Monitors Tegile IntelliFlash Performance (per Controller).

### - Tegile_IntelliFlash_Pools_API (DataSource)

> Monitors Tegile Pools usage/performance stats information + Pool disk type statistics (per Disk Type).

### - Tegile_IntelliFlash_ProjectLUNs_API (DataSource)

> Monitors Tegile project LUN performance metrics such as IOPS, data throughput, latency & storage.

### - Tegile_IntelliFlash_Projects_API (DataSource)

> Monitors Tegile project storage/data metrics.
> Tegile Projects are common organizational templates that create logical containers for volumes based on their specific purpose – like virtual desktop images and file shares.

### - Tegile_IntelliFlash_Troubleshooter_API (DataSource)

> Responsible to make sure there's no outstanding issue with the API contact.

### - addCategory_Tegile_API (PropertySource)

> This property source will be applied to Tegile devices that we'll want to grab their metrics (via the API datasources).