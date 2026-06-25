# PowerShell AI Clipboard Watcher

Copy an image to your clipboard. Get AI analysis back. That's it.

This script watches your Windows clipboard for new images (screenshots, snips, copied images) and automatically sends them to Azure OpenAI's GPT-4o vision API for analysis. Supports both free-text responses and structured output with custom JSON schemas.

Part of the **Scripting Like a Pro** blog series — [#58: PowerShell AI Clipboard Watcher](https://bartpasmans.tech/powershell-ai-clipboard-watcher/).

## What's Included

| File | Description |
|------|-------------|
| `Watch-Clipboard.ps1` | Clipboard watcher — detects new images and sends them to GPT-4o |
| `Invoke-ImageQuery.ps1` | Core function — encodes an image and queries Azure OpenAI |
| `ImageQuerySchema.ps1` | Example JSON schemas for screenshots, errors, and diagrams |

## Prerequisites

- **Windows** (uses `System.Windows.Forms.Clipboard`)
- **PowerShell 5.1+**
- **Azure OpenAI** resource with a GPT-4o deployment

## Setup

Set your Azure OpenAI credentials as environment variables:

```powershell
$env:AZURE_OPENAI_ENDPOINT   = 'https://your-resource.openai.azure.com/'
$env:AZURE_OPENAI_DEPLOYMENT = 'gpt-4o'
$env:AZURE_OPENAI_API_KEY    = 'your-api-key'
```

Or add them permanently via System Settings > Environment Variables.

## Usage

### Start the clipboard watcher

```powershell
. .\Watch-Clipboard.ps1

Watch-Clipboard
```

Now copy any image (PrintScreen, Win+Shift+S, copy from browser) and the watcher will automatically analyze it.

### Structured error analysis

```powershell
. .\Watch-Clipboard.ps1

Watch-Clipboard -Schema $errorSchema -Question "Classify this error and suggest a fix"
```

Every screenshot gets classified with error type, severity, root cause, and a suggested fix command.

### Architecture diagram parsing

```powershell
Watch-Clipboard -Schema $diagramSchema -Question "Explain this architecture diagram"
```

### Analyze a single image (without the watcher)

```powershell
. .\Invoke-ImageQuery.ps1

Invoke-ImageQuery -ImagePath ".\screenshot.png" -Question "What do you see?"
```

### Structured single image analysis

```powershell
. .\Invoke-ImageQuery.ps1
. .\ImageQuerySchema.ps1

$result = Invoke-ImageQuery -ImagePath ".\error.png" -Question "Analyze this error" -Schema $errorSchema

$result.errorType   # configuration, authentication, network, permission, runtime, resource, unknown
$result.severity    # critical, high, medium, low
$result.rootCause   # what went wrong
$result.fix         # how to fix it
$result.command     # command to run
```

## Available Schemas

`ImageQuerySchema.ps1` includes three schemas:

- **`$screenshotSchema`** — General screenshot triage: application name, description, UI elements, errors, suggestions
- **`$errorSchema`** — Error classification: error type (enum), severity (enum), message, root cause, fix, command
- **`$diagramSchema`** — Diagram parsing: diagram type (enum), title, components, connections, summary

## Parameters

### Watch-Clipboard

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-IntervalSeconds` | int | 2 | Polling interval in seconds |
| `-Schema` | hashtable | — | JSON schema for structured output |
| `-Question` | string | "What do you see in this image?..." | Question to ask about each image |

### Invoke-ImageQuery

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-ImagePath` | string | Yes | Path to the image file (png, jpg, gif, bmp, webp) |
| `-Question` | string | Yes | Question to ask about the image |
| `-Schema` | hashtable | No | JSON schema for structured output |

## How It Works

1. The watcher polls the clipboard every N seconds using `[System.Windows.Forms.Clipboard]::GetImage()`
2. When an image is found, it computes a SHA256 hash to detect new images (prevents re-analyzing the same image)
3. New images are saved to a temp file and passed to `Invoke-ImageQuery`
4. `Invoke-ImageQuery` base64-encodes the image, builds a multimodal API request, and sends it to Azure OpenAI
5. If a schema is provided, the response is parsed as structured JSON; otherwise it's returned as free text

## Related

- [Blog #57: Show AI What You See](https://yoursite.com/blog/57) — The vision API foundation this builds on
- [Azure OpenAI GPT-4o Vision docs](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/gpt-with-vision)
- [Azure OpenAI Structured Outputs](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/structured-outputs)

## License

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — Free to use, share, and adapt for non-commercial purposes with attribution.
