Virtual Network Peering
Create two VM in different Resource Group with the following configuration:
Add Public IP
Set static private IP in both VM
Add NSG and block all inbound traffic except Virtual Network
Allow ICMP inbound traffic in both VM
Vnet configuration:
Create peering between two Virtual Networks Via Azure PowerShell

Try ping private IP from one VM to another, if you get replay everything is Ok. 

