# DevOps, GitOps, Kubernetes: My Journey from $x^2 + y^2 = r^2$ and Still Looping

2023-OCT-16, I'm Martin, I've been a _"DevOps"_ ~~whatever it means~~ for a year and a half. On a day-to-day basis, my job consists of writing shell commands inside Kubernetes YAML manifests and ~~more often that I would like~~ extinguish fires.

This job is my first contact with Kubernetes, although I had previous awareness of containers.

I am certainly **not an expert**. The following is not a tutorial, it isn't a list of best practices, it isn't professional advice. Rather, it archives and documents the pitfalls I encounter, decisions I make, and progress I achieve during my upskilling session. Consider it as public note taking.

## We Can't Have Nice Things

Image the dawn of time itself, the 🦕🦕 roam the Earth, people program in assembly, times are harsh. An _Application_ runs on a _Machine_... And ~~only when relied upon, these things are sentient, after all~~ crashes...

> "It works on my machine."

Fast-forward after all efforts to decouple the application from the machine. An _Application_ runs on an _OS_ that operates a _Machine_... And crashes...

> "It works on my OS."

We still thought the application was too close from the machine ~~and because applications started having expectations about the underlying OS~~. An _Application_ runs on _Guest OS_ in a _VM_ on a _Host OS_ that operates the _Machine_... And crashes...

> "It works on my VM."

Virtual machines are getting too slow for our speed greed. En _Application_ runs on _Half An OS_ isolated in a _Container_ sharing its other half with a _Host OS_ that operates the _Machine_... And crashes...

> "It works on my container."

And ~~thank the gods~~ today, an _Application_ runs on _Half An OS_ isolated in its _Container_ wrapped by a _Pod_ part of a _Replica Set_ managed by a _Deployment_ running on _Kubernetes-First OS_ in a _VM_ ~~you really didn't think they'd go away so easily~~ forming a _Cluster_ provisioned in the _Cloud_... And crashes...

> "It works on my cluster."

Thanks to cutting-edge technique, application release management has never been so simple and streamlined.

## Prerequisites

The first thing to have at hand reach when upskilling Kubernetes would be a Kubernetes cluster, right? What about installing a local distribution, such as Docker Desktop, K3D, Minikube, or Kind?

I upskill as part of my full-time job, and I want to keep it closely related to it, hence my wish to use the same environment. Unfortunately, we can't have nice things:

* There are no resources to provision an entire cluster only for one person to play around, so using an corporate OCP cluster is out of question.
* My work laptop is behind VPN and proxy, I lost hope long ago to get Internet connectivity from local containers and VMs.
* Get off the VPN, and I loose access to Teams and Outlook.
* My own toaster couldn't run ~~Crysis~~ a digital clock, let alone a Kubernetes cluster.
* Session on _Play With Kubernetes_ only lasts 4 hours, the site was down when I tried it. Moreover, I would have to create, link up and administrate the nodes, which is not what I'm looking for.
* I could buy a stack of Raspberry Pi, but it also exhibits the same administration burden as _Play With Kubernetes_ ~~and muggins' tight-fisted~~.

Hence my last resort solution: make ~~good~~ use of my corporate Visual Studio Professional subscription and its free Azure credits! Out of the hole, but we still can't have nice things:

* I've been working with Kubernetes for more than a year, now. There is a lot of things I know, a lot of things I think I know ~~but I'm actually wrong, my knowledge is erroneous~~, and a lot of things I don't know... But I've never used Azure, I don't know shit, period.
* Not only to run, but also build and tag container images, I'll have to resort to the cloud, which is less than ideal.

## Azure

Wandering the wonderful land of the Azure Portal, I discovered how to make Microsoft provision clusters for me. 2023-OCT-17, AKS comes in three flavors: the _Kubernetes cluster_, the _Kubernetes cluster with Azure Arc_, and the _AKS hybrid cluster_. In my great ignorance, I chose the option with the least amount of words in it.

Troubles come back when trying to connect to the new cluster.

```ps1
az login
```
```output
A web browser has been opened at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize. Please continue the login in the web browser. If no web browser is available or if the web browser fails to open, use device code flow with `az login --use-device-code`.

AADSTS50076: Due to a configuration change made by your administrator, or because you moved to a new location, you must use multi-factor authentication to access '6c33504c-d67b-4397-90d2-0ee95e75175c'.
Trace ID: 993c5b55-27d5-4468-bc3a-387e32095f4e
Correlation ID: 510624d5-b25b-4ac6-9829-ebe1f28077d1
Timestamp: 2023-10-17 11:49:43Z

Interactive authentication is needed. Please run:
az login
```

~~`az login` failed. Please run `az login`.~~

Of course it is but the conspiracy of my nemesis, the corporate proxy. Fortunaltely, it is possible to circumvent the issue, thanks to `az` honoring `$Env:HTTP_PROXY`.

```ps1
$Env:HTTP_PROXY = "..."
$Env:HTTPS_PROXY = "..."

az login
```
```output
A web browser has been opened at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize. Please continue the login in the web browser. If no web browser is available or if the web browser fails to open, use device code flow with `az login --use-device-code`.

[
  ...
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "d8c186ba-8457-4434-878f-95a10b5e3d4c",
    "id": "2c8d9b0c-0f4d-45ac-b9b4-edfdededdf5c",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Visual Studio Professional Subscription",
    "state": "Enabled",
    "tenantId": "d8c186ba-8457-4434-878f-95a10b5e3d4c",
    "user": {
      "name": "plessym@...",
      "type": "user"
    }
  }
]
```

Amongst the load of JSON spat by the command, I can see my Visual Studio Professional subscription, waiting for its prince charming.

```ps1
az account set --subscription "2c8d9b0c-0f4d-45ac-b9b4-edfdededdf5c" # The ID of the subscription.
```

Now, for connecting to the cluster...

```ps1
az aks get-credentials --resource-group "clusty_group" --name "clusty"
```
```output
The behavior of this command has been altered by the following extension: aks-preview
Merged "clusty" as current context in C:\Users\plessym\.kube\config
```

`oc` is the OCP equivalent of `kubectl`. I use OCP on my day-to-day job, and find that ~~`kubectl` is just the worst keystroke~~ the name is easier to type, so I made an alias.

```ps1
oc get pods -A
```
```output
NAMESPACE         NAME                                       READY   STATUS    RESTARTS   AGE
calico-system     calico-kube-controllers-77cd848cf8-4jkmd   1/1     Running   0          71m
calico-system     calico-node-srwb4                          1/1     Running   0          71m
calico-system     calico-typha-86d99df555-9znp2              1/1     Running   0          71m
kube-system       cloud-node-manager-zwdxm                   1/1     Running   0          72m
kube-system       coredns-789789675-4dv9s                    1/1     Running   0          72m
kube-system       coredns-789789675-x4cd2                    1/1     Running   0          70m
kube-system       coredns-autoscaler-649b947bbd-nv24m        1/1     Running   0          72m
kube-system       csi-azuredisk-node-v8d97                   3/3     Running   0          72m
kube-system       csi-azurefile-node-5brz6                   3/3     Running   0          72m
kube-system       konnectivity-agent-58d88649f4-8kjtr        1/1     Running   0          64m
kube-system       konnectivity-agent-58d88649f4-ckvnf        1/1     Running   0          64m
kube-system       kube-proxy-qnmqc                           1/1     Running   0          72m
kube-system       metrics-server-5bd48455f4-552s5            2/2     Running   0          70m
kube-system       metrics-server-5bd48455f4-tg7gp            2/2     Running   0          70m
tigera-operator   tigera-operator-f5995db8-4ch6m             1/1     Running   0          72m
```

For the sake of systematism, I want to create my clusters using the command line instead of clicking buttons in the web UI.

