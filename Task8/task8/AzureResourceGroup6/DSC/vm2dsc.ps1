Configuration Main
{

    Param ( [string] $nodeName
    )

    Import-DscResource -ModuleName xNetworking
    
    xFirewall Firewall 
    { 
        Name                  = "ICMP enable" 
        DisplayName           = "Firewall Rule for ping" 
        Ensure                = "Present" 
        Enabled               = $true
        Profile               = ("Public", "Private") 
        Direction             = "Inbound"
        Protocol              = "ICMPv4"
        Description           = "Firewall Rule for ping"

    }
} 