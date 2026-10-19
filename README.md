# Secure Azure Application Platform

A cloud infrastructure mini-project that deploys a secure, modular web application environment on Microsoft Azure using **Azure Bicep (Infrastructure as Code)**.

The platform uses Azure Application Gateway to route HTTP traffic to backend Ubuntu virtual machines, with segmented networking, Network Security Groups, outbound connectivity, and supporting Azure services.

## Architecture

```text
                       Internet / User
                             |
                             v
                  Azure Application Gateway
                     Public IP + Listener
                             |
                      Backend Pool
                      /           \
                     v             v
                Ubuntu VM 01   Ubuntu VM 02
                 10.1.1.4       10.1.1.5
                   Nginx          Nginx
                      \           /
                       Web Subnet
                       10.1.1.0/24
                             |
                    Azure Virtual Network
                       10.1.0.0/16

    Supporting Azure Services:
    - NAT Gateway
    - Network Security Groups
    - Azure Storage
    - Azure Key Vault
    - Log Analytics
```

## Project Objectives

- Automate infrastructure provisioning using Azure Bicep.
- Deploy Ubuntu virtual machines to host web applications.
- Configure Azure Application Gateway for HTTP routing.
- Implement backend health probes to monitor server availability.
- Segment the virtual network using dedicated subnets.
- Configure outbound internet connectivity through NAT Gateway.
- Apply network access controls using Network Security Groups.
- Integrate Azure Storage, Key Vault, and Log Analytics.

## Technology Stack

| Technology                | Purpose                                |
| ------------------------- | -------------------------------------- |
| Microsoft Azure           | Cloud infrastructure                   |
| Azure Bicep               | Infrastructure as Code                 |
| Azure CLI                 | Resource deployment and management     |
| Ubuntu Linux              | Backend virtual machines               |
| Nginx                     | Web server                             |
| Azure Application Gateway | HTTP routing and backend health checks |
| Azure Virtual Network     | Network isolation and segmentation     |
| Network Security Groups   | Network traffic filtering              |
| NAT Gateway               | Outbound internet connectivity         |
| Azure Key Vault           | Secret and key management              |
| Azure Storage             | Cloud storage                          |
| Log Analytics             | Monitoring and log analysis            |

## Azure Resources

| Resource                   | Name / Configuration |
| -------------------------- | -------------------- |
| Resource Group             | `rg-secure-app-prod` |
| Virtual Network            | `vnet-secure-app`    |
| VNet Address Space         | `10.1.0.0/16`        |
| Web Subnet                 | `10.1.1.0/24`        |
| Application Gateway Subnet | `10.1.2.0/24`        |
| Management Subnet          | `10.1.3.0/24`        |
| Virtual Machine 1          | `vm-01` — `10.1.1.4` |
| Virtual Machine 2          | `vm-02` — `10.1.1.5` |
| Application Gateway        | `appgateway`         |
| Backend Pool               | `backendPool1`       |
| NAT Gateway                | `nat-web-gateway`    |
| NAT Public IP              | `nat-outbound-ip`    |
| Key Vault                  | `kv-oculyx-344c61a7` |

## Project Structure

```text
.
├── main.bicep
└── Modules/
    ├── Monitor/
    │   └── main.bicep
    ├── Keyvault/
    │   └── main.bicep
    ├── Network/
    │   └── main.bicep
    ├── Storage/
    │   └── main.bicep
    ├── Compute/
    │   └── main.bicep
    └── AppDefaulGateway/
        └── main.bicep
```

The root `main.bicep` file orchestrates the infrastructure modules, while each module defines a specific part of the Azure environment.

## How It Works

1. A user sends an HTTP request to the Application Gateway's public IP.
2. The Application Gateway routes the request to a backend virtual machine.
3. Nginx serves the web page from the selected VM.
4. Health probes monitor backend availability.
5. NSGs restrict network traffic according to configured rules.
6. The NAT Gateway provides outbound connectivity for resources in the associated subnet.
7. Azure Storage, Key Vault, and Log Analytics provide supporting cloud capabilities.