```ps1
az group create `
  --name "clusty2_group" `
  --location "uksouth"
```
```json
{
  "location": "uksouth",
  "managedBy": null,
  "name": "clusty2_group",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

After multiple tries, especially with the `--node-vm-size` argument, it looks like you HAVE TO fail to get the list of available options, I settled for the arguments below.

```ps1
az aks create `
  --name "clusty2" `
  --resource-group "clusty2_group" `
  --enable-vpa `
  --k8s-support-plan "KubernetesOfficial" `
  --kubernetes-version "1.27.3" `
  --load-balancer-sku "basic" `
  --location "uksouth" `
  --node-count 1 `
  --node-vm-size "standard_b2pls_v2" `
  --tier "free" `
  --vm-set-type "VirtualMachineScaleSets"
```
```output
Argument '--enable-vpa' is in preview and under development. Reference and support levels: https://aka.ms/CLI_refstatus
The behavior of this command has been altered by the following extension: aks-preview

 / Running ..

{
  "aadProfile": null,
  "addonProfiles": null,
  "agentPoolProfiles": [
    {
      "availabilityZones": null,
      "capacityReservationGroupId": null,
      "count": 1,
      "creationData": null,
      "currentOrchestratorVersion": "1.27.3",
      "enableAutoScaling": false,
      "enableCustomCaTrust": false,
      "enableEncryptionAtHost": false,
      "enableFips": false,
      "enableNodePublicIp": false,
      "enableUltraSsd": false,
      "gpuInstanceProfile": null,
      "hostGroupId": null,
      "kubeletConfig": null,
      "kubeletDiskType": "OS",
      "linuxOsConfig": null,
      "maxCount": null,
      "maxPods": 110,
      "messageOfTheDay": null,
      "minCount": null,
      "mode": "System",
      "name": "nodepool1",
      "networkProfile": {
        "allowedHostPorts": null,
        "applicationSecurityGroups": null,
        "nodePublicIpTags": null
      },
      "nodeImageVersion": "AKSUbuntu-2204gen2arm64containerd-202310.04.0",
      "nodeLabels": null,
      "nodePublicIpPrefixId": null,
      "nodeTaints": null,
      "orchestratorVersion": "1.27.3",
      "osDiskSizeGb": 128,
      "osDiskType": "Managed",
      "osSku": "Ubuntu",
      "osType": "Linux",
      "podSubnetId": null,
      "powerState": {
        "code": "Running"
      },
      "provisioningState": "Succeeded",
      "proximityPlacementGroupId": null,
      "scaleDownMode": null,
      "scaleSetEvictionPolicy": null,
      "scaleSetPriority": null,
      "securityProfile": {
        "sshAccess": "LocalUser"
      },
      "spotMaxPrice": null,
      "tags": null,
      "type": "VirtualMachineScaleSets",
      "upgradeSettings": {
        "drainTimeoutInMinutes": null,
        "maxSurge": null
      },
      "vmSize": "standard_b2pls_v2",
      "vnetSubnetId": null,
      "windowsProfile": null,
      "workloadRuntime": "OCIContainer"
    }
  ],
  "apiServerAccessProfile": null,
  "autoScalerProfile": null,
  "autoUpgradeProfile": {
    "nodeOsUpgradeChannel": "NodeImage",
    "upgradeChannel": null
  },
  "azureMonitorProfile": null,
  "azurePortalFqdn": "clusty2-clusty2group-4e65ca-d4f92eaa.portal.hcp.uksouth.azmk8s.io",
  "creationData": null,
  "currentKubernetesVersion": "1.27.3",
  "disableLocalAccounts": false,
  "diskEncryptionSetId": null,
  "dnsPrefix": "clusty2-clusty2group-4e65ca",
  "enableNamespaceResources": null,
  "enablePodSecurityPolicy": false,
  "enableRbac": true,
  "extendedLocation": null,
  "fqdn": "clusty2-clusty2group-4e65ca-d4f92eaa.hcp.uksouth.azmk8s.io",
  "fqdnSubdomain": null,
  "guardrailsProfile": null,
  "httpProxyConfig": null,
  "id": "/subscriptions/4d3ffcff-1616-4e65-bcea-d4f92eaaea83/resourcegroups/clusty2_group/providers/Microsoft.ContainerService/managedClusters/clusty2",
  "identity": {
    "delegatedResources": null,
    "principalId": "48f72951-3f19-4276-8bae-e848eaf6d307",
    "tenantId": "78c2686f-e93d-4cf8-96cf-75a47377a357",
    "type": "SystemAssigned",
    "userAssignedIdentities": null
  },
  "identityProfile": {
    "kubeletidentity": {
      "clientId": "560c647a-98ad-442d-9189-40b3685ac150",
      "objectId": "f1d43816-8b54-4a53-8177-ec07f8ffe616",
      "resourceId": "/subscriptions/4d3ffcff-1616-4e65-bcea-d4f92eaaea83/resourcegroups/MC_clusty2_group_clusty2_uksouth/providers/Microsoft.ManagedIdentity/userAssignedIdentities/clusty2-agentpool"
    }
  },
  "ingressProfile": null,
  "kubernetesVersion": "1.27.3",
  "linuxProfile": {
    "adminUsername": "azureuser",
    "ssh": {
      "publicKeys": [
        {
          "keyData": "ssh-rsa ImlkZW50aXR5UHJvZmlsZSI6IHsKICAgICJrdWJlbGV0aWRlbnRpdHkiOiB7CiAgICAgICJjbGllbnRJZCI6ICI1NjBjNjQ3YS05OGFkLTQ0MmQtOTE4OS00MGIzNjg1YWMxNTAiLAogICAgICAib2JqZWN0SWQiOiAiZjFkNDM4MTYtOGI1NC00YTU/zLTgxNzctZWMwN2Y4ZmZlNjE2IiwKICAgICAgInJlc291cmNlSWQiOiAiL3N1YnNjcmlwdGlvbnMvNGQzZmZ+jZmYtMTYxNi00ZTY1LWJjZWEtZDRmOTJlYWFlYTgzL3Jlc291cmNlZ3JvdXBzL01DX2NsdXN0eTJfZ3JvdXBfY2x1c3R5Ml91a3NvdXRoL3Byb3ZpZGVycy9NaWNyb3NvZnQuTWFuYWdlZElkZW50aXR5L3VzZXJBc3NpZ25lZElkZW50aXRpZ+XMvY2x1c3R5Mi1hZ2VudHBvb2wi= plessym@MARTINPC\n"
        }
      ]
    }
  },
  "location": "uksouth",
  "maxAgentPools": 100,
  "metricsProfile": {
    "costAnalysis": {
      "enabled": false
    }
  },
  "name": "clusty2",
  "networkProfile": {
    "dnsServiceIp": "10.0.0.10",
    "ipFamilies": [
      "IPv4"
    ],
    "kubeProxyConfig": null,
    "loadBalancerProfile": null,
    "loadBalancerSku": "Basic",
    "monitoring": null,
    "natGatewayProfile": null,
    "networkDataplane": null,
    "networkMode": null,
    "networkPlugin": "kubenet",
    "networkPluginMode": null,
    "networkPolicy": "none",
    "outboundType": "loadBalancer",
    "podCidr": "10.244.0.0/16",
    "podCidrs": [
      "10.244.0.0/16"
    ],
    "serviceCidr": "10.0.0.0/16",
    "serviceCidrs": [
      "10.0.0.0/16"
    ]
  },
  "nodeResourceGroup": "MC_clusty2_group_clusty2_uksouth",
  "nodeResourceGroupProfile": null,
  "oidcIssuerProfile": {
    "enabled": false,
    "issuerUrl": null
  },
  "podIdentityProfile": null,
  "powerState": {
    "code": "Running"
  },
  "privateFqdn": null,
  "privateLinkResources": null,
  "provisioningState": "Succeeded",
  "publicNetworkAccess": null,
  "resourceGroup": "clusty2_group",
  "resourceUid": "f2660731a9a5e4126ac56431",
  "securityProfile": {
    "azureKeyVaultKms": null,
    "customCaTrustCertificates": null,
    "defender": null,
    "imageCleaner": null,
    "imageIntegrity": null,
    "nodeRestriction": null,
    "workloadIdentity": null
  },
  "serviceMeshProfile": null,
  "servicePrincipalProfile": {
    "clientId": "msi",
    "secret": null
  },
  "sku": {
    "name": "Base",
    "tier": "Free"
  },
  "storageProfile": {
    "blobCsiDriver": null,
    "diskCsiDriver": {
      "enabled": true,
      "version": "v1"
    },
    "fileCsiDriver": {
      "enabled": true
    },
    "snapshotController": {
      "enabled": true
    }
  },
  "supportPlan": "KubernetesOfficial",
  "systemData": null,
  "tags": null,
  "type": "Microsoft.ContainerService/ManagedClusters",
  "upgradeSettings": null,
  "windowsProfile": null,
  "workloadAutoScalerProfile": {
    "keda": null,
    "verticalPodAutoscaler": {
      "addonAutoscaling": "Disabled",
      "enabled": true
    }
  }
}
```

Now, for connecting to the cluster...

```ps1
az aks get-credentials --resource-group "clusty2_group" --name "clusty2"
```
```output
The behavior of this command has been altered by the following extension: aks-preview
Merged "clusty2" as current context in C:\Users\plessym\.kube\config
```

And cheking everything is running...

```ps1
 oc get pods -A
```
```output
NAMESPACE     NAME                                        READY   STATUS    RESTARTS      AGE
kube-system   azure-ip-masq-agent-m7jvv                   1/1     Running   0             18m
kube-system   cloud-node-manager-xbvpp                    1/1     Running   0             18m
kube-system   coredns-789789675-7h6ww                     1/1     Running   0             19m
kube-system   coredns-789789675-mjlcm                     1/1     Running   0             17m
kube-system   coredns-autoscaler-649b947bbd-qbzdh         1/1     Running   0             19m
kube-system   csi-azuredisk-node-svgpf                    3/3     Running   0             18m
kube-system   csi-azurefile-node-k2648                    3/3     Running   0             18m
kube-system   konnectivity-agent-7cdbf864f5-qktmv         1/1     Running   0             18m
kube-system   konnectivity-agent-7cdbf864f5-tp25c         1/1     Running   0             18m
kube-system   kube-proxy-mzhlf                            1/1     Running   0             18m
kube-system   metrics-server-5bd48455f4-qp48c             2/2     Running   1 (16m ago)   17m
kube-system   metrics-server-5bd48455f4-z7dmz             2/2     Running   0             17m
kube-system   vpa-admission-controller-6cdbf7ccf5-ksplm   1/1     Running   0             17m
kube-system   vpa-admission-controller-6cdbf7ccf5-smkkm   1/1     Running   0             17m
kube-system   vpa-recommender-68c7d59c84-6qp5t            1/1     Running   0             17m
kube-system   vpa-updater-6b4d5dc6bf-gjgxz                1/1     Running   0             17m
```

My passion for automation urges me to put all those `az` command into a `Start-Cluster.ps1` script. I'll create `Stop-Cluster.ps1` and `Enter-Cluster.ps1` on the same principles.

```diff
📁 ..
  📁 .
+   📁 scripts
+     🧾 Enter-Cluster.ps1
+     🧾 Start-Cluster.ps1
+     🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```ps1
param (
  [String] $Name = "clusty"
)

$GroupName = "${Name}_g"

$ExistingGroups = az group list --query "[?name=='$GroupName']" | ConvertFrom-Json

if ($ExistingGroups.Count -ne 0) {
  Write-Host "Cluster already exists." -ForegroundColor "Green"
  Write-Host "Starting cluster..." -ForegroundColor "Yellow"

  az aks start `
    --name $Name `
    --resource-group $GroupName `
    --only-show-errors
} else {
  Write-Host "Creating group..." -ForegroundColor "Yellow"

  az group create `
    --name $GroupName `
    --location "uksouth" `
    --only-show-errors

  Write-Host "Creating cluster..." -ForegroundColor "Yellow"

  az aks create `
    --name $Name `
    --resource-group $GroupName `
    --enable-vpa `
    --k8s-support-plan "KubernetesOfficial" `
    --kubernetes-version "1.27.3" `
    --load-balancer-sku "basic" `
    --location "uksouth" `
    --node-count 1 `
    --node-vm-size "standard_b2pls_v2" `
    --tier "free" `
    --vm-set-type "VirtualMachineScaleSets" `
    --only-show-errors
}
```

## Application

At the essence of the universe, is the application. I'll create a web app, make it simple... Start with a greeter. I'm using .NET ~~nobody is perfect~~ for the only reason that I know it. I'll call this greeter application "Hello".

```ps1
dotnet new create "web" --name "Martin.Hello" --exclude-launch-settings --output "./applications/hello"
```
```output
The template "ASP.NET Core Empty" was created successfully.

Processing post-creation actions...
Restoring C:\Users\plessym\Documents\Martin\docs\applications\hello\Martin.Hello.csproj:
  Determining projects to restore...
  Restored C:\Users\plessym\Documents\Martin\docs\applications\hello\Martin.Hello.csproj (in 104 ms).
Restore succeeded.
```

`dotnet new` created a few files, of which `Program.cs` is the entrypoint of the application.

```diff
📁 ..
  📁 .
+   📁 applications
+     📁 hello
+       🧾 appsettings.Development.json
+       🧾 appsettings.json
+       🧾 Martin.Hello.csproj
+       🧾 Program.cs
    📁 scripts
      🧾 Enter-Cluster.ps1
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```cs
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.Run();
```

We can run the application and be greeted.

```ps1
dotnet run --project "./applications/hello"
```
```output
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5000
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: C:\Users\plessym\Documents\Martin\docs\applications\hello
```

If we point a browser at http://localhost:5000, it will show `Hello World!`, but I don't want to open and fiddle around with my browser all the time, because I'm lazy, so I'll create a `hello.http` file and use [REST Client for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) instead.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 scripts
      🧾 Enter-Cluster.ps1
