# General Utilities

General utilities for dealing with music files and their tags

## Scripts

### `rename-files.sh`
Rename all files in a directory by removing a specified string

**Usage:**
- Run from inside the scene release directory or specify path:

```bash
./path/to/script.sh "string to remove" /optional/path/to/release
```

- -r Recursive (include directories)
- -d Also rename directories

**Optional: add to your PATH**
- To run a script via filename alone without its full path, add your script directory to your PATH. Example, if your scripts are in ~/bin:

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Then run as usual.