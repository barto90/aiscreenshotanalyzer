function Invoke-ImageQuery {
    param(
        [Parameter(Mandatory)]
        [string]$ImagePath,

        [Parameter(Mandatory)]
        [string]$Question,

        [hashtable]$Schema
    )

    $Endpoint   = $env:AZURE_OPENAI_ENDPOINT
    $Deployment = $env:AZURE_OPENAI_DEPLOYMENT
    $ApiKey     = $env:AZURE_OPENAI_API_KEY

    if (-not $Endpoint -or -not $Deployment -or -not $ApiKey) {
        throw "Missing environment variables. Set AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_DEPLOYMENT, and AZURE_OPENAI_API_KEY."
    }

    if (-not (Test-Path $ImagePath)) {
        throw "Image not found: $ImagePath"
    }

    $extension = [System.IO.Path]::GetExtension($ImagePath).TrimStart('.').ToLower()
    $mimeMap = @{
        png  = "image/png"
        jpg  = "image/jpeg"
        jpeg = "image/jpeg"
        gif  = "image/gif"
        bmp  = "image/bmp"
        webp = "image/webp"
    }

    $mimeType = $mimeMap[$extension]
    if (-not $mimeType) {
        throw "Unsupported image format: $extension (use png, jpg, gif, bmp, or webp)"
    }

    Write-Host ""
    Write-Host "  Reading image..." -ForegroundColor Cyan
    $imageBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $ImagePath))
    $base64 = [Convert]::ToBase64String($imageBytes)
    $dataUri = "data:$mimeType;base64,$base64"
    Write-Host "  Image loaded: $extension, $([math]::Round($imageBytes.Length / 1KB)) KB" -ForegroundColor DarkGray

    Write-Host "  Querying AI..." -ForegroundColor Cyan

    $body = @{
        messages = @(
            @{
                role    = "system"
                content = @"
You are a visual analysis assistant.
You receive an image and a question about it.
Describe what you see accurately and answer the question based ONLY on the image content.
If something is unclear or not visible, say so explicitly.
Do not guess or make up information that is not visible in the image.
"@
            }
            @{
                role    = "user"
                content = @(
                    @{
                        type      = "image_url"
                        image_url = @{
                            url    = $dataUri
                            detail = "high"
                        }
                    }
                    @{
                        type = "text"
                        text = $Question
                    }
                )
            }
        )
        max_tokens = 2000
    }

    if ($Schema) {
        $body.response_format = @{
            type        = "json_schema"
            json_schema = @{
                name   = "image_analysis"
                strict = $true
                schema = $Schema
            }
        }
    }

    $json    = $body | ConvertTo-Json -Depth 20
    $headers = @{
        "api-key"      = $ApiKey
        "Content-Type" = "application/json"
    }
    $url = "$Endpoint/openai/deployments/$Deployment/chat/completions?api-version=2024-10-21"

    $response = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $json

    $answer = $response.choices[0].message.content

    if ($Schema) {
        return $answer | ConvertFrom-Json
    }

    return $answer
}
