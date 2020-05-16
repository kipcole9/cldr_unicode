if File.exists?(Unicode.data_dir()) do
  defmodule Mix.Tasks.Unicode.Download do
    @moduledoc """
    Downloads the required Unicode files to support Unicode
    """

    use Mix.Task
    require Logger

    @shortdoc "Download Unicode data files"

    @doc false
    def run(_) do
      Application.ensure_all_started(:inets)
      Application.ensure_all_started(:ssl)

      Enum.each(required_files(), &download_file/1)
    end

    defp required_files do
      [
        {"https://unicode.org/Public/UCD/latest/ucd/UnicodeData.txt",
         data_path("unicode_data.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/extracted/DerivedGeneralCategory.txt",
         data_path("categories.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/Blocks.txt", data_path("blocks.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/Scripts.txt", data_path("scripts.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/DerivedCoreProperties.txt",
         data_path("derived_properties.txt")},
        {"https://unicode.org/Public/UCD/latest/ucd/extracted/DerivedCombiningClass.txt",
         data_path("combining_class.txt")},
        # {"https://unicode.org/Public/emoji/13.0/emoji-sequences.txt", data_path("emoji.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/emoji/emoji-data.txt", data_path("emoji.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt",
         data_path("property_value_alias.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/PropList.txt",
         data_path("properties.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/PropertyAliases.txt",
         data_path("property_alias.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/LineBreak.txt",
         data_path("line_break.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/auxiliary/WordBreakProperty.txt",
         data_path("word_break.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/auxiliary/GraphemeBreakProperty.txt",
         data_path("grapheme_break.txt")},
        {"https://www.unicode.org/Public/UCD/latest/ucd/auxiliary/SentenceBreakProperty.txt",
         data_path("sentence_break.txt")},
        {"https://unicode.org/Public/UCD/latest/ucd/IndicSyllabicCategory.txt",
         data_path("indic_syllabic_category.txt")},
        {"https://unicode.org/Public/UCD/latest/ucd/CaseFolding.txt",
         data_path("case_folding.txt")},
        {"https://unicode.org/Public/UCD/latest/ucd/SpecialCasing.txt",
         data_path("special_casing.txt")}
      ]
    end

    defp download_file({url, destination}) do
      url = String.to_charlist(url)

      case :httpc.request(url) do
        {:ok, {{_version, 200, 'OK'}, _headers, body}} ->
          destination
          |> File.write!(:erlang.list_to_binary(body))

          Logger.info("Downloaded #{inspect(url)} to #{inspect(destination)}")
          {:ok, destination}

        {_, {{_version, code, message}, _headers, _body}} ->
          Logger.error(
            "Failed to download #{inspect(url)}. " <> "HTTP Error: (#{code}) #{inspect(message)}"
          )

          {:error, code}

        {:error, {:failed_connect, [{_, {host, _port}}, {_, _, sys_message}]}} ->
          Logger.error(
            "Failed to connect to #{inspect(host)} to download " <>
              " #{inspect(url)}. Reason: #{inspect(sys_message)}"
          )

          {:error, sys_message}
      end
    end

    defp data_path(filename) do
      Path.join(Unicode.data_dir(), filename)
    end
  end
end