+     🌐 hello.http
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```http
@BASE_URL = "http://localhost:5000"

GET {{BASE_URL}}
```

Trying that out will slap you back in the face with an unkind error message:

> The connection was rejected. Either the requested service isn’t running on the requested server/port, the proxy settings in vscode are misconfigured, or a firewall is blocking requests. Details: RequestError: connect ECONNREFUSED 127.0.0.1:443.

The silly solution here being to remove the quotes around the value of `@BASE_URL = "http://localhost:5000"`, because we can't have nice things.

```diff
- @BASE_URL = "http://localhost:5000"
+ @BASE_URL =  http://localhost:5000
```

We shalt new proceed to define the behavior of our greeter application:

* On `GET /`, it must respond by `Hello.`, in plain text.
* On `GET /<name>`, it must respond by `Hello, <name>.`, in plain text.

Simple Web API.

To make it happen, we should modify `hello.http`...

```http
@BASE_URL = http://localhost:5000

###############################################################################
# This should return "Hello.", plain-text.

GET {{BASE_URL}}/

###############################################################################
# @prompt NAME
# This should return "Hello, <NAME>.", plain-text.

GET {{BASE_URL}}/{{NAME}}
```

And `Program.cs`...

```diff
  var builder = WebApplication.CreateBuilder(args);
  var app = builder.Build();

- app.MapGet("/", () => "Hello World!");
+ app.MapGet("/", () => "Hello.");
+ app.MapGet("/{name}", (string name) => $"Hello, {name}.");

  app.Run();
```

Restarting the application while developing is becoming quite tedious already, so I should use `dotnet watch run` instead of `dotnet run`.

Now http://localhost:5000/Martin returns `Hello, Martin.`!

If you're committing to Git, you'll notice the `bin` and `obj` folders are massively full of compiler-generated 💩. I'll make myself a `.gitignore` to save my bandwidth.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
+       ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 scripts
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```
bin/
obj/
```

Now that we've got our application, we must build it, and ship it. Easy just press F5, right?Well, no, we need to properly build it, package it, and deploy it. But there is a problem: I never learned how to do that in Uni, I've always pressed F5! Because, remember: we can't have nice things.

For that, I got to pull self-taught ~~self-teaching, really~~ knowledge of ASP.NET app publication, and save it into a script.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 scripts
      🧾 Enter-Cluster.ps1
      🌐 hello.http
+     🧾 Publish-Hello.ps1
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```ps1
dotnet publish "$PSScriptRoot/../applications/hello" `
  --configuration "Release" `
  --no-self-contained `
  --output "$PSScriptRoot/../applications/hello/bin/publish"
```

The default `--configuration` is `Debug`; it has compiler options to output debugging information. The other built-in configuration is `Release`, which has options to make the compiler optimize the code harder.

Self-contained applications bundle the .NET runtime along with your own code. `--no-self-contained` makes a prerequisite for anyone wanting to run my greeter application to install the .NET runtime. Between the ASP.NET Core Runtime, the .NET Desktop Runtime and then .NET Runtime listed on https://dotnet.microsoft.com/en-us/download/dotnet/7.0, this will confuse everyone! Just the ASP.NET one has 7 options to install it on windows! Again, we can't have nice things, I'm just doing my part.


```ps1
& "./scripts/Publish-Hello.ps1"
```
```output
MSBuild version 17.4.1+9a89d02ff for .NET
  Determining projects to restore...
  All projects are up-to-date for restore.
  Martin.Hello -> C:\Users\plessym\Documents\Martin\docs\applications\hello\bin\Release\net7.0\Martin.Hello.dll
  Martin.Hello -> C:\Users\plessym\Documents\Martin\docs\applications\hello\bin\publish\
```

Admire the published results.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        📂 bin
          📂 publish
+           🧾 appsettings.Development.json
+           🧾 appsettings.json
+           🧾 Martin.Hello.deps.json
+           📚 Martin.Hello.dll
+           💾 Martin.Hello.exe
+           🧾 Martin.Hello.pdb
+           🧾 Martin.Hello.runtimeconfig.json
+           🧾 web.config
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 scripts
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Publish-Hello.ps1
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```

The `publish` folder is full of 💩, except the `.exe` file, which we can run to execute our app.

```ps1
& "./applications/hello/bin/publish/Martin.Hello.exe"
```
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5000
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: C:\Users\plessym\Documents\Martin\docs
```

Use `hello.http` to try it out, it works! Of course, it's mine! That feeling wont last for long, though...

Congrat, we now have an app we can run anywhere... Anywhere there is an ASP.NET runtime, that is, because we can't have nice things.

## Container

Create a `Containerfile` for the simplest _Hello World_ command possible.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
+       🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 scripts
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Publish-Hello.ps1
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```Dockerfile
FROM alpine:3.18.0
ENTRYPOINT ["echo", "Hello"]
```

Now, I can't even build images locally: I wouldn't be able to pull the base layers thanks to the corporate proxy I sit behind. Definitely, we can't have nice things... Therefore, I have to build my container images in the cloud as well. I'll use [Kaniko](https://github.com/GoogleContainerTools/kaniko), for the only reason that this is what I'm using at work.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
+   📁 jobs
+     🧾 kaniko.yaml
    📁 scripts
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Publish-Hello.ps1
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: kaniko
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: main
          image: gcr.io/kaniko-project/executor:v1.17.0
          args:
            - --destination=ghcr.io/martin-deploy-2/hello:1
            - --context=git://github.com/martin-deploy-2/docs.git#refs/heads/main
            - --context-sub-path=applications/hello
            - --dockerfile=Containerfile
          volumeMounts:
            - mountPath: /kaniko/.docker/config.json
              name: kaniko-config
              subPath: .dockerconfigjson
      volumes:
        - name: kaniko-config
          secret:
            secretName: martin-deploy-2-ghcr
```

Kaniko needs to be configured, especially with a "context", which serves as a source for building the container image from, and a destination to push the built image to. I'll use the GitHub Container Registry for this. Now, Kaniko will need to authenticate with the GHCR, which means providing it with a GitHub token, mounted into the Kaniko container from a Secret...

But there is no way I will expose one of my precious GitHub tokens in a public repository: you can't have those nice things! Instead, I will resort to [Bitnami's Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets). I downloaded `kubeseal.exe` from the release page, and created an umbrella Helm chart for the controller.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
+   📁 charts
+     📁 bitnami
+       📁 sealed-secrets
+         🧾 Chart.yaml
    📁 jobs
      🧾 kaniko.yaml
    📁 scripts
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Publish-Hello.ps1
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```yaml
apiVersion: v2
type: application

name: sealed-secrets
version: 1.0.0
appVersion: 0.24.2
description: Helm chart for the sealed-secrets controller.
home: https://github.com/bitnami-labs/sealed-secrets
icon: https://bitnami.com/assets/stacks/sealed-secrets/img/sealed-secrets-stack-220x234.png

kubeVersion: ">=1.16.0-0"
dependencies:
  - name: sealed-secrets
    version: 2.13.1
    repository: https://bitnami-labs.github.io/sealed-secrets

keywords:
  - secrets
  - sealed-secrets
```

Then, it was about checking in the wrapper chart's dependency.

```ps1
helm dependency build "./charts/bitnami/sealed-secrets"
```
```output
Getting updates for unmanaged Helm repositories...
...Successfully got an update from the "https://bitnami-labs.github.io/sealed-secrets" chart repository
Saving 1 charts
Downloading sealed-secrets from repo https://bitnami-labs.github.io/sealed-secrets
Deleting outdated charts
```

`helm dependency build` downloads `.tgz` file for each dependency chart, which I won't commit to Git.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
+     ✋ .gitignore
    📁 jobs
      🧾 kaniko.yaml
    📁 scripts
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Publish-Hello.ps1
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```
*.tgz
```

And actually install the chart.

```ps1
helm upgrade "sealed-secrets" "./charts/bitnami/sealed-secrets" --namespace "sealed-secrets"--create-namespace --install --render-subchart-notes --cleanup-on-fail
```
```output
Release "sealed-secrets" does not exist. Installing it now.
NAME: sealed-secrets
LAST DEPLOYED: Fri Oct 20 10:34:27 2023
NAMESPACE: sealed-secrets
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **

You should now be able to create sealed secrets.

1. Install the client-side tool (kubeseal) as explained in the docs below:

    https://github.com/bitnami-labs/sealed-secrets#installation-from-source

2. Create a sealed secret file running the command below:

    kubectl create secret generic secret-name --dry-run=client --from-literal=foo=bar -o [json|yaml] | \
    kubeseal \
      --controller-name=sealed-secrets \
      --controller-namespace=sealed-secrets \
      --format yaml > mysealedsecret.[json|yaml]

The file mysealedsecret.[json|yaml] is a commitable file.

If you would rather not need access to the cluster to generate the sealed secret you can run:

    kubeseal \
      --controller-name=sealed-secrets \
      --controller-namespace=sealed-secrets \
      --fetch-cert > mycert.pem

to retrieve the public cert used for encryption and store it locally. You can then run 'kubeseal --cert mycert.pem' instead to use the local cert e.g.

    kubectl create secret generic secret-name --dry-run=client --from-literal=foo=bar -o [json|yaml] | \
    kubeseal \
      --controller-name=sealed-secrets \
      --controller-namespace=sealed-secrets \
      --format [json|yaml] --cert mycert.pem > mysealedsecret.[json|yaml]

3. Apply the sealed secret

    kubectl create -f mysealedsecret.[json|yaml]

Running 'kubectl get secret secret-name -o [json|yaml]' will show the decrypted secret that was generated from the sealed secret.

Both the SealedSecret and generated Secret must have the same name and namespace.
```

Some of these instruction, I will immediately turn into scripts!

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
      ✋ .gitignore
    📁 jobs
      🧾 kaniko.yaml
    📁 scripts
      🧾 Enter-Cluster.ps1
      🌐 hello.http
+     🧾 Protect-Secret.ps1
      🧾 Publish-Hello.ps1
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```ps1
$BasePath = "$PSScriptRoot/../sealed-secrets"

Get-ChildItem -Path "$BasePath/*.yaml.secret" -File -Name | ForEach-Object {
  $Secret = "$BasePath/$_"
  $SealedSecret = $Secret -replace ".yaml.secret", ".yaml"

  Write-Host "+ Secret: $Secret" -ForegroundColor "Gray"
  Write-Host "  Sealed: $SealedSecret" -ForegroundColor "Gray"

  $Utf8NoBom = New-Object System.Text.UTF8Encoding $false

  # Using [System.IO.File]::WriteAllLines here because Powershell's >> encodes output in UTF8 with BOM, because we can't have nice things, which then breaks everything...
  [System.IO.File]::WriteAllLines(
    $SealedSecret,
    @(
      "# This file is generated, do not edit manually."
      "# When editing, run ``Protect-Secret.ps1`` to regenerate."
      kubeseal `
        --secret-file $Secret `
        --allow-empty-data `
        --cert "$PSScriptRoot/sealed-secrets-cert.pem" `
        --format yaml
    ),
    $Utf8NoBom
  )
}
```

