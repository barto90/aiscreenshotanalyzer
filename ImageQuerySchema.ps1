$screenshotSchema = @{
    type       = "object"
    properties = @{
        application = @{ type = "string" }
        description = @{ type = "string" }
        elements    = @{
            type  = "array"
            items = @{ type = "string" }
        }
        errors      = @{
            type  = "array"
            items = @{ type = "string" }
        }
        suggestions = @{
            type  = "array"
            items = @{ type = "string" }
        }
    }
    required             = @("application", "description", "elements", "errors", "suggestions")
    additionalProperties = $false
}

$errorSchema = @{
    type       = "object"
    properties = @{
        errorType   = @{
            type = "string"
            enum = @("configuration", "authentication", "network", "permission", "runtime", "resource", "unknown")
        }
        severity    = @{
            type = "string"
            enum = @("critical", "high", "medium", "low")
        }
        message     = @{ type = "string" }
        rootCause   = @{ type = "string" }
        fix         = @{ type = "string" }
        command     = @{ type = "string" }
    }
    required             = @("errorType", "severity", "message", "rootCause", "fix", "command")
    additionalProperties = $false
}

$diagramSchema = @{
    type       = "object"
    properties = @{
        diagramType = @{
            type = "string"
            enum = @("architecture", "network", "flow", "sequence", "deployment", "other")
        }
        title       = @{ type = "string" }
        components  = @{
            type  = "array"
            items = @{ type = "string" }
        }
        connections = @{
            type  = "array"
            items = @{ type = "string" }
        }
        summary     = @{ type = "string" }
    }
    required             = @("diagramType", "title", "components", "connections", "summary")
    additionalProperties = $false
}
