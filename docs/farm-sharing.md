# Farm export and import

Open **Farms → My Farms → Share**.

- **Export farm** exports the selected saved farm.
- **Export all** puts all saved farms in one string.
- **Import string** opens the paste field. Click **Import farms** to add the farms as new copies.

Copy the complete string with Ctrl+A, Ctrl+C. Line breaks and surrounding whitespace are accepted when importing.

## Included data

The export contains complete saved farm and item records, including additional nested fields, assignments, timestamps, selected methods, map locations, route coordinates, pin metadata, tips and source links. It includes the full route plan: order, locked stops, location overrides, guidance settings and each character's saved progress.

Linked catalog farms are embedded with their target/yield metadata, all resolved map options, referenced gathering records and instance entrance information. Imported farms use these snapshots rather than replacing their geometry with the recipient's local catalog. Saved map-source selections also carry their resolved geometry.

Farm run history records stored in Session History are included and imported with the corresponding farm.

## Import behavior

Existing farms and history records are kept. Farm IDs and history IDs are reassigned locally to prevent collisions; item IDs within each farm and route stop keys remain intact. The original build/active-character context is retained in `transferContext`, while importing does not start navigation or replace an active route.

The complete collection is decoded and validated before any farms or history are added. Unsupported versions, incomplete strings, checksum mismatches, missing linked data and invalid records produce an error instead of a partial import. Exports likewise fail explicitly if a required dependency cannot be included.

## Format and verification

Version 1 uses a `GGT-FARMS:1:` prefix, uncompressed byte length, Adler-32 checksum and a Base64-encoded Deflate-compressed CBOR payload. Encoding uses Retail's `C_EncodingUtil` API; pasted text is never evaluated as Lua.

Automated round-trip tests cover maps and provenance, per-character progress, route plans, history ID remapping, unknown fields, reload persistence, missing local catalogs, multiple catalog snapshots, corruption and atomic rejection. Codec APIs are substituted in headless tests; real Deflate/Base64 have also been exercised. The native CBOR codec and rendered copy/paste flow still require an in-game check after `/reload`.
