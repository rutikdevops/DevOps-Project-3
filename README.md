# DevOps-Project-3
- Deploy Website on Kubernetes Cluster using Dockerfile, Ansible-Playbook GitHub & Jenkins
![Developer (2)](https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/d2811528-3968-4b2d-985a-fdef21537fe6)
# Project Overview
- Developer write code and upload on GitHub
- Connect GitHub to Jenkins using Webhook
- I write Dockerfile & Docker Login on Ansible server
- Push Docker Image to DockerHub
- Write Ansible Playbook on Ansible Server
- Create Kubernetes Cluster using IAM User, Route53,
- Kubernetes cluster Pull the Image from DockerHub


# Create Kubernetes Cluster on Aws
# Steps :-
- Create VM
- CLI configure on created VM
- Create IAM Role and give access to ec2, S3, Route53, IAM and then attach these to ec2

# Create VM for Kubernetes Cluster
- Create IAM role-> Roles-> Create Role-> ec2-> Next-> Give below Access-> Role Name=Jenkins-kubernetes-project
<img width="700" alt="image" src="https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/62e05533-f086-4248-b5be-d6a14bd64a8c">

# Create ec2 instance name as controller-machine and attach to created IAM role
- CLI cinfiguration is already configured in AWS (only already congigured in AWS instance)
<img width="520" alt="image" src="https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/07100536-83ca-4d60-b4d1-e957780d97ec">

# KoPS Installation in AWS
- Refer this link- https://kubernetes.io/docs/setup/production-environment/tools/kops/ 
- Install Kubectl on linux
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```
- Make the kubectl binary executable
```bash
chmod +x ./kubectl  
```
- move th binary in your path
```bash
mv ./kubectl /bin/kubectl
kubectl
```
- Install kops
```bash
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
```
- Make the kops binary executable
```bash
chmod +x kops-linux-amd64
```
- Move the kops binary in to your PATH.
```bash
sudo mv kops-linux-amd64 /bin/kops
```


# Create a route53 domain for your cluster
- Route53-> create hosted zone-> Domain Name=rutikdevops.in-> Private hosted zone-> region=mumbai-> vpc=select available-> create
<img width="960" alt="image" src="https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/9623c4e8-b3d5-473e-a736-84e6d955b946">

# Create an S3 bucket to store your clusters state 
```bash
aws s3 mb s3://clusters.dev.rutikdevops.in
export KOPS_STATE_STORE=s3://clusters.dev.rutikdevops.in
```
# Build your cluster configuration
```bash
ssh-keygen
kops create cluster --cloud=aws --zones=ap-south-1b --name=clusters.dev.rutikdevops.in --dns-zone=rutikdevops.in --dns-private
kops update cluster --name clusters.dev.rutikdevops.in --yes
// Now cluster is ready it will take 10 minutes to ready
kubectl get nodes     // for checking
```


# create jenkins server
- install plugin = publish over ssh
```bash
passwd root
vi /etc/ssh/sshd_config    // do required changes
systemctl restart sshd
```
- system config-> add ssh
<img width="949" alt="image" src="https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/98dd64b0-6bc9-493e-b200-061d4edf5c35">


# create Ansible server
```bash
passwd root
vi /etc/ssh/sshd_config    // do required changes
systemctl restart sshd
```
- system config-> add ssh
<img width="959" alt="image" src="https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/182aeadd-2153-49f5-b47b-3d694daa0a92">

# Master node is linked with controller machine
- Ansible server
```bash
ssh-keygen
cd .ssh/
vim id_rsa.pub     //copy key
```
- Cluster server
```bash
cd .ssh/
vim authorised_key   //paste key here
```
- Ansible server
```bash
ssh root@(paste here controller machine private ip)
exit
```

- Ansible server
```bash
yum install docker -y
systemctl start docker
systemctl enable docker
systemctl status docker
```
- passwdless connection jenkins to ansible
- jenkins server
```bash
ssh-keygen
cd .ssh/
vim id_rsa.pub     //copy key
```
- ansible server
```bash
cd .ssh/
vim authorised_key   //paste key here
```
- jenkins server
```bash
ssh root@(paste here private ip of ansible)
```

- ansible server
```bash
docker login
```

- ansible server
```bash
cd /opt/
vim ansible.yml
- hosts: all
  become: true

  tasks:
    - name: create new deployment
      command: kubectl apply -f /opt/deployment.yml

    - name: create new service
      command: kubectl apply -f /opt/service.yml
```



- Controller-machine server
```bash
cd /opt/
vim deployment.yml
apiversion: apps/v1
kind: Deployment
metadata:
  name: rutikdevops
spec:
  selector:
    matchLabels:
      app: rutikdevops
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: rutikdevops
    spec:
      containers:
      - name: rutikdevops
        image: rutikdevops/kubernetesproject
        imagePullPolicy: Always
        ports:
        - containerPort: 80
```

- Controller-machine server
```bash
cd /opt/
vim service.yml
apiversion: v1
kind: service
metadata:
  name: rutikdevops
  labels:
    app: rutikdevops
spec:
  selector:
    app: rutikdevops
  type: LoadBalancer
  ports:
    - port: 8080
      targetPort: 80
      nodePort: 31200
```



- Ansible server
```bash
yum install ansible -y
vim /etc/ansible/hosts/
[kube]
paste here controller machine private ip
```

- create git repo and create Dockerfile in this repo
- connect github to webhook
```bash
FROM centos:latest
MAINTAINER rutikkapadnis123@gmail.com
RUN yum install -y httpd \
zip \
unzip 
ADD https://www.free-css.com/assets/files/free-css-templates/download/page258/beauty.zip /var/www/html/
WORKDIR /var/www/html
RUN unzip beauty.zip
RUN cp -rvf beauty/* .
RUN rm -rf beauty.zip 
CMD ["/usr/sbin/httpd", "-D",  "FOREGROUND"]
EXPOSE 80 
```


- jenkins-> new project-> name is same as image name mentioned in dockerfile i.e. kubernetesproject
- jenkins-server
```bash
yum install git -y
```

<img width="688" alt="image" src="https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/65de2810-d0bd-482b-a7d9-c1735075f5e3">
<img width="680" alt="image" src="https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/f46f9664-0f9c-45af-bcb3-ede91494cac3">
![image](https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/5a015a62-cb99-491b-b4d3-d18eeea1c781)
![image](https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/225efb22-01cc-4d0a-a2d6-a2b533cdcbba)
![image](https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/fb964cf6-c597-42ea-8382-b9f01737152d)


- controller machine server
```bash
kubectl get all
```
<img width="550" alt="image" src="https://github.com/rutikdevops/DevOps-Project-3/assets/109506158/10cfeb64-2acd-40a5-b11a-245bf694d01c">









































