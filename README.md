# Smart Task Tracker

This is a simple but smart **Task Tracker** web app built using **Node.js**, **Express**, **MySQL (RDS)**, and **AWS EC2**. It lets you add, view, and delete tasks with a colorful and interactive frontend.

---

## What this project is about

This project is my learning journey into full-stack web development and cloud deployment.  
I built a backend server with Node.js and Express, connected it to a **MySQL RDS** database hosted on AWS, and deployed the backend on an **AWS EC2** instance.  
The frontend is a simple, colorful, and interactive HTML/CSS/JS app served statically from the same server.

---
Tech Stack
Backend: Node.js, Express

Database: MySQL on AWS RDS

Infrastructure: AWS (VPC, EC2, RDS, Security Groups) via Terraform

Deployment: Docker

Region: eu-west-1 (Ireland)
## How to deploy and run the project

### Prerequisites

- AWS account
- Terraform installed (for infrastructure setup)
- Node.js and npm installed on your local machine
- AWS CLI installed and configured with proper permissions

---

### Step 1: Deploy 

1. Build & Push Docker Image
bash
Copy
Edit
cd backend
docker build -t smart-task-tracker .
docker tag smart-task-tracker <your-dockerhub-username>/smart-task-tracker:latest
docker push <your-dockerhub-username>/smart-task-tracker:latest

2. Use the provided Terraform scripts to create:
  - A VPC with subnets and security groups
  - An RDS MySQL database instance
  - An EC2 instance with IAM role allowing S3 access

- Example Terraform commands:

terraform init
terraform apply
Follow prompts to confirm creation.

 Upload your project zip to S3
Zip your project folder locally:

zip -r smart-task-tracker.zip .
Upload smart-task-tracker.zip to your S3 bucket using the AWS console or CLI:



aws s3 cp smart-task-tracker.zip s3://your-bucket-name/deployments/
Step 3: Connect to your EC2 instance
SSH into the EC2 instance using its public IP and key pair:

ssh -i your-key.pem ec2-user@<EC2_PUBLIC_IP>
Step 4: Download and set up your app on EC2
Download your project zip from S3:

aws s3 cp s3://your-bucket-name/deployments/smart-task-tracker.zip .
Unzip it:


unzip smart-task-tracker.zip
cd backend
Install dependencies:


npm install
Step 5: Configure environment variables and start your app
Start the server with your RDS endpoint and password:


DB_HOST=your-rds-endpoint DB_PASSWORD=your-db-password pm2 start server.js --name tasktracker
Replace your-rds-endpoint and your-db-password with actual values.

Step 6: Access your app
Visit in browser:

cpp

http://<EC2_PUBLIC_IP>:3000
You should see your Task Tracker app running!

What I learned
How to build a backend API with Node.js and Express

How to connect to a MySQL database (RDS) from Node.js

How to deploy infrastructure on AWS with Terraform

How to configure EC2 security groups and IAM roles

How to upload and download files using S3

Managing environment variables securely

Using pm2 to keep Node.js apps running on EC2

Docker networking tweaks to connect EC2 and RDS

CIDR conflicts during subnet creation

Next steps for me
Improve frontend UI/UX

Add user authentication

Automate deployment with CI/CD pipelines

Explore serverless options (AWS Lambda)

Thanks for checking out my project!
Feel free to reach out if you want to collaborate or learn together.

Author: halsstech XD
Date: August 2025
