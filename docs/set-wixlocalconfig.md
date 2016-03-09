# Set-WixLocalConfig
## SYNOPSIS
Sets local WiX configuration.

## SYNTAX
```powershell
Set-WixLocalConfig [-Path <String>] [-Replace] [-Settings] <Object> [<CommonParameters>]

Set-WixLocalConfig [-Path <String>] [-Replace] [-ProductShortName <String>] [-ProductName <String>] [-ProductVersion <String>] [-Manufacturer <String>] [-HelpLink <String>] [-AboutLink <String>] [-UpgradeCodeX86 <String>] [-UpgradeCodeX64 <String>] [<CommonParameters>]
```

## DESCRIPTION
This function accepts an object representing configuration settings or
individual configuration settings and writes them to a JSON
formatted file (default location: '.\.wix.json').  It returns the new
configuration.

## PARAMETERS
### -Path \<String\>
An alternative folder to look for a '.wix' file.
```
Required?                    false
Position?                    named
Default value                (Get-Location).Path
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -Replace \<SwitchParameter\>
Replace all existing configuration with new settings.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -Settings \<Object\>

```
Required?                    true
Position?                    1
Default value
Accept pipeline input?       true (ByValue)
Accept wildcard characters?  false
```
 
### -ProductShortName \<String\>
Set "ProductShortName" value.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -ProductName \<String\>
Set "ProductName" value.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -ProductVersion \<String\>
Set "ProductVersion" value.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -Manufacturer \<String\>
Set "Manufacturer" value.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -HelpLink \<String\>
Set "HelpLink" value.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -AboutLink \<String\>
Set "AboutLink" value.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -UpgradeCodeX86 \<String\>
Set "UpgradeCodeX86" value.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -UpgradeCodeX64 \<String\>
Set "UpgradeCodeX64" value.
```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

## INPUTS
`System.Management.Automation.PSCustomObject`

Provide a custom object representing the local WiX
configuration.  Use Get-WixLocalConfig to see an example of the object
format.

## OUTPUTS
`System.Management.Automation.PSCustomObject`

Returns a custom object representing the new local WiX
configuration.

## NOTES
NAME: Set-WixLocalConfig

AUTHOR: Richard Grainger <grainger@gmail.com>

## EXAMPLES
### EXAMPLE 1
```powershell
PS C:\>Set-WixLocalConfig -ProductName "My Awesome PowerShell Module "
```

Sets the 'ProductName' setting in default config file '.\.wix.json'.

