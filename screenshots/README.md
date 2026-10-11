# Screenshots

# DIAGRAM 
             Internet
                 |
                 v
     Application Load Balancer
                 |
                 v
             Target Group
              /       \
             v         v
          EC2-1       EC2-2
             \         /
              Auto Scaling
                   |
             Launch Template
