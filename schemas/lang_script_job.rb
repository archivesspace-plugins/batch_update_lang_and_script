{
  :schema => {
    "$schema" => "http://www.archivesspace.org/archivesspace.json",
    "version" => 1,
    "type" => "object",

    "properties" => {

      "finding_aid_language" => {
        "type" => "string",
        "dynamic_enum" => "language_iso639_2"
      },
      "finding_aid_script" => {
        "type" => "string",
        "dynamic_enum" => "script_iso15924"
      },
      "all_repos" => {
        "type" => "boolean",
        "default" => false
      }

    }
  }
}
