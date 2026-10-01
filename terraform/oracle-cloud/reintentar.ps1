# Reintenta "terraform apply" hasta que Oracle tenga capacidad ARM libre ("Out of host capacity").
# Empieza con una maquina pequena (mas facil de conseguir) y se puede ampliar despues sin recrearla.
#
# Uso (desde esta carpeta):  .\reintentar.ps1 [-Ocpus 1] [-MemoriaGb 6] [-MinutosEntreIntentos 5] [-MaxHoras 24]
param(
  [int]$Ocpus = 1,
  [int]$MemoriaGb = 6,
  [int]$MinutosEntreIntentos = 5,
  [int]$MaxHoras = 24
)

$tf = (Get-Command terraform -ErrorAction SilentlyContinue).Source
if (-not $tf) {
  $tf = (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter terraform.exe -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}
if (-not $tf) { throw "No se encuentra terraform" }

$limite = (Get-Date).AddHours($MaxHoras)
$intento = 0
while ((Get-Date) -lt $limite) {
  $intento++
  Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Intento $intento ($Ocpus OCPU / $MemoriaGb GB)..."
  $salida = & $tf apply -no-color -auto-approve -var "ocpus=$Ocpus" -var "memoria_gb=$MemoriaGb" 2>&1 | Out-String
  if ($salida -match "Apply complete") {
    Write-Host "CONSEGUIDO tras $intento intentos."
    ($salida -split "`n" | Select-String "ip_publica|ssh|url") | ForEach-Object { Write-Host $_.Line.Trim() }
    exit 0
  }
  if ($salida -notmatch "Out of host capacity") {
    Write-Host "Error distinto de falta de capacidad; me detengo:"
    Write-Host ($salida -split "`n" | Select-String "Error" | Select-Object -First 5)
    exit 1
  }
  # Pausa con algo de azar para no martillear la API
  Start-Sleep -Seconds (($MinutosEntreIntentos * 60) + (Get-Random -Minimum 0 -Maximum 60))
}
Write-Host "Se agoto el tiempo sin conseguir capacidad."
exit 2
