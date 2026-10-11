#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y apache2

systemctl enable --now apache2

cat > /var/www/html/index.html <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>AWS EC2 Auto Scaling Demo</title>
</head>
<body>
  <main>
    <h1>Welcome to the AWS EC2 + ALB + Auto Scaling Project</h1>
    <p>This page is served by Apache on an Ubuntu EC2 instance.</p>
  </main>
</body>
</html>
HTML
