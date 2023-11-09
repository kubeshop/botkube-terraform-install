This repository is for setting up Botkube for MS Teams on Azure AKS from scratch automatically using Terraform Cloud.
Follow along with this tutorial [here](https://botkube.io/blog/integrating-microsoft-teams-with-azure-for-kubernetes-deployments)

# Tutorial Guide

In this tutorial, we will guide you through the step-by-step process of configuring and leveraging Botkube for Microsoft Teams and AKS. This enhancement empowers your team to efficiently establish a connection between Kubernetes and Microsoft Teams, facilitating the streamlined management of multiple Kubernetes clusters and significantly improving incident resolution times.

## Prerequisites

- Botkube Cloud account
- Access to a Kubernetes cluster
- MS Teams account
- Create a Custom App in Microsoft Teams

## Create a Custom App in Microsoft Teams
![image](https://github.com/kubeshop/botkube-terraform-install/assets/100232008/a36a09fe-b24b-406d-a3f2-b17427073d99)
1. Log into the Developer Portal for Teams.
2. Click on the Apps left-hand side menu item and choose New app.
3. In the Add app pop-up, provide an app name (e.g., Botkube).
4. Your app should now be listed in the Apps table. Click the app to continue.
5. Fill in the App details in the Configure/Basic information section as follows:
   - App name / Short name: Botkube
   - Descriptions / Short description: Botkube is a bot for your Kubernetes cluster.
   - Descriptions / Long description: Botkube helps you monitor your Kubernetes cluster, debug critical deployments, and gives recommendations for standard practices by running checks on the Kubernetes resources.
   - Version: 1.5.0
   - Developer Information / Developer: Botkube
   - Developer Information / Website: [https://botkube.io](https://botkube.io)
   - App URLs / Privacy policy: [https://botkube.io/privacy](https://botkube.io/privacy)
   - App URLs / Terms of use: [https://botkube.io/license](https://botkube.io/license)
   - Application (client) ID: Add the Application (client) ID you obtained from Azure Active Directory.
  ![image](https://github.com/kubeshop/botkube-terraform-install/assets/100232008/a07e9fbc-60b8-4e64-bed2-b002eeb8988f)
6. Click the Save button to save your app details.

## Configure the Botkube Branding

1. Navigate to Branding on the left-hand side menu item and click to open the Branding section.
2. Download Botkube icons from [here](https://github.com/kubeshop/botkube/tree/main/branding/logos) and update Branding icons.
![image](https://github.com/kubeshop/botkube-terraform-install/assets/100232008/8723fa47-423d-433c-99bd-a024889df05b)
## Add the Bot Feature to the App
![image](https://github.com/kubeshop/botkube-terraform-install/assets/100232008/a7248b5a-5a02-4134-a046-391cd0fe4717)
1. On the left-hand side menu, click Configure / App features.
2. In App features, click the "Bot" button.
3. In Select an existing bot, select the bot you just created.
4. In Identify your bot enable:
   - What can your bot do?: Upload and download files
   - Select the scopes in which people can use this command: Personal & Team
5. Then click Save.
![image](https://github.com/kubeshop/botkube-terraform-install/assets/100232008/52f538df-e5cf-47a4-84cc-ea72dbee28e1)
## Install Bot to Teams
![image](https://github.com/kubeshop/botkube-terraform-install/assets/100232008/9aa67f70-82df-493c-a327-ff3c7a428c52)

1. Go to Publish to org.
2. Click on Publish your app to install the Botkube app on MS Teams.

## Deploying Botkube

### Terraform

#### Prerequisites

- Terraform Cloud Account
- Azure Account
- Github Account

#### Collect Azure Credentials for Terraform Cloud

Before you start setting up the environment, you need to collect the Azure credentials required for Terraform Cloud. You can see the credentials needed for Azure in [this documentation](#). Make note of the following environment variables, which you will need for Terraform integration:

- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID
- ARM_SUBSCRIPTION_ID

#### Create a Workspace in Terraform Cloud

1. Log in to your Terraform Cloud account.
2. Create a new workspace by clicking on Workspaces and then Create a New Workspace.
3. Connect your GitHub account with Terraform Cloud and select the forked repository as the source.
4. Do not trigger any runs yet. We'll configure the workspace variables first.
5. Inside your newly created workspace, go to the Settings tab.
6. Click on Workspace Variables to add the following parameters:
   - ARM_CLIENT_ID
   - ARM_CLIENT_SECRET
   - ARM_TENANT_ID
   - ARM_SUBSCRIPTION_ID
7. Set the values for these variables based on the Azure credentials you collected.
8. Navigate to the "Runs" tab within your Terraform Cloud workspace.
9. Start a new run by clicking on the "Start new run" button.
10. You can monitor the progress of the run in the "Runs" tab. Wait until everything is created successfully.

Once the Terraform deployment is complete, you can access Botkube in MS Teams. Log in to your Azure account and navigate to the Kubernetes cluster created during the Terraform deployment. You will find a public domain URL similar to [this](https://botkube.centralus.cloudapp.azure.com/bots/teams/v1/messages). Use this URL as the Bot configuration endpoint address in Microsoft Teams.
