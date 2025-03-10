# clo4's tiny cloudflare ddns client

There are a lot of DDNS clients that exist, but most of them are massive
overkill for what I need. This program fits my requirements exactly, and does
nothing more:

- Updates A records with Cloudflare's DNS
- Updates multiple records at once, concurrently
- Doesn't run as a daemon (user is expected to use a scheduler, e.g. systemd
  timers or cron)
- Doesn't do anything more complicated than it has to (no custom configuration
  languages)
- Compiled, not interpreted

This is a simple Go program. I don't have any use-case for this outside of Nix,
so I'm not concerned about releasing it in a binary format. This source code is
unlicensed - as close to public domain as I can legally make it. You can copy
it, change it, vendor it, whatever. I don't care. The license is included in the
project root.

Since this does exactly what I need, there are edge-cases that I don't care
about that this doesn't handle. Namely:

- Partial failures will cause the address cache write to be skipped, meaning
  each record will be updated again even if it succeeded previously.
- IPv6 is unsupported (this will not be a limitation forever, eventually I'll
  want this)
- Configuration is not checked for correctness. You can enter garbage data into
  any of the fields
- The cache location is not configurable, so if you don't want to use `/var/tmp`
  (which may not be reasonable on another system) you don't have a choice

None of these shortcomings matter at all for what I need this to do. However, if
someone that is not me wants to use this, you must be aware of what it does and
does not do.

## Configuration

You configure this tool by setting a CONFIG_PATH environment variable to the
path of a JSON file.

That JSON file is an array of objects that contain the following fields:

- `api_token`
- `zone_id`
- `record_id`
- `domain_name`

To minimize the complexity of the implementation, you must supply the record ID.
This means that there must be an existing DNS record - this program will not
create one for you. Unfortunately, the record ID is not exposed anywhere in the
dashboard interface, meaning you need to use information returned by the API to
get this detail.

### Getting record IDs

The simplest way is to load the dashboard to the records list for a given
domain, open the network inspector, and reload the page. There will be an API
request to `dns_records` that contains all of the details.

The more complicated way is to use the API yourself. I'm including this as
futureproofing in case the dashboard ever changes or makes it harder to get this
information, such as by server-rendering the page.

First, you'll need an API token. To get an API token, in the dashboard go to
Profile > API tokens. Create one with the permission 'Zone' 'DNS' 'Edit'. This
is the only permission you'll need. While you're there, you'll also need another
token to list your records to get the record_id. Create a token with 'Zone'
'DNS' 'Read'. The script below will get the IDs for each of the records.

```
curl -X GET "https://api.cloudflare.com/client/v4/zones/ZONE_ID_HERE/dns_records" \
     -H "Authorization: Bearer YOUR_TOKEN_HERE" \
     -H "Content-Type:application/json" | jq '.result[] |  { name, id }'
```
