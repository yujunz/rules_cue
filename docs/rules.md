<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public APIs re-export

<a id="cue_config"></a>

## cue_config

<pre>
cue_config(<a href="#cue_config-name">name</a>, <a href="#cue_config-stamp">stamp</a>)
</pre>

Collects information about the build settings in the current configuration.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="cue_config-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="cue_config-stamp"></a>stamp |  Whether stamping is enabled for this build.   | Boolean | required |  |


<a id="cue_instance"></a>

## cue_instance

<pre>
cue_instance(<a href="#cue_instance-name">name</a>, <a href="#cue_instance-ancestor">ancestor</a>, <a href="#cue_instance-deps">deps</a>, <a href="#cue_instance-directory_of">directory_of</a>, <a href="#cue_instance-package_name">package_name</a>, <a href="#cue_instance-srcs">srcs</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="cue_instance-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="cue_instance-ancestor"></a>ancestor |  Containing CUE instance or module root.<br><br>This value must refer either to a dominating target using the cue_instance rule (or another rule that yields a CUEInstanceInfo provider) or a dominating target using the cue_module rule (or another rule that yields a CUEModuleInfo provider).   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="cue_instance-deps"></a>deps |  cue_instance targets to include in the evaluation.<br><br>These instances are those mentioned in import declarations in this instance's CUE files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="cue_instance-directory_of"></a>directory_of |  Directory designator to use as the instance directory.<br><br>If the given target is a directory, use that directly. If the given target is a file, use the file's containing directory.<br><br>If left unspecified, use the directory containing the first CUE file nominated in this cue_instance's "srcs" attribute.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |
| <a id="cue_instance-package_name"></a>package_name |  Name of the CUE package to load for this instance.<br><br>If left unspecified, use the basename of the containing directory as the CUE pacakge name.   | String | optional | <code>""</code> |
| <a id="cue_instance-srcs"></a>srcs |  CUE input files that are part of the nominated CUE package.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |


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


<a id="cue_version"></a>

## cue_version

<pre>
cue_version(<a href="#cue_version-name">name</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="cue_version-name"></a>name |  <p align="center"> - </p>   |  none |


