module "kubernetes-application" {
  source = "/terraform"
  registry = "registry.hub.docker.com/library"
  k8s_api_address = "https://k3s-server:6443"
  application_name = "test"
  k8s_config_path = "/root/.kube/kubeconfig.yaml"
  application_ports = [80]
  ip = "10.43.125.3"
  image = "nginx:1.19"
  environment = "homolog"
  healthcheck_path = "/"
  application_type = "cronjob"
}