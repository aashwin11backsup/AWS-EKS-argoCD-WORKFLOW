# AWS EKS & ArgoCD GitOps Workflow

This repository contains the necessary Terraform and Kubernetes configurations to automatically provision an AWS EKS cluster and deploy the AWS Load Balancer Controller and ArgoCD using GitHub Actions.

The entire process is managed via GitOps principles, where infrastructure and application deployments are triggered by workflows in this repository.



***

## 🚀 Prerequisites

Before you begin, ensure you have the following:
* An AWS account with sufficient permissions to create EKS clusters, VPCs, and IAM roles.
* A GitHub account.

***

## ⚙️ Setup Instructions

To get started, you need to configure repository secrets to allow GitHub Actions to securely authenticate with your AWS account.

1.  **Fork this Repository**: Start by forking this repository to your own GitHub account.

2.  **Configure Repository Secrets**:
    * Navigate to your forked repository's **Settings**.
    * Go to **Secrets and variables** > **Actions** in the left sidebar.
    * Click on the **Repository secrets** tab.
    * Add the following two secrets using credentials from a dedicated IAM user:
        * `AWS_ACCESS_KEY_ID`
        * `AWS_SECRET_ACCESS_KEY`
3. **Make sure you have created an S3 and DynamoDB Table and noted down there Bucket Name and DD Table Name**



***

##  workflow: Deployment Workflow

To create the infrastructure and deploy the applications, you must run the GitHub Actions workflows in the specified order.

1.  **Run `1 - Terraform EKS Manual Deploy-APPLY/DESTROY`**
    * Go to the **Actions** tab in your repository.
    * Select this workflow from the list.
    * Click **Run workflow**.
    * Choose **`Apply`** from the dropdown menu to create the EKS cluster and supporting infrastructure.

2.  **Run `2 - Deploy Apps to EKS`**
    * Once the first workflow is complete, select this workflow.
    * Click **Run workflow**.
    * This workflow will automatically:
        * Update `kubeconfig` to connect to the new cluster.
        * Create the necessary IAM Role for the ALB Controller's Service Account (IRSA).
        * Deploy the AWS Load Balancer Controller using Helm.
        * Deploy ArgoCD using Helm.
        * Apply an `Ingress` resource to expose the ArgoCD server via an Application Load Balancer (ALB).

***

## 🔐 Accessing ArgoCD

Once the `2 - Deploy Apps to EKS` workflow has finished successfully, you can find the credentials to log in to the ArgoCD UI in the workflow's output logs.

* **URL**: The public DNS name of the ALB will be generated and printed.
* **Username**: `admin`
* **Password**: A unique password will be generated and printed in the logs.

> **⚠️ Please Be Patient!**
> After the workflow completes, it can take **4-5 minutes** for the ALB to become fully active and for the DNS to propagate. If you see a "Site Not Found" error, please wait and refresh the page after a few minutes.

***

## 💣 Teardown Workflow

To avoid incurring unnecessary costs, destroy all resources once you are finished. **It's crucial to run these workflows in the reverse order of deployment.**

1.  **Run `3 - Destroy Apps from EKS`**
    * Go to the **Actions** tab.
    * Select this workflow and run it to cleanly uninstall ArgoCD, the ALB Controller, and related Kubernetes resources.

2.  **Run `1 - Terraform EKS Manual Deploy-APPLY/DESTROY`**
    * Select this workflow again.
    * Click **Run workflow**.
    * This time, choose **`Destroy`** from the dropdown menu to delete the EKS cluster and all AWS infrastructure.

***


## 🕒 Important Notes on Timing

Provisioning and destroying an EKS cluster takes a significant amount of time. Please be aware of the following approximate wait times:

#### Terraform Apply
* **EKS Cluster Creation**: ~7 to 8 minutes
* **Node Group Creation**: ~5 to 6 minutes

#### Terraform Destroy
* **EKS Cluster Destruction**: ~8 to 9 minutes
* **Node Group Destruction**: ~5 to 6 minutes