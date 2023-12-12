defmodule Membrane.PrecompiledDependencyProvider do
  @moduledoc """
  Module providing URLs for precompiled dependencies used by Membrane plugins.

  Dependencies that are fully located in the repositories of `membraneframework-precompiled` will
  be referred to as Generic. Otherwise they will be referred to as Non-generic.
  """
  @membrane_precompiled_org_url "https://github.com/membraneframework-precompiled"

  @non_generic_precompiled_deps [
    :ffmpeg
  ]

  @type precompiled_dependency() ::
          :ffmpeg | :portaudio | :"fdk-aac" | :srtp | :opus | :sdl2 | :portaudio | :mad

  @doc """
  Get URL of a precompiled build of given dependency for appropriate target.
  """
  @spec get_precompiled_dependency_url(dependency :: precompiled_dependency()) ::
          String.t() | nil
  def get_precompiled_dependency_url(dependency) do
    target = Bundlex.get_target()

    case dependency do
      generic_dep when generic_dep in @non_generic_precompiled_deps ->
        get_non_generic_dep_url(generic_dep, target)

      non_generic_dep ->
        get_generic_dep_url(non_generic_dep, target)
    end
  end

  @spec get_generic_dep_url_prefix(dep :: precompiled_dependency()) :: String.t()
  defp get_generic_dep_url_prefix(dep) do
    "#{@membrane_precompiled_org_url}/precompiled_#{dep}/releases/latest/download/#{dep}"
  end

  @spec get_generic_dep_url(dep :: precompiled_dependency(), target :: Bundlex.target()) ::
          String.t() | nil
  defp get_generic_dep_url(dep, target) do
    url_prefix = get_generic_dep_url_prefix(dep)

    case target do
      %{abi: "musl"} ->
        nil

      %{os: "linux"} ->
        "#{url_prefix}_linux.tar.gz"

      %{architecture: "x86_64", os: "darwin" <> _rest_of_os_name} ->
        "#{url_prefix}_macos_intel.tar.gz"

      %{architecture: "aarch64", os: "darwin" <> _rest_of_os_name} ->
        "#{url_prefix}_macos_arm.tar.gz"

      _other ->
        nil
    end
  end

  @spec get_non_generic_dep_url(dep :: precompiled_dependency(), target :: Bundlex.target()) ::
          String.t() | nil
  defp get_non_generic_dep_url(:ffmpeg, target) do
    url_prefix = get_generic_dep_url_prefix(:ffmpeg)

    case target do
      %{abi: "musl"} ->
        nil

      %{architecture: "aarch64", os: "linux"} ->
        "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n6.0-latest-linuxarm64-gpl-shared-6.0.tar.xz"

      %{os: "linux"} ->
        "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n6.0-latest-linux64-gpl-shared-6.0.tar.xz"

      %{architecture: "x86_64", os: "darwin" <> _rest_of_os_name} ->
        "#{url_prefix}_macos_intel.tar.gz"

      %{architecture: "aarch64", os: "darwin" <> _rest_of_os_name} ->
        "#{url_prefix}_macos_arm.tar.gz"

      _other ->
        nil
    end
  end
end
