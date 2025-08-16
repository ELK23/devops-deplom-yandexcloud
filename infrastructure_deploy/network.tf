# Создание VPC-сети
resource "yandex_vpc_network" "default" {
  name = "default-network"
}

# Создание NAT-шлюза
resource "yandex_vpc_gateway" "nat_gateway" {
  name       = "default-nat-gateway"
  shared_egress_gateway {}
}

# Таблица маршрутов с направлением в NAT
resource "yandex_vpc_route_table" "default_route_table" {
  name       = "default-route-table"
  network_id = yandex_vpc_network.default.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Подсеть в зоне A
resource "yandex_vpc_subnet" "private_a" {
  name           = "private-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  route_table_id = yandex_vpc_route_table.default_route_table.id
}

# Подсеть в зоне B
resource "yandex_vpc_subnet" "private_b" {
  name           = "private-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.3.0/24"]
  route_table_id = yandex_vpc_route_table.default_route_table.id
}

# Подсеть в зоне D
resource "yandex_vpc_subnet" "private_d" {
  name           = "private-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.4.0/24"]
  route_table_id = yandex_vpc_route_table.default_route_table.id
}