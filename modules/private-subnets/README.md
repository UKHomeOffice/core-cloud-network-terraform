# 🔧 Terraform Module: Dynamic /27 Private Subnets

This module dynamically creates **three `/27` private subnets** from a given AWS VPC, skipping the first few small CIDR blocks (typically reserved by AWS LZA for e.g. tgw use).

Supports **VPC CIDRs** of `/20` (large), `/22` (medium), and `/24` (small).

---

## 📦 Features

- 🔍 Dynamically looks up a VPC by `Name` tag
- 📐 Calculates proper subnet sizing to safely carve `/27`s
- 🚫 Skips the first 6 subnet indexes to avoid overlapping with existing `/28`s
- 🌐 Distributes the subnets across **3 Availability Zones**
- ✅ Compatible with varying VPC sizes

---

## 📥 Input Variables

| Name      | Type          | Description                                         |
|-----------|---------------|-----------------------------------------------------|
| `vpc_name`| `string`      | The value of the VPC's `Name` tag                  |
| `tags`    | `map(string)` | Tags to apply to all created subnets (optional)    |

---

## 🚀 Usage

```hcl
module "private_subnets" {
  source   = "./modules/private-subnets"

  vpc_name = "workload-dev-vpc"

  tags = {
    project-id        = "CORECLOUD"
    service-id        = "Infrastructure"
    portfolio-id      = "CTO"
    cost-centre       = "0123456789"
    finance-account-id = "tbd"
  }
}