I pulled the certificate from the cluster...

```ps1
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Using [System.IO.File]::WriteAllLines here because Powershell's >> encodes output in UTF8 with BOM, because we can't have nice things, which then breaks everything...
[System.IO.File]::WriteAllLines(
  "$PWD/scripts/sealed-secrets-cert.pem",
  (kubeseal --fetch-cert --controller-name "sealed-secrets" --controller-namespace "sealed-secrets"),
  $Utf8NoBom
)
```

And git-ignored it.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
      ✋ .gitignore
    📁 jobs
      🧾 kaniko.yaml
    📁 scripts
+     ✋ .gitignore
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Protect-Secret.ps1
      🧾 Publish-Hello.ps1
+     🧾 sealed-secrets-cert.pem.example
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```
/sealed-secrets-cert.pem
```

I creaed the secret from which I will generate the sealed secret.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
      ✋ .gitignore
    📁 jobs
      🧾 kaniko.yaml
    📁 sealed-secrets
+     ✋ .gitignore
+     🧾 martin-deploy-2-ghcr.yaml.secret.example
    📁 scripts
      ✋ .gitignore
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Protect-Secret.ps1
      🧾 Publish-Hello.ps1
      🧾 sealed-secrets-cert.pem.example
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```yaml
# This file is used to generate another file.
# When editing, run `Protect-Secret.ps1` to regenerate the output.
apiVersion: v1
kind: Secret
metadata:
  name: martin-deploy-2-ghcr
  annotations:
    sealedsecrets.bitnami.com/cluster-wide: "true"
type: kubernetes.io/dockerconfigjson
stringData:
  .dockerconfigjson: |-
    {
      "auths": {
        "ghcr.io": {
          "auth": "__AUTH_BASE_64__"
            // Where __AUTH_BASE_64__ = b64("__GITHUB_USERNAME__:__GITHUB_PERSONAL_ACCESS_TOKEN__")
            // When creating the token:
            // * Select the `read:packages` scope to download container images and read their metadata.
            // * Select the `write:packages` scope to download and upload container images and read and write their metadata.
            // * Select the `delete:packages` scope to delete container images.
        }
      }
    }

```

```ps1
& "./scripts/Protect-Secret.ps1"
```
```output
+ Secret: C:\Users\plessym\Documents\Martin\docs\scripts/../sealed-secrets/martin-deploy-2-ghcr.yaml.secret
  Sealed: C:\Users\plessym\Documents\Martin\docs\scripts/../sealed-secrets/martin-deploy-2-ghcr.yaml
```

Time to apply the new secret containing the GHCR credetials.

```ps1
oc apply --filename "./sealed-secrets/martin-deploy-2-ghcr.yaml"
```
```output
sealedsecret.bitnami.com/martin-deploy-2-ghcr created
```

Check it was indeed created.

```ps1
oc get sealedsecrets,secrets
```
```output
NAME                                            STATUS   SYNCED   AGE
sealedsecret.bitnami.com/martin-deploy-2-ghcr            True     79s

NAME                          TYPE                             DATA   AGE
secret/martin-deploy-2-ghcr   kubernetes.io/dockerconfigjson   1      79s
```

Pushed to the remote repository, and created the Kaniko job.

```ps1
oc apply --filename "./jobs/kaniko.yaml";  oc logs "jobs/kaniko" --follow
```
```output
job.batch/kaniko created
Enumerating objects: 23, done.
Counting objects: 100% (23/23), done.
Compressing objects: 100% (11/11), done.
Total 23 (delta 3), reused 20 (delta 3), pack-reused 0
INFO[0001] Retrieving image manifest alpine:3.18.0
INFO[0001] Retrieving image alpine:3.18.0 from registry index.docker.io
INFO[0002] Built cross stage deps: map[]
INFO[0002] Retrieving image manifest alpine:3.18.0
INFO[0002] Returning cached image manifest
INFO[0002] Executing 0 build triggers
INFO[0002] Building stage 'alpine:3.18.0' [idx: '0', base-idx: '-1']
INFO[0002] Skipping unpacking as no commands require it.
INFO[0002] ENTRYPOINT ["echo", "Hello"]
INFO[0002] Pushing image to ghcr.io/martin-deploy-2/hello:1
INFO[0003] Pushed ghcr.io/martin-deploy-2/hello@sha256:197facbbbf2f4e569559710d540bd38c197facbbbf2f4e569559710d540bd38c
```

To run this first _Hello World_ container, we need another job.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
      ✋ .gitignore
    📁 jobs
+     🧾 hello.yaml
      🧾 kaniko.yaml
    📁 sealed-secrets
      ✋ .gitignore
      🧾 martin-deploy-2-ghcr.yaml.secret.example
    📁 scripts
      ✋ .gitignore
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Protect-Secret.ps1
      🧾 Publish-Hello.ps1
      🧾 sealed-secrets-cert.pem.example
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: main
          image: ghcr.io/martin-deploy-2/hello:1
```

Run the job.

```ps1
oc apply --filename "./jobs/hello.yaml"; oc logs "jobs/hello" --follow
```
```output
job.batch/hello created
Error from server (BadRequest): container "main" in pod "hello-mcngn" is waiting to start: ContainerCreating
```

Which isn't really whe was expected. `oc describe pod "hello-mcngn"`, however, has the amability to disclose and actually useful clue:

```
Failed to pull image "ghcr.io/martin-deploy-2/hello:1": rpc error:
  code = Unknown
  desc = failed to pull and unpack image "ghcr.io/martin-deploy-2/hello:1":
         failed to resolve reference "ghcr.io/martin-deploy-2/hello:1":
         failed to authorize:
         failed to fetch anonymous token: unexpected status from GET request to https://ghcr.io/token?scope=repository%3Amartin-deploy-2%2Fhello%3Apull&service=ghcr.io: 401 Unauthorized
```

I never told ~~Clusty II~~ my Kubernetes cluster how to authenticate against the GHCR! This boils down to updating my new job with a GHCR credentials secret that I already created.


```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
      ✋ .gitignore
    📁 jobs
!     🧾 hello.yaml
      🧾 kaniko.yaml
    📁 sealed-secrets
      ✋ .gitignore
      🧾 martin-deploy-2-ghcr.yaml.secret.example
    📁 scripts
      ✋ .gitignore
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Protect-Secret.ps1
      🧾 Publish-Hello.ps1
      🧾 sealed-secrets-cert.pem.example
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```diff
apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: main
          image: ghcr.io/martin-deploy-2/hello:1
+     imagePullSecrets:
+       - name: martin-deploy-2-ghcr
```

From restarting the job, it looks like it fails again.

```ps1
oc replace --filename "./jobs/hello.yaml" --force; oc logs "jobs/hello" --follow
```
```output
job.batch "hello" deleted
job.batch/hello replaced
Error from server (BadRequest): container "main" in pod "hello-9pgw7" is waiting to start: ContainerCreating
```

But a second try gives it justice.

```ps1
oc logs "jobs/hello"
```
```output
Hello
```

I deployed my own app using the `Containerfile`. In the Kaniko builder job, I had to update it to produce version `2`, and in the Hello job, I had to update it to use version `2`.


```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
!       🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
      ✋ .gitignore
    📁 jobs
!     🧾 hello.yaml
!     🧾 kaniko.yaml
    📁 sealed-secrets
      ✋ .gitignore
      🧾 martin-deploy-2-ghcr.yaml.secret.example
    📁 scripts
      ✋ .gitignore
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Protect-Secret.ps1
      🧾 Publish-Hello.ps1
      🧾 sealed-secrets-cert.pem.example
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```Dockerfile
FROM alpine:3.18.0
RUN apk add aspnetcore7-runtime
COPY ./bin/publish /opt/hello
ENTRYPOINT ["dotnet", "/opt/hello/Martin.Hello.dll"]
```
```diff
  apiVersion: batch/v1
  kind: Job
  metadata:
    name: kaniko
  spec:
    template:
      spec:
        restartPolicy: Never
        containers:
          - name: main
            image: gcr.io/kaniko-project/executor:v1.17.0
            args:
-             - --destination=ghcr.io/martin-deploy-2/hello:1
+             - --destination=ghcr.io/martin-deploy-2/hello:2
              - --context=git://github.com/martin-deploy-2/docs.git#refs/heads/main
              - --context-sub-path=applications/hello
              - --dockerfile=Containerfile
            volumeMounts:
              - mountPath: /kaniko/.docker/config.json
                name: kaniko-config
                subPath: .dockerconfigjson
        volumes:
          - name: kaniko-config
            secret:
              secretName: martin-deploy-2-ghcr
```
```diff
  apiVersion: batch/v1
  kind: Job
  metadata:
    name: hello
  spec:
    template:
      spec:
        restartPolicy: Never
        containers:
          - name: main
-           image: ghcr.io/martin-deploy-2/hello:1
+           image: ghcr.io/martin-deploy-2/hello:2
        imagePullSecrets:
          - name: martin-deploy-2-ghcr
