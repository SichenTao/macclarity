# Threat model

## Trust boundary

Collector facts are immutable evidence. Rules reference evidence identifiers. Guidance text is non-authoritative. A validated cleanup manifest becomes executable only after a user-confirmed receipt binds its digest, targets and expiry.

Filenames, paths, archive entries, process arguments, document contents and personalized guidance are untrusted input. They are length-bounded before analysis and never interpolated into shell commands.

## Fail-closed cases

- system, filesystem, home, workspace or Library roots;
- wildcards, unresolved variables and symbolic links;
- missing or changed targets;
- expired or mismatched receipts;
- incomplete permissions presented as complete coverage.
