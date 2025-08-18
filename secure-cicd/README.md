# 📌 Proyecto 2 – secure-cicd
### 🎯 Objetivo

Implementar un pipeline CI/CD seguro para aplicaciones contenedorizadas, utilizando GitHub Actions, Trivy, GHCR, Kubernetes y Helm, garantizando análisis de seguridad, despliegues confiables y controlados.

---

## 🏗️ Arquitectura
```mermaid
flowchart LR
  Dev[DevSecOps Engineer] -->|Push Code| GitHub[GitHub Repo]
  GitHub -->|CI/CD| Actions[GitHub Actions]

  Actions -->|1.Build| Build[Docker Build]
  Actions -->|2.Scan FS| TrivyFS[Trivy FS - codigo / IaC]
  Actions -->|3.Scan Image| TrivyImg[Trivy Image - CVEs]
  Actions -->|4.Publish| GHCR[(GHCR Registry)]
  Actions -->|5.Deploy| Helm[Helm Upgrade --install]

  Helm -->|Rollout & Tests| K8s[(Kubernetes Cluster)]