```

Then, re-run the build job.

```ps1
oc replace --filename "./jobs/kaniko.yaml" --force; sleep 2; oc logs "jobs/kaniko" --follow
```
```output
job.batch "kaniko" deleted
job.batch/kaniko replaced
Enumerating objects: 28, done.
Counting objects: 100% (28/28), done.
Compressing objects: 100% (14/14), done.
Total 28 (delta 5), reused 24 (delta 4), pack-reused 0
INFO[0001] Retrieving image manifest alpine:3.18.0
INFO[0001] Retrieving image alpine:3.18.0 from registry index.docker.io
INFO[0001] Built cross stage deps: map[]
INFO[0001] Retrieving image manifest alpine:3.18.0
INFO[0001] Returning cached image manifest
INFO[0001] Executing 0 build triggers
INFO[0001] Building stage 'alpine:3.18.0' [idx: '0', base-idx: '-1']
INFO[0001] Unpacking rootfs as cmd RUN apk add aspnetcore7-runtime requires it.
INFO[0002] RUN apk add aspnetcore7-runtime
INFO[0002] Initializing snapshotter ...
INFO[0002] Taking snapshot of full filesystem...
INFO[0002] Cmd: /bin/sh
INFO[0002] Args: [-c apk add aspnetcore7-runtime]
INFO[0002] Running: [/bin/sh -c apk add aspnetcore7-runtime]
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/main/aarch64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/community/aarch64/APKINDEX.tar.gz
(1/9) Installing libgcc (12.2.1_git20220924-r10)
(2/9) Installing libstdc++ (12.2.1_git20220924-r10)
(3/9) Installing dotnet-host (7.0.12-r0)
(4/9) Installing dotnet7-hostfxr (7.0.12-r0)
(5/9) Installing icu-data-full (73.2-r2)
(6/9) Installing icu-libs (73.2-r2)
(7/9) Installing lttng-ust (2.13.5-r2)
(8/9) Installing dotnet7-runtime (7.0.12-r0)
(9/9) Installing aspnetcore7-runtime (7.0.12-r0)
Executing busybox-1.36.0-r9.trigger
OK: 145 MiB in 24 packages
INFO[0003] Taking snapshot of full filesystem...
error building image: error building stage: failed to get files used from context: failed to get fileinfo for /kaniko/buildcontext/applications/hello/bin/publish: lstat /kaniko/buildcontext/applications/hello/bin/publish: no such file or directory
```

Of course, Kaniko cannot possibly find the `./applications/hello/bin/publish` folder anywhere, considering that this folder is created by a command I've only run on my local machine, and it won't run itself magically in the cloud! I'd be tempted to say that we can't have nice things, and, don't get me wrong: we can't. But I kinda feel like this one's on me...

The solution to that is to build the application at the same time as we build the container by using a two-stage Containerfile.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
!       🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
      ✋ .gitignore
    📁 jobs
      🧾 hello.yaml
      🧾 kaniko.yaml
    📁 sealed-secrets
      ✋ .gitignore
      🧾 martin-deploy-2-ghcr.yaml.secret.example
    📁 scripts
      ✋ .gitignore
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Protect-Secret.ps1
      🧾 Publish-Hello.ps1
      🧾 sealed-secrets-cert.pem.example
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```Dockerfile
FROM alpine:3.18.0 AS builder
RUN apk add dotnet7-sdk
COPY . /tmp/builder
RUN dotnet publish "/tmp/builder" --configuration "Release" --no-self-contained --output "/tmp/builder/bin/publish"

FROM alpine:3.18.0
RUN apk add aspnetcore7-runtime
COPY --from=builder /tmp/builder/bin/publish /opt/hello
ENTRYPOINT ["dotnet", "/opt/hello/Martin.Hello.dll"]
```

Then, re-run the build job again. Version `2` was never built, so we can just reuse it.

```ps1
oc replace --filename "./jobs/kaniko.yaml" --force; sleep 2; oc logs "jobs/kaniko" --follow
```
```output
job.batch "kaniko" deleted
job.batch/kaniko replaced
Enumerating objects: 33, done.
Counting objects: 100% (33/33), done.
Compressing objects: 100% (17/17), done.
Total 33 (delta 8), reused 27 (delta 5), pack-reused 0
INFO[0001] Resolved base name alpine:3.18.0 to builder
INFO[0001] Retrieving image manifest alpine:3.18.0
INFO[0001] Retrieving image alpine:3.18.0 from registry index.docker.io
INFO[0001] Retrieving image manifest alpine:3.18.0
INFO[0001] Returning cached image manifest
INFO[0001] Built cross stage deps: map[0:[/tmp/builder/bin/publish]]
INFO[0001] Retrieving image manifest alpine:3.18.0
INFO[0001] Returning cached image manifest
INFO[0001] Executing 0 build triggers
INFO[0001] Building stage 'alpine:3.18.0' [idx: '0', base-idx: '-1']
INFO[0001] Unpacking rootfs as cmd RUN apk add dotnet7-sdk requires it.
INFO[0002] RUN apk add dotnet7-sdk
INFO[0002] Initializing snapshotter ...
INFO[0002] Taking snapshot of full filesystem...
INFO[0002] Cmd: /bin/sh
INFO[0002] Args: [-c apk add dotnet7-sdk]
INFO[0002] Running: [/bin/sh -c apk add dotnet7-sdk]
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/main/aarch64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/community/aarch64/APKINDEX.tar.gz
(1/16) Installing libgcc (12.2.1_git20220924-r10)
(2/16) Installing libstdc++ (12.2.1_git20220924-r10)
(3/16) Installing dotnet-host (7.0.12-r0)
(4/16) Installing dotnet7-hostfxr (7.0.12-r0)
(5/16) Installing icu-data-full (73.2-r2)
(6/16) Installing icu-libs (73.2-r2)
(7/16) Installing lttng-ust (2.13.5-r2)
(8/16) Installing dotnet7-runtime (7.0.12-r0)
(9/16) Installing aspnetcore7-runtime (7.0.12-r0)
(10/16) Installing aspnetcore7-targeting-pack (7.0.12-r0)
(11/16) Installing dotnet7-apphost-pack (7.0.12-r0)
(12/16) Installing dotnet7-targeting-pack (7.0.12-r0)
(13/16) Installing dotnet7-templates (7.0.112-r0)
(14/16) Installing netstandard21-targeting-pack (7.0.112-r0)
(15/16) Installing libucontext (1.2-r2)
(16/16) Installing dotnet7-sdk (7.0.112-r0)
Executing busybox-1.36.0-r9.trigger
OK: 547 MiB in 31 packages
INFO[0009] Taking snapshot of full filesystem...
INFO[0027] COPY . /tmp/builder
INFO[0027] Taking snapshot of files...
INFO[0027] RUN dotnet publish "/tmp/builder" --configuration "Release" --no-self-contained --output "/tmp/builder/bin/publish"
INFO[0027] Cmd: /bin/sh
INFO[0027] Args: [-c dotnet publish "/tmp/builder" --configuration "Release" --no-self-contained --output "/tmp/builder/bin/publish"]
INFO[0027] Running: [/bin/sh -c dotnet publish "/tmp/builder" --configuration "Release" --no-self-contained --output "/tmp/builder/bin/publish"]

Welcome to .NET 7.0!
---------------------
SDK Version: 7.0.112

----------------
Installed an ASP.NET Core HTTPS development certificate.
To trust the certificate run 'dotnet dev-certs https --trust' (Windows and macOS only).
Learn about HTTPS: https://aka.ms/dotnet-https
----------------
Write your first app: https://aka.ms/dotnet-hello-world
Find out what's new: https://aka.ms/dotnet-whats-new
Explore documentation: https://aka.ms/dotnet-docs
Report issues and find source on GitHub: https://github.com/dotnet/core
Use 'dotnet --help' to see available commands or visit: https://aka.ms/dotnet-cli
--------------------------------------------------------------------------------------
MSBuild version 17.4.8+6918b863a for .NET
  Determining projects to restore...
  Restored /tmp/builder/Martin.Hello.csproj (in 112 ms).
  Martin.Hello -> /tmp/builder/bin/Release/net7.0/Martin.Hello.dll
  Martin.Hello -> /tmp/builder/bin/publish/
INFO[0033] Taking snapshot of full filesystem...
INFO[0034] Ignoring socket dotnet-diagnostic-48-2359189-socket, not adding to tar
INFO[0034] Ignoring socket yzVN4p8NiNLbt514KVAFuQ872ZRcHUWa2Ep8OZ2Tezs, not adding to tar
INFO[0034] Saving file tmp/builder/bin/publish for later use
INFO[0034] Deleting filesystem...
INFO[0035] Retrieving image manifest alpine:3.18.0
INFO[0035] Returning cached image manifest
INFO[0035] Executing 0 build triggers
INFO[0035] Building stage 'alpine:3.18.0' [idx: '1', base-idx: '-1']
INFO[0035] Unpacking rootfs as cmd RUN apk add aspnetcore7-runtime requires it.
INFO[0035] RUN apk add aspnetcore7-runtime
INFO[0035] Initializing snapshotter ...
INFO[0035] Taking snapshot of full filesystem...
INFO[0035] Cmd: /bin/sh
INFO[0035] Args: [-c apk add aspnetcore7-runtime]
INFO[0035] Running: [/bin/sh -c apk add aspnetcore7-runtime]
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/main/aarch64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/community/aarch64/APKINDEX.tar.gz
(1/9) Installing libgcc (12.2.1_git20220924-r10)
(2/9) Installing libstdc++ (12.2.1_git20220924-r10)
(3/9) Installing dotnet-host (7.0.12-r0)
(4/9) Installing dotnet7-hostfxr (7.0.12-r0)
(5/9) Installing icu-data-full (73.2-r2)
(6/9) Installing icu-libs (73.2-r2)
(7/9) Installing lttng-ust (2.13.5-r2)
(8/9) Installing dotnet7-runtime (7.0.12-r0)
(9/9) Installing aspnetcore7-runtime (7.0.12-r0)
Executing busybox-1.36.0-r9.trigger
OK: 145 MiB in 24 packages
INFO[0037] Taking snapshot of full filesystem...
INFO[0041] COPY --from=builder /tmp/builder/bin/publish /opt/hello
INFO[0041] Taking snapshot of files...
INFO[0041] ENTRYPOINT ["dotnet", "/opt/hello/Martin.Hello.dll"]
INFO[0041] Pushing image to ghcr.io/martin-deploy-2/hello:2
INFO[0046] Pushed ghcr.io/martin-deploy-2/hello@sha256:1ed16fc9d7cb48608ab5b907e91eb5381ed16fc9d7cb48608ab5b907e91eb538
```

Re-run the application.

```ps1
oc replace --filename "./jobs/hello.yaml" --force; sleep 2; oc logs "jobs/hello" --follow
```
```output
job.batch "hello" deleted
job.batch/hello replaced
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5000
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: /
```

Now, pointing a browser at http://localhost:5000 will not give anything, but we can test our application from within its own container, we just need the name of the pod.

```ps1
oc get pods --output "name" | Select-String -SimpleMatch "hello"
```
```output
pod/hello-g6ppd
```

Then, we'll be able to CURL our app.

```ps1
oc exec "$(oc get pods --output "name" | Select-String -SimpleMatch "hello")" -- ash -c "apk add curl && curl --silent http://localhost:5000"
```
```output
If you don't see a command prompt, try pressing enter.
warning: couldn't attach to pod/test, falling back to streaming logs: unable to upgrade connection: container test not found in pod test_default
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/main/aarch64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/community/aarch64/APKINDEX.tar.gz
(1/7) Installing ca-certificates (20230506-r0)
(2/7) Installing brotli-libs (1.0.9-r14)
(3/7) Installing libunistring (1.1-r1)
(4/7) Installing libidn2 (2.3.4-r1)
(5/7) Installing nghttp2-libs (1.57.0-r0)
(6/7) Installing libcurl (8.4.0-r0)
(7/7) Installing curl (8.4.0-r0)
Executing busybox-1.36.0-r9.trigger
Executing ca-certificates-20230506-r0.trigger
Hello.
```

## Pod

Before progressing further, a small aside on Pods.

The pod groups containers. It provides shared storage, in the form of volumes, which can also point to external sources. All containers in a pod share an IP address, ports, and `localhost`. All containers in a pod are scheduled on the same node.

The configuration of a pod can be declared in YAML. YAML is not a markup language, it is a data serialization language. As such it can be used to serialize data, but it's not very good at it, or ~~ironically~~ as a markup language, but it's not very good at it, or to declare configuration, but it's not very good at it either.

Create a yaml file to define a pod:

```diff
📁 ..
  📁 .
