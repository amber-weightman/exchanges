# Setup Context7 API Key for GitHub Copilot MCP
# Run this script after obtaining your API key from https://context7.com

param(
    [Parameter(Mandatory=$true)]
    [string]$ApiKey
)

# Validate API key format
if (-not $ApiKey.StartsWith("ctx7sk")) {
    Write-Error "Invalid API key format. Context7 API keys should start with 'ctx7sk'"
    exit 1
}

# Set user environment variable (persists across sessions)
[Environment]::SetEnvironmentVariable("COPILOT_MCP_CONTEXT7_API_KEY", $ApiKey, "User")

# Set for current session
$env:COPILOT_MCP_CONTEXT7_API_KEY = $ApiKey

Write-Host "Context7 API key has been set successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Restart VS Code to load the new environment variable (Ctrl+Shift+P)"
Write-Host "2. The Context7 MCP will now be available to GitHub Copilot"
Write-Host ""
Write-Host "To verify: Check that the key is set with:" -ForegroundColor Yellow
Write-Host "  $env:COPILOT_MCP_CONTEXT7_API_KEY"
