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

resource "github_repository_collaborator" "application_belskiiartem" {
  repository = "application"
  username   = "belskiiartem"
  permission = "admin"
  depends_on = [
    github_repository.application,
  ]
}
