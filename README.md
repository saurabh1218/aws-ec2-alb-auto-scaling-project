# AWS EC2 + Application Load Balancer + Auto Scaling

A beginner-friendly AWS hands-on project that demonstrates hosting a website on Ubuntu EC2, routing HTTP traffic through an Application Load Balancer (ALB), checking target health, and managing EC2 capacity with an Auto Scaling Group (ASG).

> **Important:** This repository contains project documentation and setup files. It does not contain your AWS account resources or deploy infrastructure automatically.

## Architecture

```text
                         Internet
                            |
                            v
                 Application Load Balancer
                         HTTP : 80
                            |
                            v
                       Target Group
                      /      |      \
                     v       v       v
                 EC2 ASG 1  EC2 ASG 2  (optional scale-out EC2)
                    |          |
                    +---- Apache web server
                               |
                         index.html website
```

- **EC2** runs the Ubuntu server and Apache web server.
- **User Data** automates the initial web-server setup when an instance launches.
- **Target Group** registers backend instances and performs health checks.
- **Application Load Balancer** receives HTTP requests and forwards them to healthy targets.
- **Auto Scaling Group** maintains the configured number of instances and can change capacity when scaling policies trigger.
- **Security Groups** control which network connections are allowed.

## Project objectives

- Launch an Ubuntu EC2 instance.
- Install Apache and publish a simple HTML page.
- Create an ALB and an HTTP listener on port 80.
- Register EC2 instances in a target group and verify health checks.
- Create a Launch Template and Auto Scaling Group.
- Optionally configure a target-tracking scaling policy.
- Document the setup and testing for a portfolio.

## Repository structure

```text
aws-ec2-alb-auto-scaling-project/
├── README.md
├── .gitignore
├── user-data/
│   └── install-apache.sh
├── website/
│   └── index.html
├── architecture/
│   └── architecture.md
└── screenshots/
    └── README.md
```

## Prerequisites

- An AWS account and access to the EC2 and VPC consoles.
- Basic familiarity with EC2, VPCs, subnets, and security groups.
- An Ubuntu Server AMI available in your chosen AWS Region.
- A suitable VPC with at least two subnets in different Availability Zones for a typical internet-facing ALB setup.
- Awareness that EC2, Application Load Balancer, public IPv4 addresses, storage, and data transfer may incur charges.

## Implementation overview

### 1. Launch an EC2 web server

Launch an Ubuntu EC2 instance in your VPC. For a simple lab, choose an instance type available in your Region and suitable for your workload.

Use `user-data/install-apache.sh` as the instance User Data. User Data normally runs during the instance's initial boot. Editing User Data later does not automatically rerun the script on an existing instance.

### 2. Configure security groups

Recommended traffic flow:

| Resource | Inbound rule | Source |
|---|---|---|
| ALB security group | HTTP / TCP / 80 | `0.0.0.0/0` for a public HTTP demo |
| EC2 security group | HTTP / TCP / 80 | **ALB security group** |
| EC2 security group | SSH / TCP / 22, only if needed | Your current public IP (`My IP`) |

Avoid exposing SSH to `0.0.0.0/0`. For a real deployment, use HTTPS and an appropriate certificate, and restrict access according to your security requirements.

### 3. Create a target group

- Target type: Instances
- Protocol: HTTP
- Port: 80
- Health check protocol: HTTP
- Health check path: `/`

Register the EC2 instance(s). Wait until the targets report `Healthy`.

### 4. Create an Application Load Balancer

- Scheme: Internet-facing
- IP address type: IPv4
- Select the same VPC as the target instances.
- Select suitable subnets in at least two Availability Zones.
- Attach the ALB security group.
- Add an HTTP listener on port 80 and forward its default action to the target group.

Test using the ALB DNS name with `http://` while using the HTTP-only lab configuration.

### 5. Create a Launch Template

Use an Ubuntu Server AMI, a suitable instance type, the EC2 web-server security group, and the User Data script. A Launch Template defines configuration for instances launched by Auto Scaling; it does not automatically adopt an instance that was launched manually.

### 6. Create an Auto Scaling Group

- Choose the Launch Template.
- Select the same VPC and suitable subnets across at least two Availability Zones.
- Attach the existing target group.
- Set minimum, desired, and maximum capacity to values appropriate for the lab and budget.
- Optionally configure a target-tracking policy such as average CPU utilization.
- Enable ELB health checks if you want ASG to use load-balancer health information when evaluating instances.

Example learning configuration (not a universal recommendation):

| Setting | Example |
|---|---:|
| Minimum capacity | 2 |
| Desired capacity | 2 |
| Maximum capacity | 3 |
| CPU target tracking | 50% (optional) |

Scaling is not instantaneous. A policy acts based on metrics and evaluation periods, and an instance must finish bootstrapping and pass health checks before it can serve traffic.

## Testing checklist

- [ ] Apache service is active on each web instance.
- [ ] `curl -I http://localhost` on an instance returns an HTTP success response.
- [ ] Target Group targets become `Healthy`.
- [ ] The ALB DNS name loads the website.
- [ ] ASG has the expected number of managed instances.
- [ ] ASG instances register in the target group and pass health checks.
- [ ] If a scaling policy is configured, verify its configuration and observe metrics; do not generate heavy load just to force scaling in a small lab.

## Troubleshooting

### Website times out
- Confirm the ALB is active and use its DNS name.
- Check the ALB security group allows inbound TCP 80.
- Check the EC2 security group allows TCP 80 **from the ALB security group**.
- Confirm the instance is in the correct VPC and subnet and that routing is correct.

### Target is unhealthy
- Check Apache: `sudo systemctl status apache2`
- Check local response: `curl -I http://localhost`
- Check the target group's health-check path and port.
- Inspect cloud-init output: `sudo cat /var/log/cloud-init-output.log`

### User Data did not install Apache
- Verify the script was supplied as User Data at launch.
- Check `/var/log/cloud-init-output.log`.
- Confirm the instance has network access to package repositories.
- User Data generally runs on first boot; changing it later does not automatically rerun it.

## Cleanup to avoid ongoing charges

After testing:

1. Delete the Auto Scaling Group when you no longer need it. Review the confirmation because managed instances may be terminated.
2. Delete the Application Load Balancer.
3. Remove the target group after it is no longer associated with a load balancer or other resource.
4. Terminate manually launched EC2 instances that are no longer needed.
5. Review Launch Templates, unused EBS volumes, snapshots, Elastic IP addresses, and public IPv4 usage.
6. Check **AWS Billing and Cost Management** for current and any remaining charges.

Stopping EC2 does not stop charges for every associated resource; an ALB and certain storage/network resources can continue to incur charges.


## Resume bullet (use only after you have verified the implementation)

**AWS EC2 Web Application with ALB and Auto Scaling**
- Deployed an Apache web application on Ubuntu EC2 instances and routed HTTP traffic through an Application Load Balancer.
- Configured target-group health checks and an Auto Scaling Group using a Launch Template.
- Documented network security rules, validation steps, and cleanup procedures.

## Disclaimer

This is a learning project, not a production-ready architecture. For production, consider HTTPS, least-privilege access, logging/monitoring, patching, deployment automation, and application-specific availability and security requirements.
