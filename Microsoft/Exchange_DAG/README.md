
### - Microsoft_Exchange_DAG_Metrics (DataSource)

> -Monitors the 'ContentIndexState' per DB & the respective state of copy operation
> -Makes use of 'Exchange Server PowerShell' so the user (msexchange.user) needs to have permissions to use it accordingly
> -Script to run needs have 'RemoteSigned' permission
> -'system.displayname' prop needs to be in DNS (otherwise it'll not work)

> Supported devices:
> -
> - Windows Exchange server(s)

> WIKI:
> -
> [Powershell Remoting](https://docs.microsoft.com/en-us/powershell/exchange/connect-to-exchange-servers-using-remote-powershell?view=exchange-ps)
> [Exchange Powershell](https://docs.microsoft.com/en-us/powershell/exchange/open-the-exchange-management-shell?view=exchange-ps)