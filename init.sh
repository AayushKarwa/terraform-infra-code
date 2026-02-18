#!/bin/bash
set -e
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install nginx -y
sudo systemctl start nginx 
sudo systemctl enable nginx

echo "<h1>Terraform in one shot. </h1>" | sudo tee /var/www/html/index.html