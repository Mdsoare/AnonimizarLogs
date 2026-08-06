<#
.SYNOPSIS
    Script para anonimização de dados sensíveis em logs (Compatível com nomes completos).
.DESCRIPTION
    O script identifica campos name, login e password delimitados por [ ] e mascara seus valores.
.EXAMPLE
    .\sanitizar.ps1 -ArquivoEntrada "C:\logs\producao.log"
#>

Param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ArquivoEntrada,

    [Parameter(Mandatory=$false)]
    [string]$ArquivoSaida
)

# Força o console a utilizar codificação UTF-8 para exibição correta de acentos
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 1. Validação de existência do arquivo
if (-not (Test-Path $ArquivoEntrada)) {
    Write-Error "Erro: O arquivo '$ArquivoEntrada' não foi encontrado."
    exit
}

# 2. Tratamento inteligente do nome de saída
if ([string]::IsNullOrWhiteSpace($ArquivoSaida)) {
    $diretorio = Split-Path $ArquivoEntrada -Parent
    
    # Se o diretório for vazio (arquivo na pasta atual), define como '.'
    if ([string]::IsNullOrWhiteSpace($diretorio)) { $diretorio = "." }
    
    $nomeBase = Split-Path $ArquivoEntrada -Leaf
    $ArquivoSaida = Join-Path $diretorio "new_$nomeBase"
}

# 3. Padrão Regex Unificado
# Explicação: (chaves e separadores) seguido por ([^\]]+) que captura tudo até o próximo ]
$patternUnificado = '(name[=:]|login[=:]|passwd[=:]|password[=:])([^\]]+)'

Write-Host "Iniciando anonimização: $ArquivoEntrada" -ForegroundColor Cyan

try {
    # 4. Processamento Otimizado
    # Lemos o arquivo, aplicamos a substituição em massa e salvamos com encoding UTF8
    (Get-Content $ArquivoEntrada) -replace $patternUnificado, '$1*****' | 
        Set-Content $ArquivoSaida -Encoding UTF8

    Write-Host "Sucesso! Dados anonimizados salvos em: $ArquivoSaida" -ForegroundColor Green
}
catch {
    Write-Error "Ocorreu um erro durante o processamento: $_"
}