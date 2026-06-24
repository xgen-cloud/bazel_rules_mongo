load("@aspect_bazel_lib//lib:expand_template.bzl", "expand_template")
load("@aspect_bazel_lib//lib:paths.bzl", "BASH_RLOCATION_FUNCTION")
load("@rules_shell//shell:sh_binary.bzl", "sh_binary")
load("@rules_shell//shell:sh_test.bzl", "sh_test")

def sh_template(
        name,
        template,
        substitutions = {},
        stamp_substitutions = {},
        tools = {},
        data = [],
        deps = [],
        test = False,
        output_file = None,
        visibility = ["//visibility:private"],
        toolchains = [],
        tags = [],
        **kwargs):
    default_deps = ["@bazel_tools//tools/bash/runfiles"]
    default_data = [] + toolchains
    default_substitutions = {
        # preamble needs to be escaped for make variables
        "@@BASH_RLOCATION_FUNCTION@@": BASH_RLOCATION_FUNCTION.replace("$", "$$"),
    }
    for tool, label in tools.items():
        default_substitutions["@@{}@@".format(tool)] = "$(rlocationpaths {})".format(label)
        default_data.append(label)

    if not output_file:
        output_file = "_{}.sh".format(name)

    substitutions = default_substitutions | substitutions

    expand_template(
        name = "_{}".format(name),
        template = template,
        out = output_file,
        data = default_data + data,
        is_executable = True,
        substitutions = substitutions,
        stamp_substitutions = stamp_substitutions,
        toolchains = toolchains,
        **kwargs
    )
    if test:
        sh_test(
            name = name,
            srcs = [output_file],
            data = default_data + data,
            deps = default_deps + deps,
            tags = ["lint-genfiles"] + tags,
            toolchains = toolchains,
        )
    else:
        sh_binary(
            name = name,
            srcs = [output_file],
            data = default_data + data,
            deps = default_deps + deps,
            tags = ["lint-genfiles"] + tags,
            visibility = visibility,
            toolchains = toolchains,
        )

def sh_template_test(**kwargs):
    kwargs["test"] = True
    sh_template(**kwargs)
