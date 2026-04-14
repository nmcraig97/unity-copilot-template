$raw = [Console]::In.ReadToEnd()
if ($raw -match '[\\/]\.github[\\/]') {
    @{ hookSpecificOutput = @{
        hookEventName = 'PreToolUse'
        permissionDecision = 'ask'
        permissionDecisionReason = '.github/ file modification requires approval'
    }} | ConvertTo-Json -Depth 3
} else {
    @{ hookSpecificOutput = @{
        hookEventName = 'PreToolUse'
        permissionDecision = 'allow'
    }} | ConvertTo-Json -Depth 3
}
