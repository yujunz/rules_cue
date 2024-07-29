<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="CUEModuleInfo"></a>

## CUEModuleInfo

<pre>
CUEModuleInfo(<a href="#CUEModuleInfo-module_file">module_file</a>, <a href="#CUEModuleInfo-external_package_sources">external_package_sources</a>)
</pre>

Collects files from cue_module targets for use by referring cue_instance targets.

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="CUEModuleInfo-module_file"></a>module_file |  The "module.cue" file in the module directory.    |
| <a id="CUEModuleInfo-external_package_sources"></a>external_package_sources |  The set of files in this CUE module defining external packages.    |


<a id="cue_module"></a>

## cue_module

<pre>
cue_module(<a href="#cue_module-name">name</a>, <a href="#cue_module-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="cue_module-name"></a>name |  <p align="center"> - </p>   |  <code>"cue.mod"</code> |
| <a id="cue_module-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="version"></a>

## version

<pre>
version(<a href="#version-name">name</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="version-name"></a>name |  <p align="center"> - </p>   |  none |