+ 📁 aside
+   📁 pods
+     🧾 hello.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello
spec:
  containers:
    - name: app
      image: alpine:3.18.0
      command: [echo]
      args: ["Hello."]
```
Then, run it.

```ps1
oc apply --filename "../aside/pods/hello.yaml"
```
```output
pod/hello created
```

See if we can list it.

```ps1
oc get pods
```
```output
NAME    READY   STATUS      RESTARTS      AGE
hello   0/1     Completed   2 (21s ago)   23s
```

Of course our pod is marked as Completed and must have died along the way, as proven by the same command.

```ps1
oc get pods
```
```output
NAME    READY   STATUS             RESTARTS      AGE
hello   0/1     CrashLoopBackOff   3 (35s ago)   80s
```
Bbecause Kubernetes is a mad world where you can't run the same command over and over and expect the same result! Still, in our first exposure case, it's not quite as critical as it seems, as the container simply did its job of echoing "Hello".

```ps1
oc logs "pods/hello"
```
```output
Hello.
```

To prevent the container from dying, we can make a loop.

```diff
📁 ..
  📁 .
  📁 aside
    📁 pods
!     🧾 hello.yaml
```
```diff
apiVersion: v1
kind: Pod
metadata:
  name: hello
spec:
  containers:
    - name: app
      image: alpine:3.18.0
-     command: [echo]
+     command: [ash, -c]
-     args: ["Hello."]
+     args: ['while true; do echo "Hello."; sleep 1; done']
```

```ps1
oc apply --filename "../aside/pods/hello.yaml"
```
```output
The Pod "hello" is invalid: spec: Forbidden: pod updates may not change fields other than `spec.containers[*].image`, `spec.initContainers[*].image`, `spec.activeDeadlineSeconds`, `spec.tolerations` (only additions to existing tolerations) or `spec.terminationGracePeriodSeconds` (allow it to be set to 1 if it was previously negative)
  core.PodSpec{
        Volumes:        {{Name: "kube-api-access-njbtv", VolumeSource: {Projected: &{Sources: {{ServiceAccountToken: &{ExpirationSeconds: 3607, Path: "token"}}, {ConfigMap: &{LocalObjectReference: {Name: "kube-root-ca.crt"}, Items: {{Key: "ca.crt", Path: "ca.crt"}}}}, {DownwardAPI: &{Items: {{Path: "namespace", FieldRef: &{APIVersion: "v1", FieldPath: "metadata.namespace"}}}}}}, DefaultMode: &420}}}},
        InitContainers: nil,
        Containers: []core.Container{
                {
                        Name:       "app",
                        Image:      "alpine:3.18.0",
                        Command:    {"ash", "-c"},
-                       Args:       []string{"echo Hello."},
+                       Args:       []string{`while true; do echo "Hello."; sleep 1; done`},
                        WorkingDir: "",
                        Ports:      nil,
                        ... // 16 identical fields
                },
        },
        EphemeralContainers: nil,
        RestartPolicy:       "Always",
        ... // 26 identical fields
  }
```

I forgot to mention that a pod is mostly immutable, the only mutable fields being of low interest, and the container image being a case were we generally prefer a full pod restart. To circumvent this, we can either murder the pod using `oc delete pod "hello"`, or use force.

```ps1
oc apply --filename "../aside/pods/hello.yaml" --force
```
```output
pod/hello configured
```

Now, our pod is running.

```ps1
oc get pods
```
```output
NAME    READY   STATUS    RESTARTS   AGE
hello   1/1     Running   0          54s
```

It is! And it is printing `Hello`... And it will print more `Hello` until you press CTRL+C or murder the pod.

```ps1
oc logs "pods/hello" --follow
```
```output
Hello.
Hello.
Hello.
Hello.
Hello.
Hello.
Hello.
Hello.
Hello.
Hello.
```

Sweet, I hear you thinking, let's deploy all our applications in containers within a pod! Let's take the example of two containers, happily running together in the same pod. One container is quite stable, but the other one is prone to terminating on the error side of the exit code. To simulate this, we'll add another container to our pod and make it error out after 10 seconds.

```diff
📁 ..
  📁 .
  📁 aside
    📁 pods
!     🧾 hello.yaml
```
```diff
apiVersion: v1
kind: Pod
metadata:
  name: hello
spec:
  containers:
    - name: app
      image: alpine:3.18.0
      command: [ash, -c]
-     args: ['              while true; do echo "        Hello."; sleep 1; done']
+     args: ['DATE=$(date); while true; do echo "$DATE - Hello."; sleep 1; done']
+   - name: el-contenedito-de-la-muerte
+     image: alpine:3.18.0
+     command: [ash, -c]
+     args: ['for i in $(seq 1 10); do echo "Hello, $i."; sleep 1; done; exit 666']
```

```ps1
oc apply --filename "../aside/pods/hello.yaml" --force
```
```output
pod/hello configured
```

Then follow the logs from the original, stable container.

```ps1
oc logs "pod/hello" --container "app" --follow
```
```output
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
Wed Aug 30 15:30:05 UTC 2023 - Hello.
```

I expected the whole pod to fail, but a failing container will not sink the whole pod. However, it will put it in a CrashLoopBackOff state.

```ps1
oc get pods
```
```output
NAME    READY   STATUS             RESTARTS      AGE
hello   1/2     CrashLoopBackOff   5 (95s ago)   5m35s
```

This makes it possible to deploy all our containers in a single pod, but we will be facing another issue, because we can't have nice things, remember? All containers in a pod are scheduled on the same node, which, on a single-node cluster like a ~~local~~ development environment, is not problematic, but it will become bad on a fully fledged cloud-provisioned cluster with dozens of nodes, spanning multiple regions and continents, etc... And that's without talking about scaling and replication, the needs for which will vary on an application (therefore: container) basis, while the smallest building block of Kubernetes... Is the Pod.

## Service

That would better to have access to my application from outside its own container. After all, the container is supposed to be a boat, not a jail. ~~BSD joke intensifies~~

For now, I've CURLed my application from the same container. The first step in making it public would at least to be able to contact it from another container. To do so, I can get my app pod's IP address.

```ps1
oc get pods --output "wide"
```
```output
NAME          READY   STATUS    RESTARTS   AGE   IP
hello-t6mvj   1/1     Running   0          35s   10.244.0.18
```

Then, CURL it from another pod by targeting its IP.

```ps1
oc run "test" --image "alpine:3.18.0" --stdin --tty --rm -- ash -c "apk add curl && curl http://10.244.0.18:5000"
```
```output
If you don't see a command prompt, try pressing enter.
warning: couldn't attach to pod/test, falling back to streaming logs: unable to upgrade connection: container test not found in pod test_default
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/main/aarch64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/community/aarch64/APKINDEX.tar.gz
(1/7) Installing ca-certificates (20230506-r0)
(2/7) Installing brotli-libs (1.0.9-r14)
(3/7) Installing libunistring (1.1-r1)
(4/7) Installing libidn2 (2.3.4-r1)
(5/7) Installing nghttp2-libs (1.57.0-r0)
(6/7) Installing libcurl (8.4.0-r0)
(7/7) Installing curl (8.4.0-r0)
Executing busybox-1.36.0-r9.trigger
Executing ca-certificates-20230506-r0.trigger
OK: 12 MiB in 22 packages
curl: (7) Failed to connect to 10.244.0.18 port 5000 after 0 ms: Couldn't connect to server
pod "test" deleted
```

Now, don't ask me why, but changing the base image from `alpine` to `mcr.microsoft.com/dotnet/aspnet` solves this connection failure. It looks like we are stuck with our branded leash. Because we can't have nice things.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
!       🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
      ✋ .gitignore
    📁 jobs
!     🧾 hello.yaml
!     🧾 kaniko.yaml
    📁 sealed-secrets
      ✋ .gitignore
      🧾 martin-deploy-2-ghcr.yaml.secret.example
    📁 scripts
      ✋ .gitignore
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Protect-Secret.ps1
      🧾 Publish-Hello.ps1
      🧾 sealed-secrets-cert.pem.example
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```diff
- FROM alpine:3.18.0 AS builder
+ FROM mcr.microsoft.com/dotnet/sdk:7.0 AS builder
- RUN apk add dotnet7-sdk
  COPY . /tmp/builder
  RUN dotnet publish "/tmp/builder" --configuration "Release" --no-self-contained --output "/tmp/builder/bin/publish"

- FROM alpine:3.18.0
+ FROM mcr.microsoft.com/dotnet/aspnet:7.0
- RUN apk add aspnetcore7-runtime
  COPY --from=builder /tmp/builder/bin/publish /opt/hello
  ENTRYPOINT ["dotnet", "/opt/hello/Martin.Hello.dll"]
```

Change the image version from `2` to `3` in `kaniko.yaml` and `hello.yaml`, and run a build.

```ps1
oc replace --filename "./jobs/kaniko.yaml" --force; sleep 2; oc logs "jobs/kaniko" --follow
```
```output
job.batch "kaniko" deleted
job.batch/kaniko replaced
Enumerating objects: 38, done.
Counting objects: 100% (38/38), done.
Compressing objects: 100% (19/19), done.
Total 38 (delta 11), reused 31 (delta 7), pack-reused 0
INFO[0001] Resolved base name mcr.microsoft.com/dotnet/sdk:7.0 to builder
INFO[0001] Retrieving image manifest mcr.microsoft.com/dotnet/sdk:7.0
INFO[0001] Retrieving image mcr.microsoft.com/dotnet/sdk:7.0 from registry mcr.microsoft.com
INFO[0001] Retrieving image manifest mcr.microsoft.com/dotnet/aspnet:7.0
INFO[0001] Retrieving image mcr.microsoft.com/dotnet/aspnet:7.0 from registry mcr.microsoft.com
INFO[0001] Built cross stage deps: map[0:[/tmp/builder/bin/publish]]
INFO[0001] Retrieving image manifest mcr.microsoft.com/dotnet/sdk:7.0
INFO[0001] Returning cached image manifest
INFO[0001] Executing 0 build triggers
INFO[0001] Building stage 'mcr.microsoft.com/dotnet/sdk:7.0' [idx: '0', base-idx: '-1']
INFO[0001] Unpacking rootfs as cmd COPY . /tmp/builder requires it.
INFO[0014] COPY . /tmp/builder
INFO[0014] Taking snapshot of files...
INFO[0014] RUN dotnet publish "/tmp/builder" --configuration "Release" --no-self-contained --output "/tmp/builder/bin/publish"
INFO[0014] Initializing snapshotter ...
INFO[0014] Taking snapshot of full filesystem...
INFO[0019] Cmd: /bin/sh
INFO[0019] Args: [-c dotnet publish "/tmp/builder" --configuration "Release" --no-self-contained --output "/tmp/builder/bin/publish"]
INFO[0019] Running: [/bin/sh -c dotnet publish "/tmp/builder" --configuration "Release" --no-self-contained --output "/tmp/builder/bin/publish"]
MSBuild version 17.7.3+8ec440e68 for .NET
  Determining projects to restore...
  Restored /tmp/builder/Martin.Hello.csproj (in 98 ms).
  Martin.Hello -> /tmp/builder/bin/Release/net7.0/Martin.Hello.dll
  Martin.Hello -> /tmp/builder/bin/publish/
