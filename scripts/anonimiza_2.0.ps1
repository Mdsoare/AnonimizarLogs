<#
.SYNOPSIS
    Script para anonimização recursiva de logs em diretórios.
.EXAMPLE
    .\anonimiza_2.0.ps1 -Diretorio "C:\Logs\Sistema" -Extensao "*.log"
	.\anonimiza_2.0.ps1 -Diretorio . -Extensao "*.log.*"
#>

Param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Diretorio,

    [Parameter(Mandatory=$false)]
    [string]$Extensao = "*.log" # Filtro padrão
)

# Força o console a utilizar codificação UTF-8 para exibição correta de acentos
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 1. Validação do diretório
if (-not (Test-Path $Diretorio)) {
    Write-Error "Erro: O diretório '$Diretorio' não foi encontrado."
    exit
}

# 2. Padrão Regex Unificado (Mantendo a lógica de nomes completos)
$patternUnificado = '(name[=:]|nome[=:]|login[=:]|pass[=:]|passwd[=:]|password[=:]|senha[=:]|token[=:])([^\]]+)'

# 3. Busca recursiva de arquivos
$arquivos = Get-ChildItem -Path $Diretorio -Filter $Extensao -Recurse
$totalArquivos = $arquivos.Count
$contador = 0
Write-Host "Iniciando processamento de $totalArquivos arquivos..." -ForegroundColor Cyan

foreach ($arquivo in $arquivos) {
    $contador++
    $percentual = ($contador / $totalArquivos) * 100

	Write-Progress -Activity "Anonimizando Logs" `
                   -Status "Processando arquivo $contador de $totalArquivos" `
                   -PercentComplete $percentual `
                   -CurrentOperation "Arquivo: $($arquivo.Name)"

    $caminhoOriginal = $arquivo.FullName
    $caminhoSaida = Join-Path $arquivo.DirectoryName ("new_" + $arquivo.Name)

    try {
        (Get-Content $caminhoOriginal) -replace $patternUnificado, '$1*****' | 
            Set-Content $caminhoSaida -Encoding UTF8
    }
    catch {
        Write-Warning "Erro em $($arquivo.Name): $_"
    }
}

# Remove a barra de progresso ao finalizar
Write-Progress -Activity "Anonimizando Logs" -Completed
Write-Host "`nConcluído! $totalArquivos arquivos processados." -ForegroundColor Green