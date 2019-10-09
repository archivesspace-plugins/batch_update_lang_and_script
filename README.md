# batch_update_lang_and_script

A plugin to globally update existing default language and/or script of description values of resource records.

## To install:

1. Stop the application
2. Clone the plugin into the `archivesspace/plugins` directory
3. Add `batch_update_lang_and_script` to `config.rb`, ensuring to uncomment/remove the # from the front of the relevant AppConfig line.  For example:
`AppConfig[:plugins] = ['local', 'batch_update_lang_and_script']`
4. Restart the application
