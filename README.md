# Docsearch utils

Some small utilities to work with the [Docsearch configs](https://github.com/algolia/docsearch-configs),
both public and private.

## `txt_to_json.rb`

Converts the _private_ .txt configs into the new JSON format.

## `introspector.rb`

Eventually meant to run reporting on the public & private configs. Today the
only thing it really does is convert the public configs into a CSV that can be
imported into Google Sheets for manual analysis.
