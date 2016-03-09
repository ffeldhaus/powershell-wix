# Get-WixLocalConfig
## SYNOPSIS
Returns the local WiX configuration.

## SYNTAX
```powershell
Get-WixLocalConfig [[-Path] <String>] [-ProductShortName] [-ProductName] [-ProductVersion] [-Manufacturer] [-HelpLink] [-AboutLink] [-UpgradeCodeX86] [-UpgradeCodeX64] [<CommonParameters>]
```

## DESCRIPTION
This function returns an object representing the local WiX
configuration.  Configuration is returned from a JSON formatted config file
(default location: '.\.wix.json\').  Sensible default values are
returned if they are not contained in this file.  Upgrade codes are
generated and stored if they do not exist.

Individual configuration values can also be selected.  If no configuration
values are selected, all values are returned.

## PARAMETERS
### -Path \<String\>
An alternative folder to look for a '.wix' file.
```
Required?                    false
Position?                    1
Default value                (Get-Location).Path
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -ProductShortName \<SwitchParameter\>
Include "ProductShortName" in returned object.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -ProductName \<SwitchParameter\>
Include "ProductName" in returned object.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -ProductVersion \<SwitchParameter\>
Include "ProductVersion" in returned object.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -Manufacturer \<SwitchParameter\>
Include "Manufacturer" in returned object.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -HelpLink \<SwitchParameter\>
Include "HelpLink" in returned object.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -AboutLink \<SwitchParameter\>
Include "AboutLink" in returned object.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -UpgradeCodeX86 \<SwitchParameter\>
Include "UpgradeCodeX86" in returned object.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```
 
### -UpgradeCodeX64 \<SwitchParameter\>
Include "UpgradeCodeX64" in returned object.
```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```

## INPUTS
None

## OUTPUTS
`System.Management.Automation.PSCustomObject`

Returns a custom object representing the local WiX
configuration.

## NOTES
NAME: Get-WixLocalConfig

AUTHOR: Richard Grainger <grainger@gmail.com>

## EXAMPLES
### EXAMPLE 1
```powershell
PS C:\>Get-WixLocalConfig
```

Gets local WiX configuration from '.\.wix.json'.
 
### EXAMPLE 2
```powershell
PS C:\>(Get-WixLocalConfig -ProductName).ProductName
```

Gets 'ProductName' as a stringfrom '.\.wix.json'.

