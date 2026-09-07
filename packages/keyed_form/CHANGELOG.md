## 0.1.0

Initial release.

- `KeyedFormController<Root>` — owns the editable draft, the `FieldKey`-keyed
  validation errors, and the touched / dirty / revealed bookkeeping that
  decides when an error is shown.
- `KeyedFormMode` — when a field's error becomes visible.
- Scoped validation via `KeyedFormResolver` / `KeyedFormScopeOf`.
- `KeyedFormList` — by-id list editing (append / insert / remove / move /
  update).
- `KeyedFormSnapshot` — an immutable copy of the coarse state.
