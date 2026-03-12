history
    1  kubectl get pods
    2  aws eks update-kubeconfig   --region us-east-1   --name dev-ap-medium-dev-trial
    3  aws configure
    4  aws eks update-kubeconfig   --region us-east-1   --name dev-ap-medium-dev-trial
    5  kubectl get pods
    6  kubectl get nodes
    7  kubectl top nodes
    8  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    9  kubectl edit deployment metrics-server -n kube-system
   10  kubectl get deployment metrics-server -n kube-system -o yaml > metric.yaml
   11  ls
   12  cat metric.yaml 
   13  nano metric.yaml 
   14  kubectl apply -f metric.yaml 
   15  kubectl rollout restart deployment metrics-server -n kube-system
   16  kubectl get pods -n kube-system | grep metrics
   17  kubectl top nodes
   18  aws eks describe-nodegroup   --cluster-name dev-ap-medium-dev-trial   --nodegroup-name dev-ap-medium-dev-trial-ondemand-nodes   --region us-east-1   --query "nodegroup.resources.autoScalingGroups[*].name"
   19  aws autoscaling create-or-update-tags --tags ResourceId=eks-dev-ap-medium-dev-trial-ondemand-nodes-a8ce6e76-c89c-f55c-a9e9-0f4be11aafab,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/enabled,Value=true,PropagateAtLaunch=true ResourceId=eks-dev-ap-medium-dev-trial-ondemand-nodes-a8ce6e76-c89c-f55c-a9e9-0f4be11aafab,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/dev-ap-medium-dev-trial,Value=true,PropagateAtLaunch=true
   20  aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names eks-dev-ap-medium-dev-trial-ondemand-nodes-a8ce6e76-c89c-f55c-a9e9-0f4be11aafab --query "AutoScalingGroups[].Tags"
   21  nano cluster-autoscaler-policy.json
   22  aws iam create-policy   --policy-name AmazonEKSClusterAutoscalerPolicy   --policy-document file://cluster-autoscaler-policy.json
   23  eksctl create iamserviceaccount   --cluster dev-ap-medium-dev-trial   --namespace kube-system   --name cluster-autoscaler   --attach-policy-arn arn:aws:iam::265870077988:policy/AmazonEKSClusterAutoscalerPolicy   --approve   --region us-east-1
   24  curl -sL https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz | tar xz -C /tmp
   25  sudo mv /tmp/eksctl /usr/local/bin
   26  eksctl version
   27  eksctl create iamserviceaccount   --cluster dev-ap-medium-dev-trial   --namespace kube-system   --name cluster-autoscaler   --attach-policy-arn arn:aws:iam::265870077988:policy/AmazonEKSClusterAutoscalerPolicy   --approve   --region us-east-1
   28  kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
   29  kubectl get deployment cluster-autoscaler -n kube-system
   30  kubectl get deployment cluster-autoscaler -n kube-system -o yaml > cluster-autoscaler.yaml 
   31  kubectl get deployment cluster-autoscaler -n kube-system
   32  kubectl describe deployment cluster-autoscaler -n kube-system
   33  kubectl get deployment cluster-autoscaler -n kube-systemls
   34  ls
   35  cat cluster-autoscaler.yaml 
   36  nano cluster-autoscaler-new.yaml
   37  kubectl apply -f cluster-autoscaler-new.yaml
   38  kubectl get pods -n kube-system | grep autoscaler
   39  kubectl logs -n kube-system deployment/cluster-autoscaler
   40  kubectl describe pod cluster-autoscaler-5c59cfff96-z9tld -n kube-system
   41  nano cluster-autoscaler-new.yaml
   42  kubectl apply -f cluster-autoscaler-new.yaml
   43  nano cluster-autoscaler-new.yaml
   44  kubectl apply -f cluster-autoscaler-new.yaml
   45  kubectl delete pod -n kube-system -l app=cluster-autoscaler
   46  kubectl get pods -n kube-system | grep autoscaler
   47  kubectl describe pod cluster-autoscaler-697d65bfb-l6w8q -n kube-system
   48  kubectl get pods -n kube-system | grep autoscaler
   49  aws eks describe-nodegroup   --cluster-name dev-ap-medium-dev-trial   --nodegroup-name dev-ap-medium-dev-trial-ondemand-nodes   --region us-east-1
   50  history

