param([Parameter(Mandatory=$true)][string]$File)

if (-not (Test-Path -LiteralPath $File)) { exit 0 }

$ext = [System.IO.Path]::GetExtension($File).ToLower()
$absPath = (Resolve-Path -LiteralPath $File).Path

try {
    if ($ext -eq ".wav") {
        $player = New-Object System.Media.SoundPlayer
        $player.SoundLocation = $absPath
        $player.PlaySync()
    }
    elseif ($ext -eq ".mp3") {
        Add-Type -AssemblyName presentationCore -ErrorAction Stop
        $mp = New-Object System.Windows.Media.MediaPlayer
        $uri = [System.Uri]::new($absPath)
        $mp.Open($uri)
        $mp.Play()
        Start-Sleep -Milliseconds 200
        $attempts = 0
        while ((-not $mp.NaturalDuration.HasTimeSpan) -and ($attempts -lt 20)) {
            Start-Sleep -Milliseconds 100
            $attempts++
        }
        if ($mp.NaturalDuration.HasTimeSpan) {
            $ms = [int]$mp.NaturalDuration.TimeSpan.TotalMilliseconds + 200
            Start-Sleep -Milliseconds $ms
        } else {
            Start-Sleep -Seconds 4
        }
        $mp.Close()
    }
} catch {
    exit 0
}
exit 0
