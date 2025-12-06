# Define which cloud ou service used (AWS, Azure, WCP, etc...)


provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

# Mongo

terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.16.0"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

resource "mongodbatlas_project" "project" {
  name = "vegnbio-api-prod"
  org_id= var.atlas_org_id
}

resource "mongodbatlas_project_ip_access_list" "local_ip" {
  project_id = mongodbatlas_project.project.id
  ip_address = var.local_ip
  comment    = "Local Dev Machine"
}

#resource "mongodbatlas_project_ip_access_list" "access" {
#  project_id = mongodbatlas_project.project.id
#  ip_address = "0.0.0.0/0" # to restrict
#  comment    = "Allow all for setup"
#}


resource "mongodbatlas_cluster" "cluster" {
  project_id = mongodbatlas_project.project.id
  name = "vegnbio-cluster"

  provider_name = "AWS"
  backing_provider_name = "AWS"
  provider_region_name = "EU_WEST_3"

  cluster_type = "REPLICASET"
  num_shards = 1
  replication_factor = 3

  provider_instance_size_name = "M0"
  disk_size_gb = 10
}

output "mongodb_url" {
  value = mongodbatlas_cluster.cluster.connection_strings.0.standard_srv
}