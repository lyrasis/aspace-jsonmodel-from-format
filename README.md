# JSONModel from format plugin

Get a jsonmodel representation of a record from a string or file. For example you can get the ArchivesSpace jsonmodel representation of a resource record from raw EAD, or a digital object record(s) from csv (any format that ArchivesSpace provides an importer for).

Note, this does not automatically import the record. To import you still need to post the json to the batch imports api endpoint if that is the goal (examples are provided below).

## Default types

- accession
  - csv
- digital object
  - csv
- eac
- resource
  - ead
  - marcxml

## Installation

Download the plugin to the ArchivesSpace plugins folder and enable it in `config.rb`:

```ruby
AppConfig[:plugins] << "aspace-jsonmodel-from-format"
```

## Examples

To follow the examples grab a session token:

```bash
apt-get install jq
echo "export TOKEN=$(curl -Fpassword=admin http://localhost:8089/users/admin/login | jq '.session')" > .session
source .session
```

_Modify the hostname, port, username and password if needed_

The examples assume that commands are run from the `aspace-jsonmodel-from-format` plugin folder.

## Resources

**EAD**

```bash
# get the jsonmodel representation of examples/ead.xml
curl \
  -H "Content-Type: text/xml" \
  -H "X-ArchivesSpace-Session: $TOKEN" \
  -X POST \
  -d @examples/ead.xml \
  "http://localhost:8089/plugins/jsonmodel_from_format/resource/ead" > ead.json

# import it by sending it to the batch_imports endpoint
curl \
  -H "Content-Type: application/json" \
  -H "X-ArchivesSpace-Session: $TOKEN" \
  -X POST \
  -d @ead.json \
  "http://localhost:8089/repositories/2/batch_imports"
```

**MARCXML**

```bash
# marcxml save as json
curl \
  -H "Content-Type: text/xml" \
  -H "X-ArchivesSpace-Session: $TOKEN" \
  -X POST \
  -d @examples/marc.xml \
  "http://localhost:8089/plugins/jsonmodel_from_format/resource/marcxml" > marc.json

# import it
curl \
  -H "Content-Type: application/json" \
  -H "X-ArchivesSpace-Session: $TOKEN" \
  -X POST \
  -d @marc.json \
  "http://localhost:8089/repositories/2/batch_imports"
```

The input file can contain multiple ead or marcxml records if they are wrapped in a `collection` tag.

## Digital Objects

```bash
# example digital object with --data-binary to preserve data as sent
curl \
  -H "Content-Type: text/plain" \
  -H "X-ArchivesSpace-Session: $TOKEN" \
  -X POST \
  --data-binary @examples/do.csv \
  "http://localhost:8089/plugins/jsonmodel_from_format/digital_object/csv" > do.json

# import it
curl \
  -H "Content-Type: application/json" \
  -H "Content-type:text/xml" \
  -H "X-ArchivesSpace-Session: $TOKEN" \
  -X POST \
  -d @do.json \
  "http://localhost:8089/repositories/2/batch_imports"
```

## Accessions

```bash
# example accession records with --data-binary to preserve data as sent
curl \
  -H "Content-Type: text/plain" \
  -H "X-ArchivesSpace-Session: $TOKEN" \
  -X POST \
  --data-binary @examples/acc.csv \
  "http://localhost:8089/plugins/jsonmodel_from_format/accession/csv" > acc.json

# import it
curl \
  -H "Content-Type: application/json" \
  -H "X-ArchivesSpace-Session: $TOKEN" \
  -X POST \
  -d @acc.json \
  "http://localhost:8089/repositories/2/batch_imports"
```

## Agents

```bash
curl \
  -H "Content-Type: text/xml" \
  -H "X-ArchivesSpace-Session: $TOKEN" \
  -X POST \
  -d @examples/eac.xml \
  "http://localhost:8089/plugins/jsonmodel_from_format/agent/eac" > eac.json

# import it
curl \
  -H "Content-Type: application/json" \
  -H "X-ArchivesSpace-Session: $TOKEN" \
  -X POST \
  -d @eac.json \
  "http://localhost:8089/repositories/2/batch_imports"
```

## Tesing with Docker

```bash
mkdir -p plugins/aspace-jsonmodel-from-format
cp -r backend plugins/aspace-jsonmodel-from-format

docker run --name archivesspace -d \
  -p 8080:8080 \
  -p 8081:8081 \
  -p 8089:8089 \
  -p 8090:8090 \
  -v $(pwd)/config:/archivesspace/config \
  -v $(pwd)/plugins:/archivesspace/plugins \
  lyrasis/archivesspace:2.5.2

docker logs -f --tail=50 archivesspace
```

## License

This plugin is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

---
