#!/usr/bin/env bash
set -euo pipefail

project=analise-de-acoes-531a3
project_number=324263476770
pool=github-b3-hosting
provider=github
service_account_id=github-b3-hosting-deploy
service_account_email="$service_account_id@$project.iam.gserviceaccount.com"
repo_id=1345635839
owner_id=295445077
issuer=https://token.actions.githubusercontent.com
workflow="gabriel10sousa100-dotcom/analise-acoes/.github/workflows/deploy-firebase.yml@refs/heads/main"
mapping="google.subject=assertion.sub,attribute.repository_id=assertion.repository_id,attribute.repository_owner_id=assertion.repository_owner_id,attribute.ref=assertion.ref,attribute.workflow_ref=assertion.workflow_ref,attribute.event_name=assertion.event_name"
condition="assertion.repository_owner_id == '$owner_id' && assertion.repository_id == '$repo_id' && assertion.ref == 'refs/heads/main' && assertion.workflow_ref == '$workflow' && assertion.event_name in ['push', 'workflow_dispatch']"

actual_number=$(gcloud projects describe "$project" --format='value(projectNumber)')
if [[ "$actual_number" != "$project_number" ]]; then
  echo "O número do projeto $project é diferente do esperado." >&2
  exit 1
fi

gcloud services enable iam.googleapis.com iamcredentials.googleapis.com sts.googleapis.com \
  --project="$project" --quiet

if ! gcloud iam workload-identity-pools describe "$pool" \
    --project="$project" --location=global --format='value(name)' >/dev/null 2>&1; then
  gcloud iam workload-identity-pools create "$pool" --project="$project" \
    --location=global --display-name='GitHub B3 Hosting' --quiet
fi

provider_args=(--project="$project" --location=global --workload-identity-pool="$pool")
if existing_provider=$(gcloud iam workload-identity-pools providers describe "$provider" "${provider_args[@]}" \
    --format=json 2>/dev/null); then
  python3 -c '
import json
import sys

provider = json.load(sys.stdin)
mapping = dict(entry.split("=", 1) for entry in sys.argv[3].split(","))
if (
    provider.get("attributeCondition") != sys.argv[1]
    or provider.get("oidc", {}).get("issuerUri") != sys.argv[2]
    or provider.get("attributeMapping") != mapping
    or provider.get("state") != "ACTIVE"
    or provider.get("disabled")
):
    sys.exit("Já existe uma autorização diferente com esse nome no Google Cloud.")
' "$condition" "$issuer" "$mapping" <<< "$existing_provider"
else
  gcloud iam workload-identity-pools providers create-oidc "$provider" "${provider_args[@]}" \
    --display-name='GitHub Actions' --issuer-uri="$issuer" --attribute-mapping="$mapping" \
    --attribute-condition="$condition" --quiet
fi

if ! gcloud iam service-accounts describe "$service_account_email" \
    --project="$project" --format='value(email)' >/dev/null 2>&1; then
  gcloud iam service-accounts create "$service_account_id" --project="$project" \
    --display-name='GitHub B3 Firebase Hosting' --quiet
fi

for role in roles/firebasehosting.admin roles/serviceusage.apiKeysViewer roles/serviceusage.serviceUsageConsumer; do
  gcloud projects add-iam-policy-binding "$project" --member="serviceAccount:$service_account_email" \
    --role="$role" --condition=None --quiet >/dev/null
done

gcloud iam service-accounts add-iam-policy-binding "$service_account_email" --project="$project" \
  --member="principalSet://iam.googleapis.com/projects/$project_number/locations/global/workloadIdentityPools/$pool/attribute.repository_id/$repo_id" \
  --role=roles/iam.workloadIdentityUser --condition=None --quiet >/dev/null

echo 'Conexão do GitHub com o Firebase autorizada.'
