# Open OnDemand

## Introduction

[Open OnDemand](https://openondemand.org/) is an open-source, web-based portal developed by the Ohio Supercomputer Center (OSC) to provide easy access to high-performance computing (HPC) resources. This platform allows users to submit and monitor jobs, manage files, and run applications from anywhere, using just a web browser. The portal is designed to simplify the user experience, making it accessible for both novice and experienced HPC users.

This project installs and configures Open OnDemand on a VM managed by CycleCloud. By default, it configures Open OnDemand to use EntraId and Open IdConnect for Authentication.

## Supported OS

This project supports the following operating systems:

- AlmaLinux 8.x
- Ubuntu 22.04

## Prerequisites

**Configuration for Entra ID with Federated Identity**
- Create a User Managed Identity for the OOD VM
- Create a NIC for the OOD VM, in the compute subnet of your cluster
- Create a new application in Entra ID
- Configure the application with the following settings:
  - Redirect URI: https://<NIC_IP>/oidc if using a private IP, otherwise the FQDN assigned with the above NIC IP.
  - Check the ID tokens in Implicit grant and hybrid flows
  - In Token Configuration add an optional claim
      - Token Type: ID
      - Check 'upn' in the claim list
  - Check 'Turn on the Microsoft Graph profile permission (required for claims to appear in token).'
  - In Certificate & Secrets, add a Federated Credentials using the OOD VM User Managed Identity, leave the default audience to api://AzureADTokenExchange

- **CycleCloud Slurm cluster deployed.**
- **NFS home directories accessible** from both the cluster and the OOD VM (e.g., `/shared/home` export from the cluster scheduler).

## Deployment Steps

1. Clone the repository.
2. Import the CycleCloud template : `cyclecloud import_template openondemand -f templates/OpenOnDemand.txt`
3. Import the CycleCloud project : `cyclecloud project upload azure-storage`
4. Create a cluster of type OpenOnDemand.
5. Create user accounts in CycleCloud that match email addresses in EntraID using the regex `^([^@]+)@.*$` (e.g., `John.Doe@contoso.com` = `John.Doe`). <https://osc.github.io/ood-documentation/latest/authentication/overview/map-user.html>

Once the deployment steps are complete, you will have an OOD portal accessible at the IP of the deployed node, configured with EntraID authentication. Under the clusters menu, you will find an option to connect a cluster.

If more than one cluster is to be configured, the same home directories must be used on all, and users must exist in the same central auth service.


## Authentication Flow

1. User goes to the IP of the OOD VM.
2. User logs in using the auth from the central service (e.g., EntraID).
3. OOD maps the EntraID user to a local user. User mapping uses the email attribute and applying the regex `^([^@]+)@.*$`. <https://osc.github.io/ood-documentation/latest/authentication/overview/map-user.html>
4. User successfully logs in and is mapped to a local Linux account.


## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