## Prerequisites

- An Azure subscription with permission to create the required resources.
- Azure CLI installed.
- Bicep CLI available through Azure CLI.
- A terminal on macOS, Linux, or Windows.

Install Azure CLI: <https://learn.microsoft.com/cli/azure/install-azure-cli>

Install Bicep: <https://learn.microsoft.com/azure/azure-resource-manager/bicep/install>

## Deployment

### 1. Sign in to Azure

```bash
az login
```

Select your Azure subscription:

```bash
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
```

### 2. Validate the Bicep template

Run from the project root:

```bash
az bicep build --file main.bicep
```

### 3. Preview infrastructure changes

```bash
az deployment group what-if \
  --resource-group rg-secure-app-prod \
  --template-file main.bicep
```

Review the proposed changes before deploying.

### 4. Deploy the infrastructure

```bash
az deployment group create \
  --resource-group rg-secure-app-prod \
  --template-file main.bicep \
  --name secure-app-deployment
```

If your templates require parameters, provide them through a parameter file or appropriate command-line arguments. Never commit secrets to source control.

## Validation

### Check VM status

```bash
az vm list \
  --resource-group rg-secure-app-prod \
  --show-details \
  --query "[].{Name:name,PowerState:powerState,PrivateIPs:privateIps}" \
  --output table
```

### Check Application Gateway backend health

```bash
az network application-gateway show-backend-health \
  --resource-group rg-secure-app-prod \
  --name appgateway \
  --output json
```

Both backend servers should report `Healthy`.

### Check NAT Gateway association

```bash
az network vnet subnet show \
  --resource-group rg-secure-app-prod \
  --vnet-name vnet-secure-app \
  --name Web-Subnet \
  --query "{NatGateway:natGateway.id,DefaultOutboundAccess:defaultOutboundAccess}" \
  --output json
```

### Test the public application endpoint

Replace the placeholder with the Application Gateway's public IP:

```bash
curl -i --max-time 10 http://<APPLICATION_GATEWAY_PUBLIC_IP>
```

A successful test should return `HTTP 200 OK` and the expected web page.

## Current Status

Based on the latest verification:

- Azure infrastructure deployment succeeded.
- NAT Gateway was successfully associated with the web subnet.
- Nginx on `vm-01` returned `HTTP 200 OK`.
- Both Application Gateway backend servers reported `Healthy`.

The public endpoint and Nginx on `vm-02` should be independently verified before claiming complete end-to-end functionality.

## Security Best Practices

- Never commit passwords, tokens, or access keys to Git.
- Rotate credentials that have been exposed in terminal logs or shared messages.
- Restrict SSH access to trusted IP addresses or approved management paths.
- Avoid assigning public IP addresses directly to backend VMs.
- Allow backend HTTP traffic only from the Application Gateway subnet where possible.
- Use managed identities and least-privilege access for Azure resources.
- Configure HTTPS and a valid TLS certificate before production use.
- Review NSG rules and outbound network access regularly.

## Cost Management

Azure resources may incur charges while they exist, even when they are not actively being used.

Potentially billable resources include:

- Application Gateway
- NAT Gateway and its public IP
- Virtual machines
- Storage
- Monitoring services

Inspect resources before deleting anything:

```bash
az resource list \
  --resource-group rg-secure-app-prod \
  --output table
```

If the entire environment is disposable and you no longer need its resources or data, you can delete the resource group:

```bash
az group delete \
  --name rg-secure-app-prod \
  --yes \
  --no-wait
```

> **Warning:** This command deletes all resources in the resource group. Verify that nothing important needs to be retained before running it.

## Future Improvements

- Make all network and backend configuration reproducible through Bicep.
- Automate Nginx installation and application deployment.
- Configure HTTPS on Application Gateway.
- Add diagnostic settings, alerts, and centralized monitoring.
- Integrate automated deployment validation into a CI/CD pipeline.
- Replace the test page with a production-style web application.
- Document cost estimates and teardown procedures.

## License

No license has been specified. Add a license before distributing or publishing the project.