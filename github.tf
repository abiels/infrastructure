terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}
#Documentation https://registry.terraform.io/providers/integrations/github/latest/docs/resources/

# Configure the GitHub Provider
provider "github" {
  token = var.github_token # or `GITHUB_TOKEN`
}

resource "github_repository" "application" {
  name        = "application"
  visibility  = "private"
}

resource "github_repository" "infrastructure" {
  name        = "infrastructure"
  visibility  = "private"
}


resource "github_repository_collaborator" "infrastructure_Serhii-Bahlai" {
  repository = "infrastructure"
  username   = "Serhii-Bahlai"
  permission = "admin"
  depends_on = [
    github_repository.infrastructure,
  ]
}

resource "github_repository_collaborator" "application_Serhii-Bahlai" {
  repository = "application"
  username   = "Serhii-Bahlai"
  permission = "admin"
  depends_on = [
    github_repository.application,
  ]
}

resource "github_repository_collaborator" "infrastructure_RPalaziuk" {
  repository = "infrastructure"
  username   = "RPalaziuk"
  permission = "admin"
  depends_on = [
    github_repository.infrastructure,
  ]
}

resource "github_repository_collaborator" "application_RPalaziuk" {
  repository = "application"
  username   = "RPalaziuk"
  permission = "admin"
  depends_on = [
    github_repository.application,
  ]
}
