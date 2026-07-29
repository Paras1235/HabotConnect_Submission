# HabotConnect Cloud & DevOps Engineering Hiring Project Submission

**Candidate:** Paras Thakur[cite: 1]  
**Contact:** thakurparas330@gmail.com /[cite: 1] 9459682330  
**Submission Date:**[cite: 1] 29/07/2026  

## Project Overview
This repository contains the production-grade deliverables for HabotConnect, ensuring secure Infrastructure as Code (IaC), fail-closed CI/CD pipeline gates, and strict data contract schemas to eliminate runtime drift and data security vulnerabilities.

### Repository Structure
* `01_Terraform_IaC/`: Secure GCS raw landing bucket (D0) with CMEK and uniform access, alongside BigQuery dataset (D1) with Row-Level Security (RLS) policies[cite: 1].
* `02_CICD_Poka_Yoke/`: GitHub Actions workflow enforcing a fail-closed CI/CD build gate covering linters, formatters, and secrets scanning[cite: 1].
* `03_DCYN_Schema_Validation/`: Django REST Framework (DRF) serializers paired with the custom DCYN library to guarantee strict binary compliance mapping (`Y`/`N`)[cite: 1].