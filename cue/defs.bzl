"Public APIs re-export"

load("//cue/private:config.bzl", _cue_config = "cue_config")
load("//cue/private:instance.bzl", _cue_instance = "cue_instance")
load("//cue/private:module.bzl", _cue_module = "cue_module")
load("//cue/private:export.bzl", _cue_export = "cue_export")
load("//cue/private:def.bzl", _cue_def = "cue_def")

cue_config = _cue_config
cue_def = _cue_def
cue_export = _cue_export
cue_instance = _cue_instance
cue_module = _cue_module

def cue_version(name):
    native.genrule(
        name = name,
        cmd = "$(CUE_BIN) version > $@",
        outs = ["version"],
        toolchains = ["@rules_abcue//cue:resolved_toolchain"],
    )
