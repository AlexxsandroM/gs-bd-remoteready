<#
  PowerShell script para importar os arquivos JSON do RemoteReady para o MongoDB.
  
  Requisitos:
   - mongoimport disponível no PATH (vem com MongoDB Database Tools)
   - Execute em PowerShell na pasta onde estão os arquivos JSON

  Uso:
    .\import_data.ps1
    .\import_data.ps1 -Uri "mongodb://localhost:27017" -Database "remoteready_prod"

  O script tenta importar cada arquivo JSON que começa com 'remoteready_'.
#>

param(
    [string]$Uri = "mongodb://127.0.0.1:27017",
    [string]$Database = "remoteready"
)

$ErrorActionPreference = 'Stop'

$rootPath = Get-Location
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "IMPORTAÇÃO REMOTEREADY PARA MONGODB" -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "Pasta atual: $rootPath" -ForegroundColor Yellow
Write-Host "URI: $Uri" -ForegroundColor Yellow
Write-Host "Database: $Database" -ForegroundColor Yellow
Write-Host "==========================================================================" -ForegroundColor Cyan

# Localiza arquivos remoteready_*.json
$files = Get-ChildItem -Path $rootPath -Filter 'remoteready_*.json' -File -ErrorAction SilentlyContinue

if (-not $files) {
    Write-Host "Nenhum arquivo remoteready_*.json encontrado em $rootPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Arquivos esperados:" -ForegroundColor Yellow
    Write-Host "  - remoteready_usuarios.json" -ForegroundColor Gray
    Write-Host "  - remoteready_empresas.json" -ForegroundColor Gray
    Write-Host "  - remoteready_blog_posts.json" -ForegroundColor Gray
    Write-Host "  - remoteready_certificados.json" -ForegroundColor Gray
    Write-Host "  - remoteready_user_posts.json" -ForegroundColor Gray
    Write-Host "  - remoteready_chat_history.json" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Execute primeiro o procedimento PRC_EXPORT_JSON_ARQUIVOS no Oracle para gerar os arquivos JSON."
    exit 1
}

Write-Host "Arquivos encontrados para importação:" -ForegroundColor Green
foreach ($f in $files) {
    Write-Host "  ✓ $($f.Name)" -ForegroundColor Gray
}
Write-Host ""

# Mapeamento de arquivos para coleções
$mapping = @{
    'remoteready_usuarios.json' = 'usuarios'
    'remoteready_empresas.json' = 'empresas'
    'remoteready_blog_posts.json' = 'blog_posts'
    'remoteready_certificados.json' = 'certificados'
    'remoteready_user_posts.json' = 'user_posts'
    'remoteready_chat_history.json' = 'chat_history'
}

$totalFiles = $files.Count
$processedFiles = 0
$successCount = 0
$errorCount = 0

foreach ($f in $files) {
    $processedFiles++
    $collection = $mapping[$f.Name]
    
    if (-not $collection) {
        Write-Host "[$processedFiles/$totalFiles] Pulando arquivo desconhecido: $($f.Name)" -ForegroundColor Yellow
        continue
    }

    Write-Host "[$processedFiles/$totalFiles] Importando $($f.Name) → coleção '$collection'" -ForegroundColor White

    try {
        # Comando mongoimport
        $arguments = @(
            '--uri', "$Uri/$Database",
            '--collection', $collection,
            '--file', $f.FullName,
            '--jsonArray',
            '--mode', 'upsert',
            '--upsertFields', '_id'
        )

        Write-Host "  Executando: mongoimport $($arguments -join ' ')" -ForegroundColor Gray
        
        $proc = Start-Process -FilePath 'mongoimport' -ArgumentList $arguments -NoNewWindow -Wait -PassThru -RedirectStandardOutput "$env:TEMP\mongoimport_out.txt" -RedirectStandardError "$env:TEMP\mongoimport_err.txt"

        if ($proc.ExitCode -eq 0) {
            $output = Get-Content "$env:TEMP\mongoimport_out.txt" -ErrorAction SilentlyContinue
            if ($output) {
                Write-Host "  $output" -ForegroundColor Green
            }
            Write-Host "  ✓ Importação bem-sucedida!" -ForegroundColor Green
            $successCount++
        } else {
            $errorOutput = Get-Content "$env:TEMP\mongoimport_err.txt" -ErrorAction SilentlyContinue
            Write-Host "  ✗ Falha na importação. ExitCode: $($proc.ExitCode)" -ForegroundColor Red
            if ($errorOutput) {
                Write-Host "  Erro: $errorOutput" -ForegroundColor Red
            }
            $errorCount++
        }
    }
    catch {
        Write-Host "  ✗ Exceção durante importação: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
    
    Write-Host ""
}

# Cleanup
Remove-Item "$env:TEMP\mongoimport_out.txt" -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\mongoimport_err.txt" -ErrorAction SilentlyContinue

Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "RESUMO DA IMPORTAÇÃO" -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "Total de arquivos processados: $processedFiles" -ForegroundColor White
Write-Host "Sucessos: $successCount" -ForegroundColor Green
Write-Host "Erros: $errorCount" -ForegroundColor Red

if ($successCount -gt 0) {
    Write-Host ""
    Write-Host "COMANDOS PARA VERIFICAÇÃO:" -ForegroundColor Yellow
    Write-Host "mongosh $Database --eval `"show collections`"" -ForegroundColor Gray
    Write-Host "mongosh $Database --eval `"db.usuarios.countDocuments()`"" -ForegroundColor Gray
    Write-Host "mongosh $Database --eval `"db.empresas.countDocuments()`"" -ForegroundColor Gray
    Write-Host "mongosh $Database --eval `"db.blog_posts.find().limit(3)`"" -ForegroundColor Gray
}

Write-Host "==========================================================================" -ForegroundColor Cyan

if ($errorCount -gt 0) {
    exit 1
} else {
    Write-Host "Importação concluída com sucesso!" -ForegroundColor Green
    exit 0
}