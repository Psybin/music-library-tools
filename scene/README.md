# Scene Tools

Scripts to check integrity of scene releases

## Scripts

### `verify-scene-pre.sh`
Verify all files in a scene directory match the pre in srrDB at https://www.srrdb.com/

**Usage:**
- Run from inside the scene release directory:

```bash
./path/to/script/verify-scene-pre.sh
```

- Run from script directory using the -d option:

```bash
./verify-scene-pre.sh -d /path/to/release
```

**Optional: add to your PATH**
- To run the script without specifying its full path, you can add your script directory to your PATH. For example, if your scripts are in ~/bin:

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Then run as usual from the release directory, or specify path with -d:
