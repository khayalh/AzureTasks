                Application Gateway

Via ARM template and Azure PowerShell:
•	Create two Virtual Machine
•	Configure default website on both VM
•	Add NSG and allow only port 80 and 443 for both VM
•	Add Application Gateway
•	Change Application Gateway firewall mode to Protected
•	Add HTTP listener
•	Add HTTP rule
•	Enable cookie-based session affinity feature
•	Add both VM to backend pool
Try to access your site through Application Gateway public IP addess name. 