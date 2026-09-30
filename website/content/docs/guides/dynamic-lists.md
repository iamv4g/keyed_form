---
title: Dynamic lists
description: Edit and reorder rows by stable identity so values and errors stay with the same record.
---

Rows are addressed by stable `clientId`, never by their changing index. The interactive example lets you drag rows, edit them, and add or remove entries; its panel shows each id moving with its row.

<PackingDemo />

## The example source

These are the example app's own files—the interactive demo uses the same schema and controller:

<ExampleCode id="lists-code" files="packing_list/packing_schema.dart packing_list/packing_list.dart packing_list/packing_row.dart" />

## Edit by identity

`form.field(PackingFields.items).list()` returns the list editor. It supports operations such as `append(item)`, `insertAfter(clientId, item)`, `move(from, to)`, and `removeById(clientId)`. Prefer by-id edits when the target row is already known; indexes are positions and change after insertion, removal, or movement. For the complete operation set, see [List operations](docs/form-state/lists).

Use each row's `clientId` to build its field reference and Flutter widget key. The row id remains stable while its index changes, keeping values, errors, and dirty tracking associated with the same record. See [Flutter lists and virtualization](docs/flutter/long-lists) for lazily built rows.

## Validate the collection

List-level rules belong on the list validator (the example requires at least one row); row fields retain their own validation. Collection semantics and limits are covered in [Objects and collections](docs/schema/composition).
