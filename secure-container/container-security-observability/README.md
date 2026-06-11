# 🛡 Container Security & Observability

> *"Un contenedor seguro no es el que nunca falla — es el que cuando algo ocurre, ya lo sabías antes que el atacante."*

Proyecto de portafolio que demuestra una implementación end-to-end de **seguridad en contenedores** y **observabilidad** sobre Kubernetes (AKS), siguiendo principios de **DevSecOps**, **GitOps** y **Zero Trust**.

---

## 🎯 ¿Qué demuestra este proyecto?

| Capacidad | Herramientas |
|---|---|
| Imagen distroless + hardening | Dockerfile multi-stage, `nonroot`, `readOnlyRootFilesystem` |
| Seguridad en supply chain | Cosign (keyless OIDC), SBOM con Syft, attestation en ACR |
| Análisis estático (SAST) | Semgrep (`p/nodejs`, `p/owasp-top-ten`, `p/secrets`) |
| Escaneo de vulnerabilidades | Trivy (rompe pipeline si hay CRITICAL/HIGH) |
| Admission control | Kyverno (verifica firma, prohíbe privileged, enforce non-root) |
| Runtime threat detection | Falco con reglas personalizadas (eBPF, no módulo kernel) |
| Network policies Zero Trust | Deny-all por defecto + allow-list explícita |
| Métricas de aplicación | Prometheus client (`prom-client`), ServiceMonitor |
| Dashboards | Grafana (SLO, latencia, Falco events, logs) |
| Logs centralizados | Loki + Promtail (structured JSON logging) |
| Alertas | PrometheusRule → Alertmanager → Slack (SLO + seguridad) |
| GitOps delivery | ArgoCD Hub & Spoke, Kustomize overlays (dev/prd) |
| CI/CD | GitHub Actions (build → scan → sign → push → deploy) |

---

