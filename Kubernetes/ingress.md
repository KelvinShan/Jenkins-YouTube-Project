# Step 1: Create IAM Role using eksctl

```sh
#Download an IAM policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf.
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.0/docs/install/iam_policy.json

#Create an IAM policy using the policy downloaded in the previous step.
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

#Create OIDC provider (eksctl)
cluster_name=<my-cluster>
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
echo $oidc_id

eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve

eksctl create iamserviceaccount \
    --cluster=<cluster-name> \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region <aws-region-code> \
    --approve

```

# Step 2: Install AWS Load Balancer Controller

Add the eks-charts Helm chart repository. AWS maintains this repository on GitHub.

```sh
helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --version 1.13.0

kubectl get deployment -n kube-system aws-load-balancer-controller
```



#   If not working with eksctl Create OIDC provider (AWS Console)

+   Open the Amazon EKS console.
In the left pane, select Clusters, and then select the name of your cluster on the Clusters page.

+   In the Details section on the Overview tab, note the value of the OpenID Connect provider URL.

+   Open the IAM console at https://console.aws.amazon.com/iam/.

+   In the left navigation pane, choose Identity Providers under Access management. If a Provider is listed that matches the URL for your cluster, then you already have a provider for your cluster. If a provider isn’t listed that matches the URL for your cluster, then you must create one.

+   To create a provider, choose Add provider.

+   For Provider type, select OpenID Connect.

+   For Provider URL, enter the OIDC provider URL for your cluster.

+   For Audience, enter sts.amazonaws.com.

+   (Optional) Add any tags, for example a tag to identify which cluster is for this provider.

+   Choose Add provider.
