$commands = Get-Command *Wix*
ForEach ($command in $commands){
  $strCommand = [String]$command
  $file = $PSScriptRoot + "\" + $strCommand.ToLower() + ".md"
  $script = Join-Path $PSScriptRoot "\Get-HelpByMarkdown.ps1"
  Invoke-Expression "$script $strCommand" | Out-File -FilePath $file `
                                                     -Encoding utf8
}