#!/usr/bin/env pwsh
# Pre-commit gate. Equivalent to `melos run check`.
# Usage: pwsh tool/check.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
dart run tool/tasks.dart check
exit $LASTEXITCODE
