@echo off
setlocal EnableDelayedExpansion

echo ========================================================
echo   Bootstrap do Ambiente GitOps Local (Windows)
echo ========================================================

where kind >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Kind nao esta instalado: https://kind.sigs.k8s.io/
    exit /b 1
)

where kubectl >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] kubectl nao esta instalado.
    exit /b 1
)

echo [1/5] Criando cluster Kind...
kind create cluster --name gitops-demo --config scripts/kind-config.yaml
if %ERRORLEVEL% NEQ 0 (
    echo [AVISO] Cluster ja existe. Continuando...
)

echo [2/5] Instalando ArgoCD...
kubectl create namespace argocd 2>nul || echo [INFO] Namespace argocd ja existe.
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo [3/5] Aguardando argocd-server...
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=180s
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] ArgoCD nao ficou pronto no tempo esperado.
    exit /b 1
)

REM CRDs do ArgoCD precisam estar estabelecidos antes de aplicar AppProject/Application
echo [4/5] Aguardando CRDs do ArgoCD...
kubectl wait --for=condition=established crd/applications.argoproj.io --timeout=60s
kubectl wait --for=condition=established crd/appprojects.argoproj.io --timeout=60s

echo [5/5] Aplicando AppProjects e Root App...
kubectl apply -f argocd/projects/system-project.yaml
kubectl apply -f argocd/projects/workloads-project.yaml
kubectl apply -f argocd/root-app.yaml

echo.
echo   Cluster pronto!
echo   kubectl port-forward svc/argocd-server -n argocd 8080:443
echo   Senha: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" ^| powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String([Console]::In.ReadToEnd().Trim()))"
