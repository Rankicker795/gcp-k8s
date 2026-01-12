provider "google" {
  project = "rea-k8s-test" # <--- REPLACE THIS
  region  = "us-central1"
  zone    = "us-central1-a"
}

# 1. Network: Create a custom VPC for the cluster
resource "google_compute_network" "k8s_vpc" {
  name                    = "k8s-experiment-vpc"
  auto_create_subnetworks = false
}

# 2. Subnet: Create a subnet specifically for GKE
resource "google_compute_subnetwork" "k8s_subnet" {
  name          = "k8s-subnet"
  region        = "us-central1"
  network       = google_compute_network.k8s_vpc.name
  ip_cidr_range = "10.0.0.0/24"
}

# 3. Cluster: The GKE Control Plane (Managed by Google)
resource "google_container_cluster" "primary" {
  name     = "gke-experiment-cluster"
  location = "us-central1-a"
  deletion_protection = false

  # We create the simplest cluster possible, removing the default node pool 
  # immediately so we can define a custom one below with specific cost settings.
  remove_default_node_pool = true
  initial_node_count       = 1
  
  network    = google_compute_network.k8s_vpc.name
  subnetwork = google_compute_subnetwork.k8s_subnet.name
}

# 4. Node Pool: The Worker Nodes (Where your apps run)
resource "google_container_node_pool" "primary_nodes" {
  name       = "gke-spot-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.primary.name
  node_count = 2  # This gives you 2 Worker Nodes

  node_config {
    # e2-medium is a balanced, cost-effective choice for small experiments
    machine_type = "e2-medium" 

    # SPOT instances are up to 90% cheaper but can be reclaimed by Google.
    # Perfect for experiments, bad for production databases.
    spot = true 

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

# 5. Artifact Registry: The place to store your Docker images
resource "google_artifact_registry_repository" "my_repo" {
  location      = "us-central1"
  repository_id = "my-repo"
  description   = "Docker repository for GKE"
  format        = "DOCKER"
}