## 📐 Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│  GitHub Actions CI/CD Pipeline                                  │
│  Build → Semgrep SAST → Trivy scan → Cosign sign → Push ACR    │
│                      → Syft SBOM → Attestation                  │
└────────────────────────────┬────────────────────────────────────┘
                             │ GitOps (tag commit)
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  AKS — Kubernetes Runtime                                       │
│  ┌──────────┐  ┌─────────────┐  ┌──────────┐  ┌────────────┐  │
│  │ Kyverno  │  │  demo-api   │  │  Falco   │  │  Network   │  │
│  │ Policies │  │ (distroless │  │ (eBPF)   │  │  Policies  │  │
│  │ admission│  │  non-root   │  │ runtime  │  │ zero-trust │  │
│  │ + verify │  │  read-only) │  │ detect   │  │ deny-all   │  │
│  └──────────┘  └─────────────┘  └──────────┘  └────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │ scrape / logs / events
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  Observability Stack (namespace: monitoring)                    │
│  Prometheus → Grafana dashboards (SLO + Falco)                  │
│  Loki + Promtail → structured log aggregation                   │
│  Alertmanager → Slack (#platform-critical, #security-alerts)    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📂 Estructura

```
container-security-observability/
├── app/
│   ├── server.js              # API Node.js con métricas Prometheus
│   └── package.json
├── Dockerfile                 # Multi-stage distroless, nonroot, read-only FS
├── .github/
│   └── workflows/
│       └── container-security.yml   # Pipeline CI/CD completo
├── k8s/
│   ├── base/
│   │   ├── deployment.yaml    # Hardening: securityContext, capabilities, probes
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   ├── overlays/
│   │   ├── dev/               # 1 réplica, recursos reducidos
│   │   └── prd/               # HPA 2-8 réplicas, recursos de producción
│   ├── security/
│   │   ├── kyverno-policies.yaml    # verify-signature + pod security
│   │   ├── network-policies.yaml    # Zero Trust deny-all + allow-list
│   │   └── falco-rules.yaml         # Custom rules: shell, write, egress, privesc
│   └── observability/
│       ├── prometheus-rules.yaml    # SLO alerts + Falco security alerts
│       └── grafana-dashboard.json   # Dashboard importable
└── helm/
    └── values-stack.yaml      # Instala Prometheus, Loki, Falco, Kyverno
```

---

## 🚀 Despliegue rápido

### Prerequisitos
- AKS cluster (o cualquier K8s ≥ 1.28)
- `kubectl`, `helm`, `kustomize`, `cosign`
- Azure Container Registry (ACR)
- GitHub Actions secrets configurados (ver sección de secretos)

### 1. Instalar stack de observabilidad y seguridad

```bash
# Agregar repos Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add falcosecurity       https://falcosecurity.github.io/charts
helm repo add grafana             https://grafana.github.io/helm-charts
helm repo add kyverno             https://kyverno.github.io/kyverno
helm repo update

# Kyverno (admission controller)
helm upgrade --install kyverno kyverno/kyverno \
  -n kyverno --create-namespace \
  -f helm/values-stack.yaml

# Prometheus + Grafana + Alertmanager
helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f helm/values-stack.yaml

# Falco (runtime security con eBPF)
helm upgrade --install falco falcosecurity/falco \
  -n falco --create-namespace \
  -f helm/values-stack.yaml
```

### 2. Aplicar políticas de seguridad

```bash
kubectl apply -f k8s/security/kyverno-policies.yaml
kubectl apply -f k8s/security/network-policies.yaml
kubectl apply -f k8s/security/falco-rules.yaml
kubectl apply -f k8s/observability/prometheus-rules.yaml
```

### 3. Desplegar la aplicación (DEV)

```bash
kustomize build k8s/overlays/dev | kubectl apply -f -
```

### 4. Importar dashboard en Grafana

```bash
# Port-forward Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring

# Importar: Grafana UI → Dashboards → Import → subir grafana-dashboard.json
```

---

## 🔐 Secretos requeridos (GitHub Actions)

| Secret | Descripción |
|---|---|
| `ACR_NAME` | Nombre del ACR (sin `.azurecr.io`) |
| `ACR_CLIENT_ID` | Service principal con AcrPush |
| `ACR_CLIENT_SECRET` | Password del SP |
| `GH_PAT` | Personal Access Token para commits de GitOps |
| `SLACK_WEBHOOK_URL` | Webhook de Alertmanager |
| `GRAFANA_ADMIN_PASSWORD` | Password inicial de Grafana |

---

## 🔍 Puntos clave del diseño

### Seguridad en supply chain (SLSA Level 2+)
Cada imagen pasa por: `Build` → `SAST` → `Trivy` (gate CRITICAL/HIGH) → `Cosign sign` (keyless OIDC via GitHub Actions) → `SBOM attest`. Kyverno verifica la firma en cada admission antes de crear el pod, rechazando cualquier imagen no firmada o modificada post-push.

### Imagen distroless
La imagen final (`gcr.io/distroless/nodejs20-debian12:nonroot`) no contiene shell, package manager ni herramientas de depuración. Superficie de ataque mínima. UID 65532 (nonroot). Filesystem raíz read-only; solo `/tmp` en memoria (emptyDir).

### Falco eBPF
Falco corre en modo eBPF (sin módulo kernel), compatible con AKS. Las reglas personalizadas detectan: ejecución de shell en container distroless (debería ser imposible), escritura fuera de `/tmp`, conexiones de red no autorizadas, escalada de privilegios y acceso a secretos K8s.

### Zero Trust Networking
Namespace con `deny-all` por defecto. Solo se permite tráfico declarado explícitamente: ingress desde `ingress-nginx`, scrape desde `prometheus` (puerto 3000), y egress DNS hacia `kube-dns`. Sin `0.0.0.0/0` en ninguna regla.

### SLO codificado como código
`PrometheusRule` define dos SLOs: disponibilidad ≥ 99.5% (error rate ≤ 0.5%) y latencia p99 < 500ms. Las alertas incluyen `runbook_url` con procedimientos de respuesta.

---

## 📊 Métricas expuestas (`GET /metrics`)

| Métrica | Tipo | Descripción |
|---|---|---|
| `http_requests_total` | Counter | Total requests por método, ruta y status code |
| `http_request_duration_seconds` | Histogram | Latencia por método, ruta y status code |
| `http_active_requests` | Gauge | Requests activos en el momento |
| `app_info` | Gauge | Versión de la app y versión de Node.js |

---

## 🏷 Decisiones de arquitectura

| Decisión | Alternativas consideradas | Justificación |
|---|---|---|
| Distroless en vez de Alpine | Alpine, Chainguard | Mínima superficie de ataque; sin shell imposibilita la mayoría de ataques post-exploit |
| Cosign keyless (OIDC) | Cosign con clave privada | Sin gestión de secretos de firma; la identidad es el workflow de GitHub, no una clave rotable |
| Kyverno en vez de OPA/Gatekeeper | OPA, Gatekeeper | API nativa de K8s, mutación + validación + generación en un solo CRD |
| Falco eBPF en vez de módulo kernel | Falco kernel module | AKS no expone el kernel a modificaciones; eBPF funciona sin privilegios de nodo |
| Loki en vez de Elasticsearch | OpenSearch, EFK stack | Footprint mínimo, integración nativa con Grafana, sin esquema predefinido |

---

## 🔗 Referencias

- [Sigstore / Cosign](https://docs.sigstore.dev/)
- [Kyverno policies](https://kyverno.io/policies/)
- [Falco rules](https://falco.org/docs/rules/)
- [SLSA framework](https://slsa.dev/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NSA/CISA Kubernetes Hardening Guide](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)

---

*Lucho Navarrete — Senior Cloud & Enterprise Architect | [LinkedIn](https://linkedin.com/in/lucho-navarrete) | [GitHub](https://github.com/LuchoN83)*
