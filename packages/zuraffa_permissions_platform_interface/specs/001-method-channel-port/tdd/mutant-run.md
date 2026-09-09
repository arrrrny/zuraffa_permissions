# Deliberate-mutant red evidence (spec 001-method-channel-port)

| behavior | mutant | baseline | mutant | revert | verdict |
| --- | --- | --- | --- | --- | --- |
| U1 | wire constant `granted` renamed to 'GRANTED' | baseline PASS | mutant KILLED | revert PASS | OK |
| U2 | default instance initialization removed (late field — read throws) | baseline PASS | mutant KILLED | revert PASS | OK |
| U3 | instance setter drops the registration assignment | baseline PASS | mutant KILLED | revert PASS | OK |
| U4 | fallback checkPermissions reports 'granted' instead of 'undetermined' | baseline PASS | mutant KILLED | revert PASS | OK |
| U5 | fallback requestPermissions reports 'granted' instead of 'undetermined' | baseline PASS | mutant KILLED | revert PASS | OK |
| U6 | fallback openSettings claims it can launch | baseline PASS | mutant KILLED | revert PASS | OK |
| U7 | client invokes method 'checkPermission' (wrong protocol name) | baseline PASS | mutant KILLED | revert PASS | OK |
| U8 | client invokes method 'requestPermission' (wrong protocol name) | baseline PASS | mutant KILLED | revert PASS | OK |
| U9 | null-reply guard removed | baseline PASS | mutant KILLED | revert PASS | OK |
| U10 | stringify normalization replaced with hard casts | baseline PASS | mutant KILLED | revert PASS | OK |
| U11 | null openSettings verdict no longer degrades to false | baseline PASS | mutant KILLED | revert PASS | OK |
| U12 | wire 'denied' mapped onto PermissionStatus.granted | baseline PASS | mutant KILLED | revert PASS | OK |
| U13 | unknown/missing wire values default to granted (no forward-compat degradation) | baseline PASS | mutant KILLED | revert PASS | OK |
| U14 | requestedAt pinned to 0 (no real timestamp) | baseline PASS | mutant KILLED | revert PASS | OK |
| U15 | adapter openSettings stops delegating, always false | baseline PASS | mutant KILLED | revert PASS | OK |
| U16 | constructor ignores the injected platform override | baseline PASS | mutant KILLED | revert PASS | OK |
| U17 | no-override path ignores the registered instance, fabricates a fresh default | baseline PASS | mutant KILLED | revert PASS | OK |