INFO[0024] Taking snapshot of full filesystem...
INFO[0025] Ignoring socket dotnet-diagnostic-41-118914-socket, not adding to tar
INFO[0025] Ignoring socket eb9ba90+e7db0a42fdbefd5044804+804eb9ba+2fdb, not adding to tar
INFO[0025] Saving file tmp/builder/bin/publish for later use
INFO[0025] Deleting filesystem...
INFO[0026] Retrieving image manifest mcr.microsoft.com/dotnet/aspnet:7.0
INFO[0026] Returning cached image manifest
INFO[0026] Executing 0 build triggers
INFO[0026] Building stage 'mcr.microsoft.com/dotnet/aspnet:7.0' [idx: '1', base-idx: '-1']
INFO[0026] Unpacking rootfs as cmd COPY --from=builder /tmp/builder/bin/publish /opt/hello requires it.
INFO[0029] COPY --from=builder /tmp/builder/bin/publish /opt/hello
INFO[0029] Taking snapshot of files...
INFO[0029] ENTRYPOINT ["dotnet", "/opt/hello/Martin.Hello.dll"]
INFO[0029] Pushing image to ghcr.io/martin-deploy-2/hello:3
INFO[0031] Pushed ghcr.io/martin-deploy-2/hello@sha256:fdbefd5044804eb9ba904157e7db0a42fdbefd5044804eb9ba904157e7db0a42
```

```ps1
oc replace --filename "./jobs/hello.yaml" --force; sleep 2; oc logs "jobs/hello" --follow
```
```output
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: /
```

Note that the port number has changed.

```ps1
oc get pods --output "wide"
```
```output
NAME           READY   STATUS      RESTARTS   AGE     IP
hello-4z7td    1/1     Running     0          39s     10.244.0.47
```

Not that the pod's IP address has changed, this will be important later.

```ps1
oc run "test" --image "alpine:3.18.0" --stdin --tty --rm -- ash -c "apk add curl && curl --silent http://10.244.0.47:80"
```
```output
If you don't see a command prompt, try pressing enter.
warning: couldn't attach to pod/test, falling back to streaming logs: unable to upgrade connection: container test not found in pod test_default
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/main/aarch64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/community/aarch64/APKINDEX.tar.gz
(1/7) Installing ca-certificates (20230506-r0)
(2/7) Installing brotli-libs (1.0.9-r14)
(3/7) Installing libunistring (1.1-r1)
(4/7) Installing libidn2 (2.3.4-r1)
(5/7) Installing nghttp2-libs (1.57.0-r0)
(6/7) Installing libcurl (8.4.0-r0)
(7/7) Installing curl (8.4.0-r0)
Executing busybox-1.36.0-r9.trigger
Executing ca-certificates-20230506-r0.trigger
OK: 12 MiB in 22 packages
Hello.
pod "test" deleted
```

Network ports listened to by the applications living inside containers wrapped in pods don't get automatically exposed to the outside world, that would be a nice thing, and we can't have those. Even from within the cluster, it is clumsy to have to get the pod's IP address in order to caontact it. Exposing applications to the network is done by declaring a _Service_.

As over-engineered as it sounds to have another abstraction layer to route network trafic to our pods, services are, at the end of times, not that unlikeable. See, the pods are mostly immutable, and it's the doxa to consider them as disposable at will. It means that those poor things will be sacrificed at any occasion, but they don't mind...

<!-- [portal they don't feel pain, just a simulation] -->

For us however this means that we can't rely on the pod's IP address for a long term relationship. Not only the services hide the pods, they also do load-balancing, and they trigger the creation of a DNS entry internal to the cluster, which has the form `<SERVICE_NAME>.<SERVICE_NAMESPACE="default">.svc.cluster.local`.

What are we waiting for? Let's create a service!

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
      ✋ .gitignore
    📁 jobs
!     🧾 hello.yaml
      🧾 kaniko.yaml
    📁 scripts
      ✋ .gitignore
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Protect-Secret.ps1
      🧾 Publish-Hello.ps1
      🧾 sealed-secrets-cert.pem.example
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    📁 sealed-secrets
      ✋ .gitignore
      🧾 martin-deploy-2-ghcr.yaml.secret.example
+   📁 services
+     🧾 hello.yaml
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```diff
apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  template:
+   metadata:
+     labels:
+       app.kubernetes.io/name: 2545bb8b-e59c-4f4a-b362-2d1591215f25
    spec:
      restartPolicy: Never
      containers:
        - name: main
          image: ghcr.io/martin-deploy-2/hello:3
      imagePullSecrets:
        - name: martin-deploy-2-ghcr
```
```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello
spec:
  selector:
    app.kubernetes.io/name: 2545bb8b-e59c-4f4a-b362-2d1591215f25
  ports:
    - port: 5000
      targetPort: 80
```

Both the Job and the service have their `.metadata.name` set to `hello` but that doesn't matter, because they are resources of different types.

A service knows what pods to pass trafic to, not by the pods' names, which might change as much as pods are created and ditched, but by matching their "labels". Labels are like tags that take the form of a string-string key-value pairs.

Kubernetes defines a bunch of [standard labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels), among which `app.kubernetes.io/name`, which defines the name of the considered application, which sounds like a safe starter for identifying pod wrapping containers in which applications live for the value, I'll use the second worst thing after a poor name: a giberrish GUID!

Services allow for changing the exposed network port: the `.spec.ports[].port` is the port exposed by the service, while the `.spec.ports[].targetPort` is the port the application in a container in a pod is listening to.

```ps1
oc replace --filename "./jobs/hello.yaml" --force --filename "./services/hello.yaml"
```
```output
job.batch "hello" deleted
job.batch/hello replaced
service/hello replaced
```

Check that everythin has been created.

```ps1
oc get pods,services
```
```output
NAME               READY   STATUS      RESTARTS   AGE
pod/hello-sqdlq    1/1     Running     0          39s
pod/kaniko-pptcv   0/1     Completed   0          68m

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
service/hello        ClusterIP   10.0.79.63   <none>        5000/TCP   38s
service/kubernetes   ClusterIP   10.0.0.1     <none>        443/TCP    5d1h
```

Spawn another pod to CURL the application using our new service.

```ps1
oc run "test" --image "alpine:3.18.0" --quiet --stdin --tty --rm -- ash -c "apk add curl --quiet && curl --silent http://hello.default.svc.cluster.local:5000"
```
```output
warning: couldn't attach to pod/test, falling back to streaming logs: unable to upgrade connection: container test not found in pod test_default
Hello.
```

## Housework

There are a few things I'd like to do before moving on. First is to ditch the Jobs and use Pods directly instead.

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🧾 Martin.Hello.csproj
        🧾 Program.cs
    📁 charts
      📁 bitnami
        📁 sealed-secrets
          🧾 Chart.yaml
      ✋ .gitignore
-   📁 jobs
-     🧾 hello.yaml
-     🧾 kaniko.yaml
+   📁 pods
+     🧾 hello.yaml
+     🧾 kaniko.yaml
    📁 scripts
      ✋ .gitignore
      🧾 Enter-Cluster.ps1
      🌐 hello.http
      🧾 Protect-Secret.ps1
      🧾 Publish-Hello.ps1
      🧾 sealed-secrets-cert.pem.example
      🧾 Start-Cluster.ps1
      🧾 Stop-Cluster.ps1
    📁 sealed-secrets
      ✋ .gitignore
      🧾 martin-deploy-2-ghcr.yaml.secret.example
    📁 services
      🧾 hello.yaml
    🐭 .editorconfig
    ✋ .gitignore
    📑 README.md
```
```diff
- apiVersion: batch/v1
- kind: Job
+ apiVersion: v1
+ kind: Pod
  metadata:
    name: hello
- spec:
-   template:
-     metadata:
    labels:
      app.kubernetes.io/name: 2545bb8b-e59c-4f4a-b362-2d1591215f25
  spec:
-   restartPolicy: Never
    containers:
      - name: main
        image: ghcr.io/martin-deploy-2/hello:3
    imagePullSecrets:
      - name: martin-deploy-2-ghcr
```
```diff
- apiVersion: batch/v1
- kind: Job
+ apiVersion: v1
+ kind: Pod
  metadata:
    name: kaniko
  spec:
-   template:
-     spec:
-       restartPolicy: Never
    containers:
      - name: main
        image: gcr.io/kaniko-project/executor:v1.17.0
        args:
          - --destination=ghcr.io/martin-deploy-2/hello:3
          - --context=git://github.com/martin-deploy-2/docs.git#refs/heads/main
          - --context-sub-path=applications/hello
          - --dockerfile=Containerfile
        volumeMounts:
          - mountPath: /kaniko/.docker/config.json
            name: kaniko-config
            subPath: .dockerconfigjson
    volumes:
      - name: kaniko-config
        secret:
          secretName: martin-deploy-2-ghcr
```

I've been using Jobs since the begining, but for the ~~joke~~ task at hand, there is no need for their complexity yet. Moreover, I feel like the purpose of the Job is wasted by having `restartPolicy` set to `Never`.

## Ingress

At this point, I had pods ~~R.I.P. Jobs~~ running in th Azure cluster, and they have been proven to serve quite polite greetings perfectly. However, the haven't been accessed from outside the cluster, and this is becoming unbearable! I want to be greeted from my browser! I want to use `hello.http`!

There is on viable technique for doing this called Port Forwarding.

Use `hello.http` to GET http://localhost:5000:

```ps1
# Listen on port 5000 locally, forwarding to 80 in the pod
oc port-forward "pods/hello" "5000:80"

# Listen on port 5000 locally, forwarding to the targetPort of the service's port named "https" in a pod selected by the service
oc port-forward "services/hello" "5000:https"
```
```output
Hello.
```
2023-OCT-30, ingresses will soon be replaced by Gateway API.

* * *
* * *
* * *
* * *
* * *
* * *


<!--

## Next

Thanks to cutting-edge technique, application release management has never been so simple and streamlined.

