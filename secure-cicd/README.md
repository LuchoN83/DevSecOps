# 📌 Proyecto 2 – secure-cicd
### 🎯 Objetivo

Implementar un pipeline CI/CD seguro para aplicaciones contenedorizadas, utilizando GitHub Actions, Trivy, GHCR, Kubernetes y Helm, garantizando análisis de seguridad, despliegues confiables y controlados.

---

## 🏗️ Arquitectura
flowchart LR
    DevSecOps((DevSecOps Engineer)) --> |Push Code| GitHub[GitHub Repository] 
    GitHub --> |CI/CD Pipeline| GitHubActions[GitHub Actions]
    
    GitHubActions --> |1. Build App| DockerBuild[Docker Build]
    GitHubActions --> |2. Trivy FS| TrivyFS[Trivy File System Scan]
    GitHubActions --> |3. Trivy Image| TrivyImage[Trivy Image Scan]
    GitHubActions --> |4. Publish| GHCR[GitHub Container Registry]
    GitHubActions --> |5. Deploy| Helm[Helm Atomic Deployment]

    Helm --> |Rollout + helm test| K8s[(Kubernetes Cluster)]

## ⚙️ Componentes

GitHub Actions → Orquesta el pipeline CI/CD.
Trivy (FS & Image) → Escaneo de seguridad:
    - trivy fs → detecta vulnerabilidades en código e IaC.
    - trivy image → analiza la imagen Docker y bloquea el pipeline si encuentra CVEs HIGH/CRITICAL.
GHCR (GitHub Container Registry) → Almacena la imagen validada y firmada.
Kubernetes + Helm → Despliega la aplicación de manera atómica, con helm upgrade --install --atomic --wait y valida con helm test.
