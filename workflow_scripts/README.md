# Scripts to help with workflow

## Joplin note script `Joplin_add_notes.sh`

* `Joplin_add_notes.sh` interacts with any created `Joplin Workbook`. Through the Joplin Web Clipper API to:
	1. Add new notes to the desired Workbook
	2. Delete listed notes from a single Workbook
	3. Wipe all desired notes from the whole Joplin app

* Enable the clipper service by:
	- Tools > Options > Web Clipper > Enable Web Clipper Service

![Joplin_add_script.sh demo](https://i.imgur.com/BZQb3xR.gif)

## Bash reformat script `fix_url_code.sh`

* `fix_url_code.sh` Help remove empty lines and fix broken code indenttation.
	1. `Sed` Magic.
	2. Use of VIM's `gg = G` command mode command to auto indent.

```bash
./fix_url_code.sh <filename>
./fix_url_code.sh useful.cpp
```
