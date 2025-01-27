"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//cue/private:toolchains_repo.bzl", "PLATFORMS", "toolchains_repo")
load("//cue/private:versions.bzl", "TOOL_VERSIONS")

DEFAULT_NAME = "cue"
DEFAULT_VERSION = "0.11.2"

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
# This is all fixed by bzlmod, so we just tolerate it for now.
def rules_abcue_dependencies():
    # The minimal version of bazel_skylib we require
    http_archive(
        name = "bazel_skylib",
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
    )

########
# Remaining content of the file is only used to support toolchains.
########
_DOC = "Fetch external tools needed for cue toolchain"
_ATTRS = {
    "version": attr.string(mandatory = False, values = TOOL_VERSIONS.keys()),
    "platform": attr.string(mandatory = False, values = PLATFORMS.keys()),
}

# https://github.com/cue-lang/cue/releases/download/v0.9.2/checksums.txt
# 87ebebb8459d579ff791843b3228ca64dc372181456d8e2b4ad4e3f0c607c94d  cue_v0.9.2_darwin_amd64.tar.gz
# 0f01909937c7f1b5b58d55e53a7d5366f3b4f8fc48dc31e391dd55340ea1ae95  cue_v0.9.2_darwin_arm64.tar.gz
# 67c88f6c3bdf884301794c3ec91f9e6e3f660e7de3b7e10cd29fbbd291baac50  cue_v0.9.2_linux_amd64.tar.gz
# 3b90c49faaf3367338bd95db0bf76ec86bf4ca7d175d42a221e27bdc8d265256  cue_v0.9.2_linux_arm64.tar.gz
# b63616df5dcc13dc968e714d4935d2823600aa5bdda049edbcaeb639c91a1c76  cue_v0.9.2_windows_amd64.zip
# 30fb3b62889f45da8c79a75c4c8772ea47306e5edca5c921c7ffb9095522ae1c  cue_v0.9.2_windows_arm64.zip
def _cue_repo_impl(repository_ctx):
    url = "https://github.com/cue-lang/cue/releases/download/v{0}/cue_v{0}_{1}".format(
        repository_ctx.attr.version,
        repository_ctx.attr.platform,
    )

    if (repository_ctx.attr.platform.startswith("windows")):
        url = url + ".zip"
    else:
        url = url + ".tar.gz"

    repository_ctx.download_and_extract(
        url = url,
        sha256 = TOOL_VERSIONS[repository_ctx.attr.version][repository_ctx.attr.platform],
        output = "cue_tool",
    )
    build_content = """# Generated by cue/repositories.bzl
load("@rules_abcue//cue:toolchain.bzl", "cue_toolchain")

cue_toolchain(
    name = "cue_toolchain",
    target_tool = select({
        "@bazel_tools//src/conditions:host_windows": "cue_tool/cue.exe",
        "//conditions:default": "cue_tool/cue",
    }),
)
"""

    # Base BUILD file for this repository
    repository_ctx.file("BUILD.bazel", build_content)

cue_repositories = repository_rule(
    _cue_repo_impl,
    doc = _DOC,
    attrs = _ATTRS,
)

# Wrapper macro around everything above, this is the primary API
def cue_register_toolchains(name = DEFAULT_NAME, register = True, version = DEFAULT_VERSION, **kwargs):
    """Convenience macro for users which does typical setup.

    - create a repository for each built-in platform like "cue_linux_amd64"
    - TODO: create a convenience repository for the host platform like "cue_host"
    - create a repository exposing toolchains for each platform like "cue_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.
    Args:
        name: base name for all created repos, like "cue1_14"
        register: whether to call through to native.register_toolchains.
            Should be True for WORKSPACE users, but false when used under bzlmod extension
        version: cue version
        **kwargs: passed to each cue_repositories call
    """
    for platform in PLATFORMS.keys():
        cue_repositories(
            name = name + "_" + platform,
            platform = platform,
            version = version,
            **kwargs
        )
        if register:
            native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )
