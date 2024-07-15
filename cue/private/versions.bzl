"""Mirror of release info

TODO: generate this file from GitHub API"""

# https://github.com/cue-lang/cue/releases/download/v0.9.2/checksums.txt
# 87ebebb8459d579ff791843b3228ca64dc372181456d8e2b4ad4e3f0c607c94d  cue_v0.9.2_darwin_amd64.tar.gz
# 0f01909937c7f1b5b58d55e53a7d5366f3b4f8fc48dc31e391dd55340ea1ae95  cue_v0.9.2_darwin_arm64.tar.gz
# 67c88f6c3bdf884301794c3ec91f9e6e3f660e7de3b7e10cd29fbbd291baac50  cue_v0.9.2_linux_amd64.tar.gz
# 3b90c49faaf3367338bd95db0bf76ec86bf4ca7d175d42a221e27bdc8d265256  cue_v0.9.2_linux_arm64.tar.gz
# b63616df5dcc13dc968e714d4935d2823600aa5bdda049edbcaeb639c91a1c76  cue_v0.9.2_windows_amd64.zip
# 30fb3b62889f45da8c79a75c4c8772ea47306e5edca5c921c7ffb9095522ae1c  cue_v0.9.2_windows_arm64.zip
TOOL_VERSIONS = {
    "0.9.2": {
        "darwin-amd64": "87ebebb8459d579ff791843b3228ca64dc372181456d8e2b4ad4e3f0c607c94d",
        "darwin_arm64": "0f01909937c7f1b5b58d55e53a7d5366f3b4f8fc48dc31e391dd55340ea1ae95",
        "linux_amd64": "67c88f6c3bdf884301794c3ec91f9e6e3f660e7de3b7e10cd29fbbd291baac50",
        "linux_arm64": "3b90c49faaf3367338bd95db0bf76ec86bf4ca7d175d42a221e27bdc8d265256",
        "windows_amd64": "b63616df5dcc13dc968e714d4935d2823600aa5bdda049edbcaeb639c91a1c76",
        "windows_arm64": "30fb3b62889f45da8c79a75c4c8772ea47306e5edca5c921c7ffb9095522ae1c",
    },
}
