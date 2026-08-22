# Diagnostico da sala de aula. Diz, numa tela so, por que o instalador do
# Windows nao roda nesta maquina. Nao instala nada, nao muda nada.
#
#   irm https://raw.githubusercontent.com/fabriciosiqueira08/capacitacao-gabarito/main/d.ps1 | iex

$os = Get-CimInstance Win32_OperatingSystem
$build = [int](([Environment]::OSVersion.Version.Build))
Write-Host ""
Write-Host "=== DIAGNOSTICO ===" -ForegroundColor Cyan
Write-Host ("  Windows : " + $os.Caption)
Write-Host ("  Build   : " + $build)

if ($build -lt 19041) {
  Write-Host "  >> WSL2 NAO RODA NESTE BUILD." -ForegroundColor Red
  Write-Host "     Precisa do Windows 10 versao 2004 (build 19041) ou maior." -ForegroundColor Red
  Write-Host "     Saida de hoje: PAREIE COM UM COLEGA." -ForegroundColor Yellow
} elseif ($build -lt 19045) {
  Write-Host "  >> WSL2 roda, mas o Docker Desktop atual pede 22H2 (19045)." -ForegroundColor Yellow
  Write-Host "     Atualize o Windows, ou pareie com um colega hoje." -ForegroundColor Yellow
} else {
  Write-Host "  >> versao OK para WSL2 e Docker Desktop." -ForegroundColor Green
}

Write-Host ""
$w = Get-Command winget -ErrorAction SilentlyContinue
if ($w) {
  Write-Host ("  winget  : OK (" + (winget --version) + ")") -ForegroundColor Green
} else {
  Write-Host "  winget  : NAO EXISTE" -ForegroundColor Red
  Write-Host "     E o mais comum no Windows 10. Abra a Microsoft Store," -ForegroundColor Yellow
  Write-Host "     procure 'Instalador de Aplicativo' (App Installer) e" -ForegroundColor Yellow
  Write-Host "     instale/atualize. Depois rode o instalador de novo." -ForegroundColor Yellow
}

Write-Host ""
$admin = ([Security.Principal.WindowsPrincipal] `
  [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($admin) {
  Write-Host "  admin   : OK" -ForegroundColor Green
} else {
  Write-Host "  admin   : NAO. Abra o PowerShell como administrador." -ForegroundColor Red
}

Write-Host ""
try {
  $d = (wsl --list --quiet) -replace "`0", ""
  $d = ($d | Where-Object { $_.Trim() })
  if ($d) {
    Write-Host ("  WSL     : distros -> " + ($d -join ", ")) -ForegroundColor Green
  } else {
    Write-Host "  WSL     : instalado, sem distro ainda" -ForegroundColor Yellow
  }
} catch {
  Write-Host "  WSL     : wsl.exe nao respondeu" -ForegroundColor Red
}

$vm = Get-CimInstance Win32_ComputerSystem
Write-Host ("  Virtualizacao no firmware: " + $(if ($vm.HypervisorPresent) { "ligada" } else { "DESLIGADA ou sem Hyper-V" }))
if (-not $vm.HypervisorPresent) {
  Write-Host "     Se o Ubuntu der 0x80370102 depois do reboot, e isso:" -ForegroundColor Yellow
  Write-Host "     ligue Intel VT-x / AMD-V (SVM) na BIOS." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Manda ESTA TELA no grupo." -ForegroundColor Cyan
Write-Host ""
