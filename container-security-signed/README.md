📌 Proyecto – container-security-signed
🎯 Objetivo

Imagen Docker mínima, no-root (distroless).

Firmar la imagen con Cosign (clave propia).

Verificar/enforce firma en Kubernetes con Kyverno (solo pasa si la firma coincide con tu clave).

---
🏗 Arquitectura
```mermaid
flowchart LR
  Dev[DevSecOps Engineer] -->|Build & Push| GHCR[(GitHub Container Registry)]
  Dev -->|Sign (cosign)| GHCR
  User[Developer] -->|kubectl/Helm| K8s[(Kubernetes Cluster)]
  K8s -->|Admission| Kyverno[Kyverno\nClusterPolicy: verifyImages]
  Kyverno -->|allow/deny| Workload[(Deployment/Pod)]
