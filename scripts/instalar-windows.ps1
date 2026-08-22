# Prepara um Windows para a capacitação, sem clique nenhum.
#
# Rode no PowerShell COMO ADMINISTRADOR:
#
#   irm https://raw.githubusercontent.com/fabriciosiqueira08/capacitacao-gabarito/main/scripts/instalar-windows.ps1 | iex
#
# Ele instala o WSL2 (o Linux onde você vai trabalhar), o VS Code e o Docker
# Desktop. Depois pede um reboot — e é só o que você precisa fazer no Windows:
# o resto acontece dentro do Ubuntu, com o instalar.sh.

$ErrorActionPreference = "Stop"

function Passo($texto) { Write-Host "`n==> $texto" -ForegroundColor Cyan }
function Ok($texto)    { Write-Host "    $texto" -ForegroundColor Green }
function Aviso($texto) { Write-Host "    $texto" -ForegroundColor Yellow }

$souAdmin = ([Security.Principal.WindowsPrincipal] `
  [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $souAdmin) {
  Write-Host "Este script precisa de PowerShell COMO ADMINISTRADOR." -ForegroundColor Red
  Write-Host "Feche esta janela, clique no menu Iniciar, digite PowerShell," -ForegroundColor Red
  Write-Host "clique com o botao direito e escolha 'Executar como administrador'." -ForegroundColor Red
  exit 1
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host "O winget nao existe nesta maquina." -ForegroundColor Red
  Write-Host "Atualize o 'Instalador de Aplicativo' pela Microsoft Store e rode de novo." -ForegroundColor Red
  exit 1
}

$precisaReiniciar = $false

# ── WSL2 ──────────────────────────────────────────────────────────────────
Passo "WSL2 com Ubuntu 24.04"
$distros = (wsl --list --quiet) -replace "`0", ""
if ($distros -match "Ubuntu-24.04") {
  Ok "ja instalado"
} else {
  Aviso "instalando (alguns minutos, e vai pedir reboot no fim)"
  wsl --install -d Ubuntu-24.04 --no-launch
  $precisaReiniciar = $true
}

# ── VS Code e Docker Desktop ──────────────────────────────────────────────
foreach ($app in @(
    @{ Id = "Microsoft.VisualStudioCode"; Nome = "VS Code" },
    @{ Id = "Docker.DockerDesktop";       Nome = "Docker Desktop" }
)) {
  Passo $app.Nome
  $jaTem = winget list --id $app.Id --exact 2>$null | Select-String $app.Id
  if ($jaTem) {
    Ok "ja instalado"
  } else {
    winget install --id $app.Id --exact --silent `
      --accept-package-agreements --accept-source-agreements
    Ok "instalado"
    if ($app.Id -eq "Docker.DockerDesktop") { $precisaReiniciar = $true }
  }
}

# ── o que fazer agora ─────────────────────────────────────────────────────
Write-Host ""
if ($precisaReiniciar) {
  Write-Host "PRONTO. Agora REINICIE o computador." -ForegroundColor Yellow
  Write-Host ""
  Write-Host "Depois de reiniciar, em ordem:" -ForegroundColor White
} else {
  Write-Host "PRONTO, e nao precisa reiniciar. Em ordem:" -ForegroundColor Green
}
Write-Host @"
  1. Abra o Ubuntu pelo menu Iniciar. Ele pede um usuario e uma senha:
     ANOTE A SENHA, ela e o seu sudo.

  2. Abra o Docker Desktop e espere a baleia parar de se mexer. Em
     Settings > Resources > WSL Integration, ligue a chave da linha
     Ubuntu-24.04 e clique Apply & restart.

  3. De volta no terminal do Ubuntu, cole esta linha:

     curl -fsSL https://raw.githubusercontent.com/fabriciosiqueira08/capacitacao-gabarito/main/scripts/instalar.sh | bash
"@ -ForegroundColor White
Write-Host ""
