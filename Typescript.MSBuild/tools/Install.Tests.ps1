$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut" "." "."

Describe "ModifyProjectFile" {
    It "replaces imports when conditions are present" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" Condition="Exists('$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props')" />
  <PropertyGroup>
    <TypeScriptToolsVersion>1.4</TypeScriptToolsVersion>
  </PropertyGroup>
  <Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" Condition="Exists('$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets')" />
</Project>
'@

        ModifyProjectFile "A" "B" 'TypeScript.MSBuild' $xml

        $paths = Get-Paths 'TypeScript.MSBuild'
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.Props)`" Condition=`"Exists('$($paths.Props)')`" />") | Should Be $true
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.Targets)`" Condition=`"Exists('$($paths.Targets)')`" />") | Should Be $true

    }
    
    It "replaces imports without conditions present" {
        $xml = [XML] @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.Default.props" />
  <PropertyGroup>
    <TypeScriptToolsVersion>1.4</TypeScriptToolsVersion>
  </PropertyGroup>
  <Import Project="$(MSBuildExtensionsPath32)\Microsoft\VisualStudio\v$(VisualStudioVersion)\TypeScript\Microsoft.TypeScript.targets" />
</Project>
'@

        ModifyProjectFile "A" "B" 'TypeScript.MSBuild' $xml
        
        $paths = Get-Paths 'TypeScript.MSBuild'
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.Props)`" Condition=`"Exists('$($paths.Props)')`" />") | Should Be $true
        $xml.InnerXml.Contains(
            "<Import Project=`"$($paths.Targets)`" Condition=`"Exists('$($paths.Targets)')`" />") | Should Be $true
    }
}
