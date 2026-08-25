@echo off
title Servidor B3 - Acesso pelo Celular Android
color 0b
cls
echo ================================================================
echo    B3 - SERVIDOR LOCAL PARA ACESSO NO CELULAR ANDROID
echo ================================================================
echo.
echo [1] Certifique-se de que o Celular e o PC estao no MESMO Wi-Fi.
echo.
echo [2] No seu Celular Android, abra o Google Chrome e digite:
echo.
echo        http://192.168.1.117:8080
echo.
echo [3] No Chrome do celular, toque nos 3 pontinhos e selecione:
echo        "Instalar Aplicativo" ou "Adicionar a tela inicial"
echo.
echo ================================================================
echo  Servidor rodando... (Para fechar, basta fechar esta janela)
echo ================================================================
echo.
powershell -ExecutionPolicy Bypass -Command "$listener = New-Object System.Net.HttpListener; $listener.Prefixes.Add('http://*:8080/'); $listener.Start(); Write-Host 'Servidor pronto em http://192.168.1.117:8080' -ForegroundColor Green; while ($listener.IsListening) { $ctx = $listener.GetContext(); $req = $ctx.Request; $res = $ctx.Response; $rawUrl = $req.RawUrl.Split('?')[0]; if ($rawUrl -eq '/') { $rawUrl = '/index.html' }; $filePath = (Get-Location).Path + $rawUrl.Replace('/', '\'); if (Test-Path $filePath) { $bytes = [System.IO.File]::ReadAllBytes($filePath); $ext = [System.IO.Path]::GetExtension($filePath).ToLower(); $mime = switch ($ext) { '.html' {'text/html; charset=utf-8'} '.json' {'application/json'} '.js' {'application/javascript'} '.css' {'text/css'} '.svg' {'image/svg+xml'} default {'application/octet-stream'} }; $res.ContentType = $mime; $res.ContentLength64 = $bytes.Length; $res.OutputStream.Write($bytes, 0, $bytes.Length) } else { $res.StatusCode = 404; $err = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found'); $res.OutputStream.Write($err, 0, $err.Length) }; $res.OutputStream.Close() }"
pause