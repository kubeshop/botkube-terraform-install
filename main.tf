provider "azurerm" {
  features {}
  skip_provider_registration = true
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.botkube.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.botkube.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.botkube.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.botkube.kube_config.0.cluster_ca_certificate)
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.botkube.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.botkube.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.botkube.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.botkube.kube_config.0.cluster_ca_certificate)
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.botkube.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.botkube.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.botkube.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.botkube.kube_config.0.cluster_ca_certificate)
  }
}

resource "azurerm_resource_group" "botkube" {
  name     = "botkube-resources"
  location = "Central US"
}

resource "azurerm_kubernetes_cluster" "botkube" {
  name                = "botkube"
  location            = azurerm_resource_group.botkube.location
  resource_group_name = azurerm_resource_group.botkube.name
  dns_prefix          = "botkube"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2ads_v5"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.botkube.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.botkube.kube_config_raw

  sensitive = true
}

resource "helm_release" "ingress-nginx" {
  depends_on = [azurerm_kubernetes_cluster.botkube]

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.2"
  namespace = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-dns-label-name"
    value = "botkube"
  }
}

data "kubernetes_service_v1" "nginx-ingress" {
  depends_on = [helm_release.ingress-nginx]
  metadata {
    namespace = "ingress-nginx"
    name = "ingress-nginx-controller"
  }
}

resource "helm_release" "cert-manager" {
  depends_on = [azurerm_kubernetes_cluster.botkube]

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.13.0"
  namespace = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "cluster-issuer" {
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: cluster-issuer
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: dev-botkube@botkube.io
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx

YAML
  depends_on = [helm_release.cert-manager]
}

resource "helm_release" "botkube-ms-teams" {
  depends_on = [azurerm_kubernetes_cluster.botkube, helm_release.ingress-nginx, data.kubernetes_service_v1.nginx-ingress]

  name       = "botkube"
  repository = "https://charts.botkube.io"
  chart      = "botkube"
  version    = "1.4.1"
  namespace = "botkube"
  create_namespace = true

  set {
    name  = "communications.default-group.teams.enabled"
    value = "true"
  }

  set {
    name  = "ingress.create"
    value = "true"
  }

  set {
    name  = "ingress.host"
    value = "botkube.centralus.cloudapp.azure.com"
  }

  set {
    name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "cluster-issuer"
  }

  set {
    name  = "ingress.tls.enabled"
    value = "true"
  }

  set {
    name  = "ingress.tls.secretName"
    value = "letsencrypt-prod"
  }

  set {
    name  = "settings.clusterName"
    value = azurerm_kubernetes_cluster.botkube.name
  }

  set {
    name  = "executors.k8s-default-tools.botkube/kubectl.enabled"
    value = "true"
  }

  set {
    name = "executors.k8s-default-tools.botkube/helm.enabled"
    value = "true"
  }

  set {
    name  = "communications.default-group.teams.appID"
    value = var.BOTKUBE_MS_TEAMS_APPLICATION_ID
  }

  set {
    name  = "communications.default-group.teams.appPassword"
    value = var.BOTKUBE_MS_TEAMS_APPLICATION_PASSWORD
  }

  set {
    name  = "communications.default-group.teams.botName"
    value = var.BOTKUBE_MS_TEAMS_BOT_NAME
  }
}
