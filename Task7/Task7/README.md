
Azure VM and Load Balancer

You must accomplish this task via ARM template and PowerShell scripts: 
 Deploy two Azure VMs (master and slave node) with the following requirements: 
• Add both VM to Availability Set 
• Use managed disk as an OS disk 
• Add 200 GB SSD disk as a Data disk 
• VMs must be in different subnets 
• Add NSG and allow only tcp port 8983 
• Install Solr 6 major version in both nodes on Data disk 
• The master VM should play role Solr Master node
• The slave VM should play role Solr Slave node

2.	Add Public load Balancer: 
• Use Standard sku 
• Add health probe 
• Add to backend pool Solr master and slave nodes 
• Add load balancer rule 

Simulate the node fail and check the Load Balancer configuration.
