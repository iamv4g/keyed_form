---
title: Dynamic lists
description: Rows are addressed by a stable id, never by index — so text, errors and focus follow a row wherever it moves.
---

Drag a row by its handle, type in it, add and remove rows. The panel below the list shows each row's `clientId` following it to a new index.

<PackingDemo />

## The code

These are the example app's own files — the demo above runs the same schema and controller.

<ExampleCode id="lists-code" files="packing_list/packing_schema.dart packing_list/packing_list.dart packing_list/packing_row.dart" />

## Editing the list

`form.field(PackingFields.items).list()` returns the row editor. Every edit takes an id or an index and keeps ids stable:

| Call | Does |
|---|---|
| `append(item)` | adds a row at the end |
| `insertAfter(clientId, item)` | adds a row below another |
| `move(from, to)` | reorders; `to` is the index after removal |
| `removeById(clientId)` | drops a row and its errors |

## Stable identity beats array indexes

Use each row's `clientId` to build its field reference and widget key. Its index changes after insertion, removal, or a move; its identity does not. This keeps values, errors, focus, and dirty state attached to the same record.

## Rules for the whole list

A list field takes its own rules next to the per-row ones — here `.min(1)` keeps at least one row.
