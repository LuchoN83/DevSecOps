# 📌 Proyecto 2 – secure-cicd
### 🎯 Objetivo

Implementar un pipeline CI/CD seguro para aplicaciones contenedorizadas, utilizando GitHub Actions, Trivy, GHCR, Kubernetes y Helm, garantizando análisis de seguridad, despliegues confiables y controlados.

---

## 🏗️ Arquitectura
flowchart LR
  Dev[DevSecOps Engineer] -->|Push Code| GitHub[GitHub Repo]
  GitHub -->|CI/CD| Actions[GitHub Actions]

  Actions -->|1.Build| Build[Docker Build]
  Actions -->|2.Scan FS| TrivyFS[Trivy FS - codigo / IaC]
  Actions -->|3.Scan Image| TrivyImg[Trivy Image - CVEs]
  Actions -->|4.Publish| GHCR[(GHCR Registry)]
  Actions -->|5.Deploy| Helm[Helm Upgrade --install]

  Helm -->|Rollout & Tests| K8s[(Kubernetes Cluster)]
## ⚙️ Componentes

GitHub Actions → Orquesta el pipeline CI/CD.
Trivy (FS & Image) → Escaneo de seguridad:
    - trivy fs → detecta vulnerabilidades en código e IaC.
    - trivy image → analiza la imagen Docker y bloquea el pipeline si encuentra CVEs HIGH/CRITICAL.
GHCR (GitHub Container Registry) → Almacena la imagen validada y firmada.
Kubernetes + Helm → Despliega la aplicación de manera atómica, con helm upgrade --install --atomic --wait y valida con helm test.
