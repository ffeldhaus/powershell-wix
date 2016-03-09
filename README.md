# powershell-wix
**Release your PowerShell modules the professional way!**

A Windows PowerShell module to easily convert PowerShell modules into MSI files
using WiX.

## Prerequisites
  - Windows PowerShell 3 or above
  - [WiX Toolset] (http://wixtoolset.org/releases/)

## Example Usage
Install the module from
[releases] (https://github.com/liger1978/powershell-wix/releases) or clone this
repo, then:

````powershell
Import-Module powershell-msi
cd My_Awesome_Module
Set-WixLocalConfig -ProductName "My Awesome PowerShell Module" -Manufacturer "John Smith"
Start-WixBuild
````

That's it! 64 bit and a 32 bit MSI package files containing your module will be
generated in your module's directory .  When your users install the package, the
module will be installed in their standard PowerShell module path, ready for use
via `Import-Module`.

## Functions
- [Start-WixBuild](https://github.com/liger1978/powershell-wix/tree/master/docs/start-wixbuild.md)
- [Get-WixLocalConfig](https://github.com/liger1978/powershell-wix/tree/master/docs/get-wixlocalconfig.md)
- [Set-WixLocalConfig](https://github.com/liger1978/powershell-wix/tree/master/docs/set-wixlocalconfig.md)

## Getting help
Use Get-Help, e.g.:

````powershell
Get-Help Start-WixBuild -Online
````

## License, copyright and acknowledgements
**powershell-msi**: Copyright (c) 2016 Richard Grainger,
[MIT License] (https://opensource.org/licenses/MIT)

**WiX Toolset**: Copyright (c) 2016 Outercurve Foundation,
[Microsoft Reciprocal License (MS-RL)] (http://opensource.org/licenses/ms-rl)

**Get-HelpByMarkdown.ps1**: Copyright (c) 2014 Akira Sugiura,
[MIT License] (https://opensource.org/licenses/MIT)

Inspired by [this] (http://viziblr.com/news/2012/8/17/how-to-easily-create-an-msi-to-install-your-powershell-modul.html).