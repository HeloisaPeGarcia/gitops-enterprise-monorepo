#!/usr/bin/env bash
set -euo pipefail

echo "========================================================"
echo "  Bootstrap do Ambiente GitOps Local (Linux / macOS / WSL)"
echo "========================================================"

for cmd in kind kubectl; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "[ERRO] '$cmd' não está instalado. Abortando."; exit 1; }
done

echo "[1/5] Criando cluster Kind..."
kind create cluster --name gitops-demo --config scripts/kind-config.yaml || true

echo "[2/5] Instalando ArgoCD..."
kubectl create namespace argocd 2>/dev/null || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "[3/5] Aguardando argocd-server..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server \
  -n argocd --timeout=180s

# CRDs do ArgoCD precisam estar estabelecidos antes de aplicar AppProject/Application
echo "[4/5] Aguardando CRDs do ArgoCD..."
kubectl wait --for=condition=established crd/applications.argoproj.io --timeout=60s
kubectl wait --for=condition=established crd/appprojects.argoproj.io --timeout=60s

echo "[5/5] Aplicando AppProjects e Root App..."
kubectl apply -f argocd/projects/system-project.yaml
kubectl apply -f argocd/projects/workloads-project.yaml
kubectl apply -f argocd/root-app.yaml

echo ""
echo "  Cluster pronto!"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Senha: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
