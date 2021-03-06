# 수정중... ( 미완성 )
- 보완해야 할 내용
1. worker group의 name tag
2. ACM 인증에서 진행이 안됨... 안되면 route53 관련 부분은 수동으로 할까 생각중
3. route53, acm 학습 미흡

# Requirements
1. AWS Account and IAM 계정

2. Terraform CLI, AWS CLI

3. Terminal ( 필자는 Windows 10이므로 WSL2를 설치하여 진행하였습니다. )

4. IAM Credentials를 환경변수 혹은 aws configure 명령어로 자격 증명 설정할 것
```bash
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
AWS_DEFAULT_REGION=ap-northeast-2

or

aws configure
AWS Access Key ID [None]: (( Your-Access-Key ))
AWS Secret Access Key [None]: (( Your-Secret-Access-key ))
Default region name [None]: ap-northeast-2
Default output format [None]:
```

- 아래와 같이 IAM 자격 증명 설정
```bash
$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************WAYM shared-credentials-file
secret_key     ****************f8zy shared-credentials-file
    region           ap-northeast-2      config-file    ~/.aws/config
```

5. bastion 접속용 keypair 생성

```bash
$ ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/test-eks-bastion" -N "" 
Generating public/private rsa key pair.
Your identification has been saved in /home/user/.ssh/test-eks-bastion
Your public key has been saved in /home/user/.ssh/test-eks-bastion.pub
The key fingerprint is:
SHA256:SSeCQF7UlHBlZ6mbYW8+m0r+MEdYY6MCUul/mTKpqLA user@taehun_kim
The key's randomart image is:
+---[RSA 4096]----+
| .o.==ooo o.     |
| . +.oo. o.      |
|  o.o . o.*      |
|   ... o+O o     |
|     ..oSB.      |
|      =.*.o      |
|.  . . ++o.      |
|... .  o +o.     |
|E.      oo+o     |
+----[SHA256]-----+

$ ls ~/.ssh
test-eks-bastion  test-eks-bastion.pub


```


# 사전 지식

## 1. AWS Node Termination Handler이란?

- Client가 Kubernetes 클러스터에서 EC2 스팟 인스턴스가 제공하는 비용 절감 및 성능 향상 효과를 손쉽게 활용하면서 EC2 스팟 인스턴스의 종료를 정상적으로 처리할 수 있도록 해준다.

- 스팟 인스턴스는 온디맨드 가격보다 최대 90% 할인된 가격으로 이용할 수 있지만 스팟 인스턴스의 특성상 도중에 중단될 수 있다.

- AWS Node Termination Handler는 AWS 인프라에서 Kubernetes 노드로 전달되는 종료 요청 간에 연결을 제공하여 중단 알림을 수신하는 노드를 정상적으로 Draining 및 종료할 수 있도록 한다.

- Kubernetes API를 사용하여 종료 대상이 되는 Draining 및 Cordon 작업을 시작한다. 스팟 종료 요청을 시뮬레이션하여 종료 시에 Kubernetes 애플리케이션이 어떻게 반응하는지를 살펴보는 Node Termination Handler 프로젝트를 구성할 수도 있다.


## 2. 



# Working Directory

- working directory 구조

```
$ tree
.
├── READEM.md
├── bastion.tf
├── eks.tf
├── eks.tfvars
├── iam.tf
├── ingress.tf
├── ingress.tfvars
├── namespace.tf
├── network.tf
├── network.tfvars
├── provider.tf
├── subdomain.tf
├── terraform.tfstate
├── terraform.tfstate.backup
└── variables.tf

0 directories, 15 files
```
- Variables 파일
  - variables.tf  : 변수 설정
  - ~.tfvars      : .tf보다 우선순위가 높은 변수 파일로써, 수동 지정 ( -var-file=~~ )하여 사용
- resource 파일
- eks.tf          : eks 생성 tf 파일
- ingress.tf      : ingress 생성 tf 파일
- network.tf      : network ( vpc, subnet, route table, .. ) 생성 tf 파일
- bastion.tf      : worker node에 접속하기 위한 ec2 bastion 생성 tf 파일
- iam.tf          : EKS Cluster 내부에서 developer group을 위한 RBAC Permission을 세팅한 tf 파일
- namespace.tf    : Cluster 내부에 namespace 생성 tf 파일
- subdomain.tf    : DNS Subdomain을 이용하여 Ingress Gateway가 request들을 특정 Application으로 Routing하도록 하는 tf 파일



## 전체적인 순서
: 전체적인 과정은 Terraform AWS 공식 Module과 아래 Reference 페이지를 참고하여 만들었습니다.



## Result

```bash

# 1. Terraform init
# Module, AWS Provider 및 워크스페이스 세팅
$ terraform init


# 2. Terraform plan
$ terraform plan -var-file ingress.tfvars -var-file network.tfvars -var-file eks.tfvars

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:
..
..
..
..


# 3. 유효성 검사
$ terraform validate

Warning: Version constraints inside provider configuration blocks are deprecated

  on eks.tf line 105, in provider "kubernetes":
 105:   version                = "~> 1.9"

Terraform 0.13 and earlier allowed provider version constraints inside the
provider configuration block, but that is now deprecated and will be removed
in a future version of Terraform. To silence this warning, move the provider
version constraint into the required_providers block.

(and one more similar warning elsewhere)

Success! The configuration is valid, but there were some validation warnings as shown above.


# 4. 테라폼 코드 실행
$ terraform apply -var-file ingress.tfvars -var-file network.tfvars -var-file eks.tfvars

```  







- Ref

https://aws.amazon.com/ko/about-aws/whats-new/2019/11/aws-supports-automated-draining-for-spot-instance-nodes-on-kubernetes/

https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

https://itnext.io/build-an-eks-cluster-with-terraform-d35db8005963