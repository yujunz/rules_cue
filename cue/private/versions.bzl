"""Mirror of release info

TODO: generate this file from GitHub API"""

TOOL_VERSIONS = {
    # https://github.com/cue-lang/cue/releases/download/v0.10.0/checksums.txt
    # cdd6acbd87528ae8f8f62497770a600ea23503d6f8b46f5919c7008f20b5238f  cue_v0.10.0_darwin_amd64.tar.gz
    # f72e5dae8b682f43a1e80fb3066a42e82c77725ac2a175927212d0be9d12671a  cue_v0.10.0_darwin_arm64.tar.gz
    # 8f449c76f69c94fd17fff869e96ec34de7f059d6d63bf05617477ed0e6133fd2  cue_v0.10.0_linux_amd64.tar.gz
    # 49369a3566af3117712a7a91dc2ec924cb5c4128385ab2edd877d9997e761312  cue_v0.10.0_linux_arm64.tar.gz
    # ae09f026261331530593966ab2d61b330a6565fd7339c13a3eed3eaa5bd4c066  cue_v0.10.0_windows_amd64.zip
    # e82bececf6aafcee74b9be4273b0163299939d0cea95fd32e8349854667775bc  cue_v0.10.0_windows_arm64.zip
    "0.10.0": {
        "darwin_amd64": "cdd6acbd87528ae8f8f62497770a600ea23503d6f8b46f5919c7008f20b5238f",
        "darwin_arm64": "f72e5dae8b682f43a1e80fb3066a42e82c77725ac2a175927212d0be9d12671a",
        "linux_amd64": "8f449c76f69c94fd17fff869e96ec34de7f059d6d63bf05617477ed0e6133fd2",
        "linux_arm64": "49369a3566af3117712a7a91dc2ec924cb5c4128385ab2edd877d9997e761312",
        "windows_amd64": "ae09f026261331530593966ab2d61b330a6565fd7339c13a3eed3eaa5bd4c066",
        "windows_arm64": "e82bececf6aafcee74b9be4273b0163299939d0cea95fd32e8349854667775bc",
    },
    # https://github.com/cue-lang/cue/releases/download/v0.9.2/checksums.txt
    # 87ebebb8459d579ff791843b3228ca64dc372181456d8e2b4ad4e3f0c607c94d  cue_v0.9.2_darwin_amd64.tar.gz
    # 0f01909937c7f1b5b58d55e53a7d5366f3b4f8fc48dc31e391dd55340ea1ae95  cue_v0.9.2_darwin_arm64.tar.gz
    # 67c88f6c3bdf884301794c3ec91f9e6e3f660e7de3b7e10cd29fbbd291baac50  cue_v0.9.2_linux_amd64.tar.gz
    # 3b90c49faaf3367338bd95db0bf76ec86bf4ca7d175d42a221e27bdc8d265256  cue_v0.9.2_linux_arm64.tar.gz
    # b63616df5dcc13dc968e714d4935d2823600aa5bdda049edbcaeb639c91a1c76  cue_v0.9.2_windows_amd64.zip
    # 30fb3b62889f45da8c79a75c4c8772ea47306e5edca5c921c7ffb9095522ae1c  cue_v0.9.2_windows_arm64.zip
    "0.9.2": {
        "darwin_amd64": "87ebebb8459d579ff791843b3228ca64dc372181456d8e2b4ad4e3f0c607c94d",
        "darwin_arm64": "0f01909937c7f1b5b58d55e53a7d5366f3b4f8fc48dc31e391dd55340ea1ae95",
        "linux_amd64": "67c88f6c3bdf884301794c3ec91f9e6e3f660e7de3b7e10cd29fbbd291baac50",
        "linux_arm64": "3b90c49faaf3367338bd95db0bf76ec86bf4ca7d175d42a221e27bdc8d265256",
        "windows_amd64": "b63616df5dcc13dc968e714d4935d2823600aa5bdda049edbcaeb639c91a1c76",
        "windows_arm64": "30fb3b62889f45da8c79a75c4c8772ea47306e5edca5c921c7ffb9095522ae1c",
    },
    # https://github.com/cue-lang/cue/releases/download/v0.8.2/checksums.txt
    # 9f91ca27cfa7110c9e7b69ff751a6521be72db2b28e29b9b36b055e6ffb6d156  cue_v0.8.2_darwin_amd64.tar.gz
    # 4c9244623ae0c95971dbcc5f938e210d96efd5c1850bb346b0bdaaf5190a375d  cue_v0.8.2_darwin_arm64.tar.gz
    # 9c95df381722b8e547ab6f257981c73246ac7c7f7a6da7571b405bef6ffb22a0  cue_v0.8.2_linux_amd64.tar.gz
    # af846c9c11925f4f28f051b8778c779535a307923d7d5fb2a9bdc92aa5925325  cue_v0.8.2_linux_arm64.tar.gz
    # 7b172396a63b34c24612c6e9da0e49db137d35f35633b133d5a33eb82e4c3611  cue_v0.8.2_windows_amd64.zip
    # 7233a300e98cbdf542f6a4e111e60a090abe9e6d1cab595b47b480d4ace87ce7  cue_v0.8.2_windows_arm64.zip
    "0.8.2": {
        "darwin_amd64": "9f91ca27cfa7110c9e7b69ff751a6521be72db2b28e29b9b36b055e6ffb6d156",
        "darwin_arm64": "4c9244623ae0c95971dbcc5f938e210d96efd5c1850bb346b0bdaaf5190a375d",
        "linux_amd64": "9c95df381722b8e547ab6f257981c73246ac7c7f7a6da7571b405bef6ffb22a0",
        "linux_arm64": "af846c9c11925f4f28f051b8778c779535a307923d7d5fb2a9bdc92aa5925325",
        "windows_amd64": "7b172396a63b34c24612c6e9da0e49db137d35f35633b133d5a33eb82e4c3611",
        "windows_arm64": "7233a300e98cbdf542f6a4e111e60a090abe9e6d1cab595b47b480d4ace87ce7",
    },
}
