# Troubleshooting

Common issues and resolutions for the Cloud Native EKS Platform.

## 1. ArgoCD Sync Issues

**Symptom**: Application stuck in `OutOfSync` or `Unknown` state.

**Resolution**:
1. Check ArgoCD UI for specific error messages (e.g., "ImagePullBackOff").
2. Verify the `Target Revision` is correct (e.g., `main` branch).
3. Check the `Application` status:
   ```bash
   kubectl get application fintrack -n argocd -o yaml
   ```
4. If stuck on finalizer, edit the resource and remove the finalizers manually (careful!).

## 2. Pods Pending or Crashing

**Symptom**: Pods are not scheduling or stuck in `CrashLoopBackOff`.

**Resolution**:
1. Check pod events:
   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   ```
2. Check logs:
   ```bash
   kubectl logs <pod-name> -n <namespace>
   ```
3. Verify resource limits vs. node capacity (CPU/Memory). Kyverno might block pods if limits are missing.

## 3. Ingress Not Accessible

**Symptom**: Application URL returns 404 or connection refused.

**Resolution**:
1. Check ingress resource:
   ```bash
   kubectl get ingress -n <namespace>
   ```
2. Verify ALB exists and targets are healthy in AWS Console.
3. Check Ingress Controller logs:
   ```bash
   kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
   ```

## 4. Terraform Apply Fails

**Symptom**: `terraform apply` errors out.

**Resolution**:
1. Check error message carefully. Often due to existing resources or permissions.
2. If state lock issue:
   ```bash
   terraform force-unlock <lock-id>
   ```
3. If specific resource failure, taint and re-apply (use with caution):
   ```bash
   terraform taint <resource_address>
   terraform apply
   ```
