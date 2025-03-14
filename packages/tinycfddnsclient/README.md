# clo4's tiny cloudflare ddns client

There are a lot of DDNS clients that exist, but most of them are massive
overkill for what I need. This program fits my requirements exactly, and does
nothing more:

- Updates both A and AAAA records with Cloudflare's DNS
- Updates multiple records at once, concurrently
- Doesn't run as a daemon (user is expected to use a scheduler, e.g. systemd
  timers or cron)
- Doesn't do anything more complicated than it has to (no custom configuration
  languages, just JSON)
- Compiled, not interpreted

This is a simple Go program. I don't have any use-case for this outside of Nix,
so I'm not concerned about releasing it in a binary format. This source code is
unlicensed - as close to public domain as I can legally make it. You can copy
it, change it, vendor it, whatever. I don't care. The license is included in the
project root.

Since this does exactly what I need, there are edge-cases that I don't care
about that this doesn't handle. Namely:

- Partial failures will cause the address cache write to be skipped, meaning
  each record will be updated again even if it succeeded previously
- Configuration is not checked extensively for correctness. You are responsible
  for providing valid data

None of these shortcomings matter at all for what I need this to do. However, if
someone that is not me wants to use this, you must be aware of what it does and
does not do.

## Configuration

You configure this tool by setting environment variables:

- `DDNS_CONFIG_PATH`: Required. Path to the JSON configuration file
- `DDNS_CACHE_PATH`: Optional. Directory where IP address cache files will be
  stored. If not set, caching will be disabled and DNS records will be updated
  on every run

The configuration file is a JSON object with two optional arrays, `a` and
`aaaa`, each containing objects with the following fields:

```json
{
  "a": [
    {
      "name": "example.com",
      "api_token": "your-cloudflare-api-token",
      "zone_id": "your-cloudflare-zone-id",
      "record_id": "your-cloudflare-record-id"
    }
  ],
  "aaaa": [
    {
      "name": "example.com",
      "api_token": "your-cloudflare-api-token",
      "zone_id": "your-cloudflare-zone-id",
      "record_id": "your-cloudflare-record-id"
    }
  ]
}
```

You must supply the record ID for each DNS record you want to update. This means
there must be existing DNS records - this program will not create them for you.
Unfortunately, the record ID is not exposed anywhere in the dashboard interface,
meaning you need to use information returned by the API to get this detail.

When running with Nix, ensure any configuration files are encrypted, as the
tokens will be readable in plain text. Search this repository for "ddns" for
example configuration.

### Cache Files

When `DDNS_CACHE_PATH` is set, the program will:

- Store IPv4 addresses in `current_address_ipv4.txt`
- Store IPv6 addresses in `current_address_ipv6.txt`

These files help avoid unnecessary DNS updates when your IP address hasn't
changed.

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

## How it works

When executed, the program:

1. Loads the configuration from the path specified in `DDNS_CONFIG_PATH`
2. Concurrently processes A and AAAA records (if any are defined)
3. For each record type:
   - Fetches your current IP address (IPv4 or IPv6) from ipify.org
   - Checks if this IP matches the cached IP (if caching is enabled)
   - Only updates DNS records if the IP has changed
   - Updates all records of that type concurrently
   - Caches the new IP if all updates succeeded (and caching is enabled)

All operations use a 10-second timeout and failures are logged with detailed
information.
