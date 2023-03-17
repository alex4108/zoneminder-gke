### Deploy helm chart

You may need to increase the limits in `values.yaml` as needed.

```
export init_delay_seconds=$(yq -r '.initialDelaySeconds' zoneminder/values.yaml)
helm install ${TF_VAR_env_name} zoneminder/ --values zoneminder/values.yaml --wait --timeout ${init_delay_seconds}s
external_ip=$(kubectl --namespace default get svc ${TF_VAR_env_name} -o json | jq -r '.status.loadBalancer.ingress[].ip')
echo "ZoneMinder should now be available at https://${external_ip}:8443/zm/"
```

At this point, ZoneMinder should be available & ready to go.

The ZoneMinder logs will indicate there were some events - Go ahead and clear these, they're leftover from the startup.

## Cleaning up

Make sure the environment variables you exported earlier are still available.

### Uninstall the helm release

```
helm uninstall ${TF_VAR_env_name}
```