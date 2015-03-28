$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut" "." "."


Describe "RestoreProjectFile" {
    It "replaces imports when conditions are present" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" Condition="Exists('$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props')" />
  <PropertyGroup>
    <TypeScriptToolsVersion>1.4</TypeScriptToolsVersion>
  </PropertyGroup>
  <Import Project="$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" Condition="Exists('$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets')" />
</Project>
'@

        $result = RestoreProjectFile "A" "B" 'TypeScript.MSBuild' $xml

        $paths = Get-Paths 'TypeScript.MSBuild'
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.OriginalProps)`" Condition=`"Exists('$($paths.OriginalProps)')`" />") | Should Be $true
        $xml.InnerXml.Contains(
           "<Import Project=`"$($paths.OriginalTargets)`" Condition=`"Exists('$($paths.OriginalTargets)')`" />") | Should Be $true

    }
    
    It "replaces imports without conditions present" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" />
  <PropertyGroup>
    <TypeScriptToolsVersion>1.4</TypeScriptToolsVersion>
  </PropertyGroup>
  <Import Project="$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" />
</Project>
'@

        RestoreProjectFile "A" "B" 'TypeScript.MSBuild' $xml
        
        $paths = Get-Paths 'TypeScript.MSBuild'
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.OriginalProps)`" Condition=`"Exists('$($paths.OriginalProps)')`" />") | Should Be $true
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.OriginalTargets)`" Condition=`"Exists('$($paths.OriginalTargets)')`" />") | Should Be $true
    }
    
    It "replaces imports when TypeScript version is newer" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" Condition="Exists('$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props')" />
  <PropertyGroup>
    <TypeScriptToolsVersion>2.0</TypeScriptToolsVersion>
  </PropertyGroup>
  <Import Project="$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" Condition="Exists('$(ProjectDir)\..\packages\TypeScript.MSBuild\tools\MSBuild\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets')" />
</Project>
'@

        $result = RestoreProjectFile "A" "B" 'TypeScript.MSBuild' $xml

        $paths = Get-Paths 'TypeScript.MSBuild'
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.OriginalProps)`" Condition=`"Exists('$($paths.OriginalProps)')`" />") | Should Be $true
        $xml.InnerXml.Contains(
           "<Import Project=`"$($paths.OriginalTargets)`" Condition=`"Exists('$($paths.OriginalTargets)')`" />") | Should Be $true

    }    
    
    It "throws no error when imports are missing" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
</Project>
'@

        { RestoreProjectFile "A" "B" 'TypeScript.MSBuild' $xml } | Should Not Throw
    }    
}
