IIS HTTPS Configuration

Create a Self-Signed Certificate.
Via ARM template:
Create a VM on Azure with the following configuration:
Add Public IP
Add NSG and allow only 80 and 443 TCP port
Add DSC extension
Via DSC configure https site on port 443 in IIS and use your Self-Signed certificate which you created before.
