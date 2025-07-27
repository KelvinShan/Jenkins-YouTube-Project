## kubectl apply for necessary files

```sh
kubectl apply -f serviceaccont.yaml
kubectl apply -f rbac.yaml
kubectl apply -f secret.yaml

#Retrieve the token:
kubectl get secret jenkins-token -n default -o jsonpath='{.data.token}' | base64 --decode

#check eks server url
aws eks describe-cluster --name <your-cluster-name> --query 'cluster.endpoint' --output text
```