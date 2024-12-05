variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "kube-435112"  
}

variable "region" {
  description = "The region where the resources will be created"
  type        = string
  default     = "us-west1"  // Change to a region with sufficient quota
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
  default     = "my-cluster1" 
}

variable "node_count" {
  description = "The number of nodes in the Kubernetes cluster"
  type        = number
  default     = 1  
}

variable "node_machine_type" {
  description = "The type of machine to use for nodes in the Kubernetes cluster"
  type        = string
  default     = "e2-medium"  // Adjust based on the required machine type
}
