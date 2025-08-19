📌 Proyecto – container-security-signed

🎯 Objetivo

Imagen Docker mínima, no-root (distroless).

Firmar la imagen con Cosign (clave propia).

Verificar/enforce firma en Kubernetes con Kyverno (solo pasa si la firma coincide con tu clave).

---

🏗 Arquitectura

```mermaid
flowchart LR
  %% ====== Actores / Sistemas ======
  Dev[Developer / DevSecOps]:::actor
  subgraph CI[CI/CD - Build, Scan, Sign & Push]
    GRepo[GitHub Repo]
    Build["1.Build imagen - Docker"]
    TrivyFS["2.Trivy FS - código/IaC"]
    TrivyImg["3.Trivy Image - CVEs"]
    Cosign["4.Cosign Sign - firma"]
    GHCR["5.GHCR: Push imagen firmada"]
  end

  subgraph K8S[Kubernetes - Deploy & Admission]
    Helm["6.Helm Upgrade/Install"]
    Kyverno["7.Kyverno Admission: verifyImages\nValida firma con cosign.pub"]
    Workload["8.Workload: Deployment/Pod"]
    Test["9.Post-Deploy: rollout wait + test"]
  end

  %% ====== Flujo CI/CD ======
  Dev -->|Push code| GRepo
  GRepo --> Build --> TrivyFS --> TrivyImg --> Cosign --> GHCR

  %% ====== Flujo de Deploy / Admission ======
  Dev -->|kubectl/helm| Helm
  Helm -->|Manifiesto - imagen:tag| Kyverno
  Kyverno -->|Firma válida - cosign.pub| Workload
  Kyverno -.->|Firma inválida - inexistente| Deny{{DENY}}

  %% ====== Métricas/Verificación ======
  Workload --> Test

  %% ====== Estilos ======
  classDef actor fill:#eef,stroke:#557,stroke-width:1px;
  classDef good fill:#e6ffed,stroke:#198754,stroke-width:1px,color:#0b4126;
  classDef warn fill:#fff4e6,stroke:#fd7e14,stroke-width:1px,color:#5f370e;
  classDef stop fill:#ffe6e6,stroke:#dc3545,stroke-width:1px,color:#5b1515;

  class Workload,GHCR good
  class Kyverno warn
```

🎬 Diagrama de Secuencia
```mermaid
sequenceDiagram
  participant Dev as Developer/DevSecOps
  participant GH as GitHub Repo
  participant CI as GitHub Actions (CI/CD)
  participant REG as GHCR Registry
  participant CL as Kubernetes Cluster
  participant KYN as Kyverno Admission
  participant APP as Deployment/Pod

  Dev->>GH: 0) push code
  GH->>CI: 1) trigger pipeline

  %% CI/CD - Build & Security Gates
  CI->>CI: 2) Docker build
  CI->>CI: 3) Trivy FS (código/IaC)\nFAIL si HIGH/CRITICAL
  CI->>CI: 4) Trivy Image (CVEs)\nFAIL si HIGH/CRITICAL
  CI->>REG: 5) Push imagen (sha/latest)
  CI->>REG: 6) Cosign sign (firma de imagen)

  %% Deploy
  Dev->>CL: 7) helm upgrade --install (imagen:tag)
  CL->>KYN: 8) Admission request (verifyImages)
  KYN->>REG: 9) Verificar firma vs cosign.pub
  alt Firma válida
    KYN-->>CL: allow
    CL->>APP: 10) Crear/actualizar deployment
    CL-->>Dev: rollout success + helm test ok
  else Firma inválida / sin firma
    KYN-->>CL: DENY
    CL-->>Dev: error: failed image verification
  end
```
