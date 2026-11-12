---
trigger: always_on
---

# Publicar sempre no Firebase

O usuário usa o app pelo link publicado https://analise-acoes-b3.web.app (Firebase Hosting, site `analise-acoes-b3`).

- Depois de QUALQUER alteração no app (index.html, sw.js, manifest.json, ícones etc.), publique no Firebase sem perguntar:
  `firebase.cmd deploy --only hosting` (use `firebase.cmd`, pois o `firebase.ps1` é bloqueado pela política de execução do PowerShell; precisa de rede).
- Antes de publicar, valide a sintaxe do JavaScript inline do index.html.
- Ao terminar, informe que foi publicado e que basta recarregar o site.

