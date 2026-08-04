# Bootstrap do Estado Remoto (IaC)

Este módulo **deve ser executado antes** de qualquer `terragrunt run-all` nos demais módulos.
Ele cria o bucket S3 e a tabela DynamoDB que o Terragrunt usa como backend de estado remoto.

## Por quê isso existe?

O Terragrunt usa S3 para guardar o estado (`tfstate`) de todos os outros módulos.
Porém, o próprio S3 precisa ser criado primeiro — com backend **local** temporário.

## Como usar

```bash
# 1. Configure as credenciais AWS
export AWS_REGION=us-east-1
export AWS_PROFILE=gitops-dev  # ou configure via IAM Role / SSO

# 2. Execute para o ambiente DEV
cd iac/bootstrap
TF_VAR_env=dev TF_VAR_aws_region=us-east-1 terraform init
TF_VAR_env=dev TF_VAR_aws_region=us-east-1 terraform apply

# 3. Execute para o ambiente PROD
TF_VAR_env=prod TF_VAR_aws_region=us-east-1 terraform apply

# 4. Agora os demais módulos podem ser inicializados normalmente
cd ../environments/dev
TG_ENV=dev terragrunt run-all init
TG_ENV=dev terragrunt run-all plan
```

> ⚠️ **Atenção:** Nunca destrua o bucket de estado com `terraform destroy` enquanto outros módulos tiverem tfstate guardado nele.
