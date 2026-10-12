# Axion 3-Tier Enterprise Infrastructure on Azure

Aapke architecture diagram ke anusaar **Enterprise Multi-Environment Setup** (`prod` aur `preprod`) **Parent Modules** aur **Dedicated Child Modules** ke saath prepare kiya gaya hai.

Har environment ka apna isolated state aur configuration hai, aur har architectural layer ka apna separate child module folder hai.

---

## 🏛️ Architecture Overview

```
Internet (User Traffic)
       │
       ▼ [Port 80/443 Public IP]
┌─────────────────────────────────────────────────────────────┐
│ Azure Application Gateway (appgw-axion-<env>)              │
│ [Dedicated Subnet: snet-appgw]                              │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼ [Private HTTP Routing]
┌─────────────────────────────────────────────────────────────┐
│ Frontend Subnet (snet-frontend)                             │
│  ├── VM Frontend 1 (Nginx Web Server)                       │
│  └── VM Frontend 2 (Nginx Web Server)                       │
│  └── Availability Set (HA)                                 │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼ [Internal LB: Private IP]
┌─────────────────────────────────────────────────────────────┐
│ Internal Azure Load Balancer (ilb-axion-backend-<env>)      │
│ [Subnet: snet-backend]                                      │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼ [Private Backend Traffic]
┌─────────────────────────────────────────────────────────────┐
│ Backend Subnet (snet-backend)                               │
│  ├── VM Backend 1 (Application API Service)                 │
│  └── VM Backend 2 (Application API Service)                 │
│  └── Availability Set (HA)                                 │
└──────────────┬──────────────────────────────────────────────┘
               │
               ▼ [Isolated DB Traffic (Port 5432)]
┌─────────────────────────────────────────────────────────────┐
│ Database Subnet (snet-database)                             │
│  └── VM Database 1 (PostgreSQL / Dedicated Managed Disk)    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure (Multi-Environment & Modular)

```text
axion infra/
├── environments/
│   ├── preprod/                # PreProd Parent Module
│   │   ├── main.tf             # Orchestrates child modules for PreProd
│   │   ├── variables.tf        # PreProd variables & default sizing
│   │   ├── terraform.tfvars    # PreProd specific configuration
│   │   └── provider.tf         # Azure provider configuration
│   │
│   └── prod/                   # Production Parent Module
│       ├── main.tf             # Orchestrates child modules for Prod
│       ├── variables.tf        # Prod variables & high-capacity sizing
│       ├── terraform.tfvars    # Production specific configuration
│       └── provider.tf         # Azure provider configuration
│
├── modules/                    # Reusable Child Modules (Individual Directories)
│   ├── resource_group/         # Child Module 1: Resource Group (Rg-axion-<env>)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── networking/             # Child Module 2: VNet, 4 Subnets & 4 NSGs
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── application_gateway/    # Child Module 3: Azure App Gateway v2 & Public IP
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── internal_lb/            # Child Module 4: Private Azure Load Balancer
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── compute_frontend/       # Child Module 5: 2x Frontend VMs + AvSet + AppGW Pool Assoc
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── compute_backend/        # Child Module 6: 2x Backend VMs + AvSet + ILB Pool Assoc
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── compute_database/       # Child Module 7: 1x DB VM + Dedicated Managed Data Disk
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── .gitignore                  # Git ignore for state, logs, and sensitive keys
└── README.md                   # Complete Documentation & Usage Guide
```

---

## ⚙️ Environment Comparison (PreProd vs Prod)

| Parameter | PreProd (`environments/preprod`) | Production (`environments/prod`) |
| :--- | :--- | :--- |
| **Resource Group** | `Rg-axion-preprod` | `Rg-axion-prod` |
| **Virtual Network** | `vnet-axion-preprod` (`10.10.0.0/16`) | `vnet-axion-prod` (`10.0.0.0/16`) |
| **App Gateway Capacity** | `1` instance (Cost-optimized) | `2` instances (High-availability) |
| **Frontend VM Sizing** | `Standard_B1s` (2 instances) | `Standard_B2s` (2 instances) |
| **Backend VM Sizing** | `Standard_B1s` (2 instances) | `Standard_B2s` (2 instances) |
| **Database VM Sizing** | `Standard_B2s` | `Standard_B2s` |
| **DB Managed Disk** | `32 GB` Standard SSD | `64 GB` Standard SSD |
| **Tags Environment** | `Environment = "PreProd"` | `Environment = "Prod"` |

---

## 🛡️ Best Practices Implemented

1. **Complete Environment State Isolation**:
   - `preprod` aur `prod` ke alag directories hone ki wajah se inka Terraform state file completely separate rehta hai. PreProd me test karte waqt Production par koi impact nahi padta.
2. **Reusability via Child Modules**:
   - Dono environments (`preprod` aur `prod`) same standard child modules (`../../modules/*`) ko consume karte hain. Code duplication zero hai.
3. **Strict 3-Tier Security (NSGs)**:
   - **App Gateway NSG**: Internet se sirf HTTP/HTTPS traffic aur Azure `GatewayManager` management ports allow hain.
   - **Frontend NSG**: Traffic sirf App Gateway subnet se accept karta hai.
   - **Backend NSG**: Traffic sirf Frontend subnet aur health probes se accept karta hai.
   - **Database NSG**: Port 5432 sirf Backend subnet se accept karta hai.
4. **Automated Secure SSH Key Generation**:
   - Koi bhi hardcoded password use nahi hua hai. Har environment automatically apna secure 4096-bit RSA SSH keypair generate karta hai (`id_rsa_preprod` aur `id_rsa_prod`), jo `.gitignore` me protected hain.
5. **Output Cleanliness**:
   - Root level `output.tf` ko exclude rakha gaya hai jaisa aapne instruct kiya tha.

---

## 🚀 Deployment Guide

### Option 1: Deploy PreProd Environment

```powershell
# PreProd directory me jayein
cd "environments/preprod"

# Initialize karein
terraform init

# Plan check karein
terraform plan

# Apply karein
terraform apply
```

### Option 2: Deploy Production Environment

```powershell
# Prod directory me jayein
cd "environments/prod"

# Initialize karein
terraform init

# Plan check karein
terraform plan

# Apply karein
terraform apply
```

---

## 🧹 Destroy / Cleanup

Kisi bhi environment ko destroy karne ke liye us environment ki directory me jakar run karein:

```powershell
terraform destroy
```
