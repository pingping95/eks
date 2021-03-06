# 수정, 보완중...........

vpc, eks, .. 공식 모듈 없이 terraform으로 설치를 진행해보았다.

- 주의할 점 : variables.tf에 account_id는 본인것으로 설정해주어야 한다.

# 1. 아키텍쳐

# 2. Working Directory

```jsx
$ tree
.
├── bastion.tf
├── eks_cluster.tf
├── eks_cluster_sg.tf
├── eks_worker.tf
├── eks_worker_sg.tf
├── iam_policy.tf
├── iam_role.tf
├── provider.tf
├── variables.tf
└── vpc.tf

0 directories, 10 files
```

## 파일 설명

- [bastion.tf](http://bastion.tf) : demo_eks VPC 내부 작업용 bastion 서버에 대한 tf 파일
- eks_cluster.tf : eks 클러스터 생성
- eks_cluster_sg.tf : eks 클러스터의 보안 그룹 생성
- eks_worker.tf : eks 워커 노드 생성
- eks_worker_sg.tf : eks 워커 노드의 보안 그룹 생성
- iam_policy.tf : iam 정책 ( EKSAutoscailerPolicy, ALBIngressControllerPolicy ) 생성
- iam_role.tf : eks_cluster_role과 eks_worker_role을 정의
- [provider.tf](http://provider.tf) : aws provider 정의
- [variables.tf](http://variables.tf) : 변수 정의
- [vpc.tf](http://vpc.tf) : vpc 내부 리소스들 ( vpc, subnet, route table, .. ) 생성

# 테스트

- aws configure을 통한 자격 증명이 되어 있어야 하며, aws-iam-authenticator가 설치되어 있어야 한다.

```bash
# 
$ terraform init

# 계획
$ terraform plan

# terraform apply로 인프라 배포
$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
..
..
..
aws_eks_node_group.eks_worker: Creation complete after 2m19s [id=eks_demo:worker]

Apply complete! Resources: 38 added, 0 changed, 0 destroyed.

Outputs:

endpoint = "https://..
..
..

# 아래 3개가 설치되어 있어야 함
# aws-iam-authenticator
# kubectl
# aws cli

# 아래 명렁어가 잘 수행되어야 함
$ aws sts get-caller-identity

$ aws eks --region ap-northeast-2 update-kubeconfig --name eks_demo
Added new context arn:aws:eks:ap-northeast-2:<<account_id>>:cluster/eks_demo to /home/user/.kube/config

# 192.168.11.0/24 : private subnet 대역
$ kubectl get nodes
NAME                                               STATUS   ROLES    AGE   VERSION
ip-192-168-11-15.ap-northeast-2.compute.internal   Ready    <none>   38m   v1.18.9-eks-d1db3c
```

### 간단한 테스트 : worker group size 증가시키기
```bash
$ terraform apply
..
..
Terraform will perform the following actions:

  # aws_eks_node_group.eks_worker will be updated in-place
  ~ resource "aws_eks_node_group" "eks_worker" {
        id              = "eks_demo:worker"
        tags            = {
            "Name" = "worker"
        }
        # (14 unchanged attributes hidden)

      ~ scaling_config {
          ~ desired_size = 1 -> 2
          ~ max_size     = 1 -> 2
          ~ min_size     = 1 -> 2
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes



$ kubectl get nodes
NAME                                                STATUS     ROLES    AGE   VERSION
ip-192-168-11-15.ap-northeast-2.compute.internal    Ready      <none>   45m   v1.18.9-eks-d1db3c
ip-192-168-12-166.ap-northeast-2.compute.internal   Ready   <none>   5s    v1.18.9-eks-d1db3c

$ kubectl get all -n kube-system
NAME                           READY   STATUS    RESTARTS   AGE
pod/aws-node-mqpwr             1/1     Running   0          35s
pod/aws-node-msxdw             1/1     Running   0          45m
pod/coredns-6fb4cf484b-ws6q2   1/1     Running   0          48m
pod/coredns-6fb4cf484b-x9rfj   1/1     Running   0          48m
pod/kube-proxy-b4d2g           1/1     Running   0          35s
pod/kube-proxy-rfdlm           1/1     Running   0          45m

NAME               TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
service/kube-dns   ClusterIP   10.100.0.10   <none>        53/UDP,53/TCP   49m

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/aws-node     2         2         2       2            2           <none>          49m
daemonset.apps/kube-proxy   2         2         2       2            2           <none>          49m

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/coredns   2/2     2            2           49m

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/coredns-6fb4cf484b   2         2         2       48m
```

# 보완할 점

1. 모듈화 할 것 ( 다른 프로젝트에서 모듈화를 진행할 것이다. )
2. worker 인스턴스 Name 태그 붙일 것 ( 각 워커에 -1, -2, .. 등을 할 수 있다면 좋을 것 같음 )
3. 어떻게 클러스터에 접근하는지 원리에 대해 좀 더 파악할 것
4. ALB Ingress, ELB, Autoscaling Group 등이 어떻게 EKS Cluster 내에서 동작하는지 파악
5. EKS 내부 IAM에 대해서 공부
6. Service Account와 RBAC, RBAC Binding 등에 대해서 좀 더 학습 → 추후 developer, admin 계정 등을 부여할 때 관리하는 것도 고려
7. 모니터링, 로깅, Jenkins CI/CD 파이프라인 등은 어떻게 구성할 지 좀 더 학습
8. ECR도 가능하면 구성할 것