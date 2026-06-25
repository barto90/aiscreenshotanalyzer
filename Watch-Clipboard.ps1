. "$PSScriptRoot\Invoke-ImageQuery.ps1"
. "$PSScriptRoot\ImageQuerySchema.ps1"

function Watch-Clipboard {
    param(
        [int]$IntervalSeconds = 2,

        [hashtable]$Schema,

        [string]$Question = "What do you see in this image? If there are errors, explain them and suggest a fix."
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $lastHash = ""
    $tempPath = Join-Path $env:TEMP "clipboard_vision.png"

    Write-Host ""
    Write-Host "  Clipboard Watcher started" -ForegroundColor Green
    Write-Host "  Copy any image to your clipboard and AI will analyze it." -ForegroundColor Cyan
    Write-Host "  Press Ctrl+C to stop." -ForegroundColor DarkGray
    Write-Host ""

    while ($true) {
        try {
            $img = [System.Windows.Forms.Clipboard]::GetImage()

            if ($img) {
                $ms = New-Object System.IO.MemoryStream
                $img.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
                $bytes = $ms.ToArray()
                $ms.Dispose()

                $hash = [BitConverter]::ToString(
                    [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
                )

                if ($hash -ne $lastHash) {
                    $lastHash = $hash

                    $img.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
                    $img.Dispose()

                    Write-Host "  New image detected on clipboard!" -ForegroundColor Yellow
                    Write-Host "  Size: $($bytes.Length / 1KB -as [int]) KB, $($img.Width)x$($img.Height) px" -ForegroundColor DarkGray

                    if ($Schema) {
                        $result = Invoke-ImageQuery -ImagePath $tempPath -Question $Question -Schema $Schema
                        $result | Format-List
                    }
                    else {
                        $result = Invoke-ImageQuery -ImagePath $tempPath -Question $Question
                        Write-Host ""
                        Write-Host "  AI says:" -ForegroundColor Green
                        Write-Host "  $result" -ForegroundColor White
                    }

                    Write-Host ""
                    Write-Host "  Watching clipboard... (Ctrl+C to stop)" -ForegroundColor DarkGray
                }
                else {
                    $img.Dispose()
                }
            }
        }
        catch {
            # Clipboard in use by another process, skip
        }

        Start-Sleep -Seconds $IntervalSeconds
    }
}
