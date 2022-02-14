resource "random_integer" "public_ip" {
  min = 001
  max = 500
}

resource "random_integer" "app_gw" {
  min = 001
  max = 500
}
