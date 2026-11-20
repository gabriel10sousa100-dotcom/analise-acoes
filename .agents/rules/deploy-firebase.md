---
trigger: always_on
---

# Publicação automática no Firebase

O usuário usa o app pelo link publicado https://analise-acoes-b3.web.app (Firebase Hosting, site `analise-acoes-b3`).

- A publicação é feita pelo GitHub Actions quando uma alteração entra na branch `main`. O fluxo valida o JavaScript do `index.html`, publica somente o Firebase Hosting e confere a versão servida pelo site.
- Confira o resultado da execução **Publicar site no Firebase** antes de informar que a atualização está no ar.
- A conexão inicial com o projeto do Google Cloud é configurada por `.github/scripts/autorizar-firebase.sh`.