```ps1
Get-ChildItem
```
```output
a.txt
b.txt
c.txt
```
```
📃📜📄📑📰🧾📝📋📁📂
```

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        📂 bin
          📂 publish
+           🧾 appsettings.Development.json
+           🧾 appsettings.json
+           🧾 Martin.Hello.deps.json
+           📚 Martin.Hello.dll
+           💾 Martin.Hello.exe
+           🧾 Martin.Hello.pdb
+           🧾 Martin.Hello.runtimeconfig.json
+           🧾 web.config
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🌐 hello.http
        🧾 Martin.Hello.csproj
        🧾 Program.cs
        🧾 publish-me-daddy.ps1
    📁 pods
+     🧾 hello-2.yaml
      🧾 hello.yaml
    📁 services
      🧾 hello.yaml
    📑 README.md
```

-->


<!--

Replica

update the application so that it displays a unique id that is set only once at startup of the application

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🌐 hello.http
        🧾 Martin.Hello.csproj
!       🧾 Program.cs
        🧾 publish-me-daddy.ps1
    📁 pods
      🧾 hello.yaml
    📁 services
      🧾 hello.yaml
    📑 README.md
```

Program.cs:

```diff
  var builder = WebApplication.CreateBuilder(args);
  var app = builder.Build();
+ var aUniqueIdThatIsSetOnlyOnceAtStartupOfTheApplication = Guid.NewGuid().ToString();

- app.MapGet("/", () =>                                                        $"Hello.");
+ app.MapGet("/", () => $"{aUniqueIdThatIsSetOnlyOnceAtStartupOfTheApplication}\nHello.");
- app.MapGet("/{name}", (string name) =>                                                        $"Hello, {name}.");
+ app.MapGet("/{name}", (string name) => $"{aUniqueIdThatIsSetOnlyOnceAtStartupOfTheApplication}\nHello, {name}.");

  app.Run();
```

dotnet run --project ./applications/hello
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5000
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: ...\applications\hello
```

GET http://localhost:5000
```
5a854efa-5441-4efe-9b53-f66ec409822a
Hello.
```

Not only that, but you will always get the same id until the application restarts

./applications/hello/publish-me-daddy.ps1
```
MSBuild version 17.4.1+9a89d02ff for .NET
  Determining projects to restore...
  All projects are up-to-date for restore.
  Martin.Hello -> ...\applications\hello\bin\Release\net7.0\Martin.Hello.dll
  Martin.Hello -> ...\applications\hello\bin\publish\
```

nerdctl image build --tag hello:v1 --namespace k8s.io ./applications/hello
```
[+] Building 4.6s (6/7)
[+] Building 4.7s (7/7)
[+] Building 4.8s (7/7) FINISHED
 => [internal] load build definition from Containerfile                                                       0.0s
 => => transferring dockerfile: 167B                                                                          0.0s
 => [internal] load .dockerignore                                                                             0.0s
 => => transferring context: 2B                                                                               0.0s
 => [internal] load metadata for mcr.microsoft.com/dotnet/aspnet:7.0                                          2.2s
 => [internal] load build context                                                                             0.3s
 => => transferring context: 181.41kB                                                                         0.3s
 => CACHED [1/2] FROM mcr.microsoft.com/dotnet/aspnet:7.0@sha256:54a3864f1c7dbb232982f61105aa18a59b976382a4e  0.0s
 => => resolve mcr.microsoft.com/dotnet/aspnet:7.0@sha256:54a3864f1c7dbb232982f61105aa18a59b976382a4e720fe18  0.0s
 => [2/2] COPY ./bin/publish /opt/hello                                                                       0.0s
 => exporting to docker image format                                                                          2.1s
 => => exporting layers                                                                                       0.1s
 => => exporting manifest sha256:b1ae106290b3db89b17c874ff8899ea7047400b1fe82c1d75f8b6ce10c3d24ec             0.0s
 => => exporting config sha256:8e9bd99f2f9fea78ccaea5dabd817e06203d3709d28b26388edbb0b5fc141576               0.0s
 => => sending tarball                                                                                        2.0s
```

change pods/hello.yaml

```diff
  apiVersion: v1
  kind: Pod
  metadata:
    name: hello
    labels:
      app.kubernetes.io/name: 2545bb8b-e59c-4f4a-b362-2d1591215f25
  spec:
    containers:
      - name: app
-       image: hello:v0
+       image: hello:v1
```

kubectl apply --filename ./pods/hello.yaml --force
```
pod/hello configured
```


kubectl get pods
```
NAME    READY   STATUS    RESTARTS      AGE
hello   1/1     Running   1 (15s ago)   46m
```

forward the port in the ranchar desktop ui

GET http://localhost:5000

```
404e4879-8d29-4751-8f81-66e277ce977d
Hello.
```

define a second pod

```diff
📁 ..
  📁 .
    📁 applications
      📁 hello
        ✋ .gitignore
        🧾 appsettings.Development.json
        🧾 appsettings.json
        🐳 Containerfile
        🌐 hello.http
        🧾 Martin.Hello.csproj
        🧾 Program.cs
        🧾 publish-me-daddy.ps1
    📁 pods
+     🧾 hello-2.yaml
      🧾 hello.yaml
    📁 services
      🧾 hello.yaml
    📑 README.md
```

hello-2.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-2
  labels:
    app.kubernetes.io/name: 2545bb8b-e59c-4f4a-b362-2d1591215f25
spec:
  containers:
    - name: app
      image: hello:v1
```

note that `hello-2` is a duplicate of `hello`
it even has the same label, without which the service would not target it

kubectl apply --filename ./pods/hello-2.yaml
```
pod/hello-2 created
```


for ($i = 0; $i -lt 10; $i++) { Invoke-RestMethod -Uri http://localhost:5000 }
```
2a884b76-2fbc-4a74-923b-a3466286d056
Hello.
2a884b76-2fbc-4a74-923b-a3466286d056
Hello.
2a884b76-2fbc-4a74-923b-a3466286d056
Hello.
2a884b76-2fbc-4a74-923b-a3466286d056
Hello.
2a884b76-2fbc-4a74-923b-a3466286d056
Hello.
2a884b76-2fbc-4a74-923b-a3466286d056
Hello.
2a884b76-2fbc-4a74-923b-a3466286d056
Hello.
2a884b76-2fbc-4a74-923b-a3466286d056
Hello.
2a884b76-2fbc-4a74-923b-a3466286d056
Hello.
2a884b76-2fbc-4a74-923b-a3466286d056
Hello.
```

only one pod responds, the trafix isn't spread by the service among the two pods as it should, because we can't have nice things, let's try to delay the response of our application by introducing an artificial delay

Program.cs

```diff
  var builder = WebApplication.CreateBuilder(args);
  var app = builder.Build();
  var aUniqueIdThatIsSetOnlyOnceAtStartupOfTheApplication = Guid.NewGuid().ToString();

- app.MapGet("/", () => $"{aUniqueIdThatIsSetOnlyOnceAtStartupOfTheApplication}\nHello.");
+ app.MapGet("/", async () =>
+ {
+   await Task.Delay(500);
+   return $"{aUniqueIdThatIsSetOnlyOnceAtStartupOfTheApplication}\nHello.";
+ });

- app.MapGet("/{name}", (string name) => $"{aUniqueIdThatIsSetOnlyOnceAtStartupOfTheApplication}\nHello, {name}.");
+ app.MapGet("/{name}", async (string name) =>
+ {
+   await Task.Delay(500);
+   return $"{aUniqueIdThatIsSetOnlyOnceAtStartupOfTheApplication}\nHello, {name}.";
+ });

  app.Run();
```

add the image build to `publish-me-daddy.ps1`

```
+ param([String] $Tag)

  dotnet publish "$PSScriptRoot" --configuration Release --no-self-contained --output "$PSScriptRoot/bin/publish"
+ nerdctl image build --tag "hello:$Tag" --namespace "k8s.io" "$PSScriptRoot"
```

./applications/hello/publish-me-daddy.ps1 -Tag "v2"

```
MSBuild version 17.4.1+9a89d02ff for .NET
  Determining projects to restore...
  All projects are up-to-date for restore.
  Martin.Hello -> ...\applications\hello\bin\Release\net7.0\Martin.Hello.dll
  Martin.Hello -> ...\applications\hello\bin\publish\
[+] Building 4.6s (7/7)
[+] Building 4.7s (7/7) FINISHED
 => [internal] load build definition from Containerfile                                                       0.1s
 => => transferring dockerfile: 167B                                                                          0.0s
 => [internal] load .dockerignore                                                                             0.1s
 => => transferring context: 2B                                                                               0.0s
 => [internal] load metadata for mcr.microsoft.com/dotnet/aspnet:7.0                                          2.2s
 => [internal] load build context                                                                             0.3s
 => => transferring context: 183.12kB                                                                         0.2s
 => CACHED [1/2] FROM mcr.microsoft.com/dotnet/aspnet:7.0@sha256:54a3864f1c7dbb232982f61105aa18a59b976382a4e  0.0s
 => => resolve mcr.microsoft.com/dotnet/aspnet:7.0@sha256:54a3864f1c7dbb232982f61105aa18a59b976382a4e720fe18  0.0s
 => [2/2] COPY ./bin/publish /opt/hello                                                                       0.0s
 => exporting to docker image format                                                                          2.0s
 => => exporting layers                                                                                       0.1s
 => => exporting manifest sha256:5bfd400c905cab0a7e8556cd26e33340dc3ab006d1912935bec9a58835794daa             0.0s
 => => exporting config sha256:229dadd01e6ec31a1051254ee81b3d94b04793030715be871febf27627f5f518               0.0s
 => => sending tarball                                                                                        1.9s
Loaded image: docker.io/library/hello:v2
```

kubectl apply --recursive --filename ./pods --filename ./services --force
```
pod/hello-2 configured
pod/hello configured
service/hello unchanged
```

for ($i = 0; $i -lt 10; $i++) { Invoke-RestMethod -Uri http://localhost:5000 }
```
983433b6-1b9d-4f6d-b0c4-0b651a892ccd
Hello.
983433b6-1b9d-4f6d-b0c4-0b651a892ccd
Hello.
983433b6-1b9d-4f6d-b0c4-0b651a892ccd
Hello.
983433b6-1b9d-4f6d-b0c4-0b651a892ccd
Hello.
983433b6-1b9d-4f6d-b0c4-0b651a892ccd
Hello.
983433b6-1b9d-4f6d-b0c4-0b651a892ccd
Hello.
983433b6-1b9d-4f6d-b0c4-0b651a892ccd
Hello.
983433b6-1b9d-4f6d-b0c4-0b651a892ccd
Hello.
983433b6-1b9d-4f6d-b0c4-0b651a892ccd
Hello.
983433b6-1b9d-4f6d-b0c4-0b651a892ccd
Hello.
```

Same results, just for a longer waiting time

-->
