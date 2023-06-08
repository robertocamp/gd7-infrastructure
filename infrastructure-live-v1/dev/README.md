❯ terraform destroy
aws_eip.nat: Refreshing state... [id=eipalloc-0898cb887aa81e197]
aws_vpc.main: Refreshing state... [id=vpc-0056d3f0be8e1f890]
aws_internet_gateway.igw: Refreshing state... [id=igw-04051e94a470b4b81]
aws_subnet.public_us_east_2a: Refreshing state... [id=subnet-0260b11c015649fee]
aws_subnet.public_us_east_2b: Refreshing state... [id=subnet-0fca4355936716298]
aws_subnet.private_us_east_2a: Refreshing state... [id=subnet-0d30f7c2f10dc0254]
aws_subnet.private_us_east_2b: Refreshing state... [id=subnet-00c2d8316c4d6565f]
aws_route_table.public: Refreshing state... [id=rtb-055041828236e7c02]
aws_route_table_association.public_us_east_2b: Refreshing state... [id=rtbassoc-0ab6aa66661bd09c2]
aws_nat_gateway.nat: Refreshing state... [id=nat-04dfca93dbf7009fe]
aws_route_table_association.public_us_east_2a: Refreshing state... [id=rtbassoc-031f5975f1943436f]
aws_route_table.private: Refreshing state... [id=rtb-05a27d825231eafed]
aws_route_table_association.private_us_east_2b: Refreshing state... [id=rtbassoc-0b6e72fb6b20dacdf]
aws_route_table_association.private_us_east_2a: Refreshing state... [id=rtbassoc-02700fd8dce2de06c]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_eip.nat will be destroyed
  - resource "aws_eip" "nat" {
      - allocation_id        = "eipalloc-0898cb887aa81e197" -> null
      - association_id       = "eipassoc-0c5913dfc39bc170e" -> null
      - domain               = "vpc" -> null
      - id                   = "eipalloc-0898cb887aa81e197" -> null
      - network_border_group = "us-east-2" -> null
      - network_interface    = "eni-0e5ae13b5d5736711" -> null
      - private_dns          = "ip-10-0-65-28.us-east-2.compute.internal" -> null
      - private_ip           = "10.0.65.28" -> null
      - public_dns           = "ec2-3-131-203-30.us-east-2.compute.amazonaws.com" -> null
      - public_ip            = "3.131.203.30" -> null
      - public_ipv4_pool     = "amazon" -> null
      - tags                 = {
          - "Name" = "dev-nat"
        } -> null
      - tags_all             = {
          - "Name" = "dev-nat"
        } -> null
      - vpc                  = true -> null
    }

  # aws_internet_gateway.igw will be destroyed
  - resource "aws_internet_gateway" "igw" {
      - arn      = "arn:aws:ec2:us-east-2:240195868935:internet-gateway/igw-04051e94a470b4b81" -> null
      - id       = "igw-04051e94a470b4b81" -> null
      - owner_id = "240195868935" -> null
      - tags     = {
          - "Name"        = "dev-igw"
          - "WorkSession" = "revision-1"
        } -> null
      - tags_all = {
          - "Name"        = "dev-igw"
          - "WorkSession" = "revision-1"
        } -> null
      - vpc_id   = "vpc-0056d3f0be8e1f890" -> null
    }

  # aws_nat_gateway.nat will be destroyed
  - resource "aws_nat_gateway" "nat" {
      - allocation_id        = "eipalloc-0898cb887aa81e197" -> null
      - association_id       = "eipassoc-0c5913dfc39bc170e" -> null
      - connectivity_type    = "public" -> null
      - id                   = "nat-04dfca93dbf7009fe" -> null
      - network_interface_id = "eni-0e5ae13b5d5736711" -> null
      - private_ip           = "10.0.65.28" -> null
      - public_ip            = "3.131.203.30" -> null
      - subnet_id            = "subnet-0260b11c015649fee" -> null
      - tags                 = {
          - "Name"        = "dev-nat"
          - "WorkSession" = "revision-1"
        } -> null
      - tags_all             = {
          - "Name"        = "dev-nat"
          - "WorkSession" = "revision-1"
        } -> null
    }

  # aws_route_table.private will be destroyed
  - resource "aws_route_table" "private" {
      - arn              = "arn:aws:ec2:us-east-2:240195868935:route-table/rtb-05a27d825231eafed" -> null
      - id               = "rtb-05a27d825231eafed" -> null
      - owner_id         = "240195868935" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - carrier_gateway_id         = ""
              - cidr_block                 = "0.0.0.0/0"
              - core_network_arn           = ""
              - destination_prefix_list_id = ""
              - egress_only_gateway_id     = ""
              - gateway_id                 = ""
              - instance_id                = ""
              - ipv6_cidr_block            = ""
              - local_gateway_id           = ""
              - nat_gateway_id             = "nat-04dfca93dbf7009fe"
              - network_interface_id       = ""
              - transit_gateway_id         = ""
              - vpc_endpoint_id            = ""
              - vpc_peering_connection_id  = ""
            },
        ] -> null
      - tags             = {
          - "Name" = "dev-private"
        } -> null
      - tags_all         = {
          - "Name" = "dev-private"
        } -> null
      - vpc_id           = "vpc-0056d3f0be8e1f890" -> null
    }

  # aws_route_table.public will be destroyed
  - resource "aws_route_table" "public" {
      - arn              = "arn:aws:ec2:us-east-2:240195868935:route-table/rtb-055041828236e7c02" -> null
      - id               = "rtb-055041828236e7c02" -> null
      - owner_id         = "240195868935" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - carrier_gateway_id         = ""
              - cidr_block                 = "0.0.0.0/0"
              - core_network_arn           = ""
              - destination_prefix_list_id = ""
              - egress_only_gateway_id     = ""
              - gateway_id                 = "igw-04051e94a470b4b81"
              - instance_id                = ""
              - ipv6_cidr_block            = ""
              - local_gateway_id           = ""
              - nat_gateway_id             = ""
              - network_interface_id       = ""
              - transit_gateway_id         = ""
              - vpc_endpoint_id            = ""
              - vpc_peering_connection_id  = ""
            },
        ] -> null
      - tags             = {
          - "Name" = "dev-public"
        } -> null
      - tags_all         = {
          - "Name" = "dev-public"
        } -> null
      - vpc_id           = "vpc-0056d3f0be8e1f890" -> null
    }

  # aws_route_table_association.private_us_east_2a will be destroyed
  - resource "aws_route_table_association" "private_us_east_2a" {
      - id             = "rtbassoc-02700fd8dce2de06c" -> null
      - route_table_id = "rtb-05a27d825231eafed" -> null
      - subnet_id      = "subnet-0d30f7c2f10dc0254" -> null
    }

  # aws_route_table_association.private_us_east_2b will be destroyed
  - resource "aws_route_table_association" "private_us_east_2b" {
      - id             = "rtbassoc-0b6e72fb6b20dacdf" -> null
      - route_table_id = "rtb-05a27d825231eafed" -> null
      - subnet_id      = "subnet-00c2d8316c4d6565f" -> null
    }

  # aws_route_table_association.public_us_east_2a will be destroyed
  - resource "aws_route_table_association" "public_us_east_2a" {
      - id             = "rtbassoc-031f5975f1943436f" -> null
      - route_table_id = "rtb-055041828236e7c02" -> null
      - subnet_id      = "subnet-0260b11c015649fee" -> null
    }

  # aws_route_table_association.public_us_east_2b will be destroyed
  - resource "aws_route_table_association" "public_us_east_2b" {
      - id             = "rtbassoc-0ab6aa66661bd09c2" -> null
      - route_table_id = "rtb-055041828236e7c02" -> null
      - subnet_id      = "subnet-0fca4355936716298" -> null
    }

  # aws_subnet.private_us_east_2a will be destroyed
  - resource "aws_subnet" "private_us_east_2a" {
      - arn                                            = "arn:aws:ec2:us-east-2:240195868935:subnet/subnet-0d30f7c2f10dc0254" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-2a" -> null
      - availability_zone_id                           = "use2-az1" -> null
      - cidr_block                                     = "10.0.0.0/19" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-0d30f7c2f10dc0254" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = false -> null
      - owner_id                                       = "240195868935" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name"                            = "dev-private-us-east-2a"
          - "WorkSession"                     = "revision-1"
          - "kubernetes.io/cluster/dev-demo"  = "owned"
          - "kubernetes.io/role/internal-elb" = "1"
        } -> null
      - tags_all                                       = {
          - "Name"                            = "dev-private-us-east-2a"
          - "WorkSession"                     = "revision-1"
          - "kubernetes.io/cluster/dev-demo"  = "owned"
          - "kubernetes.io/role/internal-elb" = "1"
        } -> null
      - vpc_id                                         = "vpc-0056d3f0be8e1f890" -> null
    }

  # aws_subnet.private_us_east_2b will be destroyed
  - resource "aws_subnet" "private_us_east_2b" {
      - arn                                            = "arn:aws:ec2:us-east-2:240195868935:subnet/subnet-00c2d8316c4d6565f" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-2b" -> null
      - availability_zone_id                           = "use2-az2" -> null
      - cidr_block                                     = "10.0.32.0/19" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-00c2d8316c4d6565f" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = false -> null
      - owner_id                                       = "240195868935" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name"                            = "dev-private-us-east-2b"
          - "kubernetes.io/cluster/dev-demo"  = "owned"
          - "kubernetes.io/role/internal-elb" = "1"
        } -> null
      - tags_all                                       = {
          - "Name"                            = "dev-private-us-east-2b"
          - "kubernetes.io/cluster/dev-demo"  = "owned"
          - "kubernetes.io/role/internal-elb" = "1"
        } -> null
      - vpc_id                                         = "vpc-0056d3f0be8e1f890" -> null
    }

  # aws_subnet.public_us_east_2a will be destroyed
  - resource "aws_subnet" "public_us_east_2a" {
      - arn                                            = "arn:aws:ec2:us-east-2:240195868935:subnet/subnet-0260b11c015649fee" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-2a" -> null
      - availability_zone_id                           = "use2-az1" -> null
      - cidr_block                                     = "10.0.64.0/19" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-0260b11c015649fee" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "240195868935" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name"                           = "dev-public-us-east-2a"
          - "kubernetes.io/cluster/dev-demo" = "owned"
          - "kubernetes.io/role/elb"         = "1"
        } -> null
      - tags_all                                       = {
          - "Name"                           = "dev-public-us-east-2a"
          - "kubernetes.io/cluster/dev-demo" = "owned"
          - "kubernetes.io/role/elb"         = "1"
        } -> null
      - vpc_id                                         = "vpc-0056d3f0be8e1f890" -> null
    }

  # aws_subnet.public_us_east_2b will be destroyed
  - resource "aws_subnet" "public_us_east_2b" {
      - arn                                            = "arn:aws:ec2:us-east-2:240195868935:subnet/subnet-0fca4355936716298" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-2b" -> null
      - availability_zone_id                           = "use2-az2" -> null
      - cidr_block                                     = "10.0.96.0/19" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-0fca4355936716298" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "240195868935" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name"                           = "dev-public-us-east-2b"
          - "kubernetes.io/cluster/dev-demo" = "owned"
          - "kubernetes.io/role/elb"         = "1"
        } -> null
      - tags_all                                       = {
          - "Name"                           = "dev-public-us-east-2b"
          - "kubernetes.io/cluster/dev-demo" = "owned"
          - "kubernetes.io/role/elb"         = "1"
        } -> null
      - vpc_id                                         = "vpc-0056d3f0be8e1f890" -> null
    }

  # aws_vpc.main will be destroyed
  - resource "aws_vpc" "main" {
      - arn                                  = "arn:aws:ec2:us-east-2:240195868935:vpc/vpc-0056d3f0be8e1f890" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.0.0.0/16" -> null
      - default_network_acl_id               = "acl-02e80f15c466bf96c" -> null
      - default_route_table_id               = "rtb-097db29d2ec445d2a" -> null
      - default_security_group_id            = "sg-0adf17803b9a61637" -> null
      - dhcp_options_id                      = "dopt-e190378a" -> null
      - enable_classiclink                   = false -> null
      - enable_classiclink_dns_support       = false -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-0056d3f0be8e1f890" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-097db29d2ec445d2a" -> null
      - owner_id                             = "240195868935" -> null
      - tags                                 = {
          - "Name"        = "dev-main"
          - "WorkSession" = "revision-1"
        } -> null
      - tags_all                             = {
          - "Name"        = "dev-main"
          - "WorkSession" = "revision-1"
        } -> null
    }

Plan: 0 to add, 0 to change, 14 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: 