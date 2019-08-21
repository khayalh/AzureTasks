VNet-to-VNet VPN gateway configuration
Create two VM in different Resource Group with the following configuration:
Add Public IP
Set static private IP in both VM
Add NSG and block all inbound traffic except Virtual Network
Allow ICMP inbound traffic in both VM
Additional Configuration:
Create virtual network gateway in both Resource Group
Create VNet-to-VNet VPN gateway connection between Virtual Networks via Azure PowerShell.
Try to ping a private IP from one virtual machine to another, if you get a reply, the task is completed


