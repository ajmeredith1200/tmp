# aws-cloudwan-prod

WORK IN PROGRESS

## The following elements are implemented in draft state:

Cloud WAN Core |
    Hays ASNs  
    2 regions initially (eu-west-1, eu-central-1)  
    segement 
    attachment policies  
    segment actions  
    nfg

Security MODULE |
    VPC  
    Subnets  
    Attachment to Cloud WAN accross 2 AZs with appliance_mode_support eanbled  
    IGW  
    External subnet route table with default via IGW  
    GWLB subnet route table with default via CNE ARN
    Attachment subnet route tables with default route via the GWLB endpoint within the same AZ
    GWLB and associated listeners, endpoints, target groups and monitoring
    HA Fortigate Firewalls, also configures VM hostname, GENEVE interface and routes back to security VPN to support GENVE tunnels and GWLB monitoring
    Security Groups for internal and external firewall interfaces


