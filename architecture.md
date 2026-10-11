# Architecture notes

```text
Internet
   |
   v
Application Load Balancer (HTTP : 80)
   |
   v
Target Group (HTTP : 80, health check: /)
   |
   +------ EC2 instance managed by ASG
   |
   +------ EC2 instance managed by ASG
   |
   +------ Optional extra instance when scaling occurs
```

## Network/security flow

1. Internet users connect to the public ALB listener.
2. The ALB forwards requests to healthy targets in the target group.
3. The EC2 security group allows HTTP only from the ALB security group.
4. SSH, if required, should be restricted to the administrator's current IP.
5. Use HTTPS and a certificate for a real public deployment.
