# Scene Tools

Scripts to check integrity of scene releases

## Scripts

### `verify-scene-pre.sh`
Verify all files in a scene directory match the pre in srrDB at https://www.srrdb.com/

### `verify-sfv.sh`
Verify the SFV of audio files in the release match the scene pre .sfv

**Usage:**
- Run from inside the scene release directory:

```bash
./path/to/script.sh
```

- Run from script directory using the -d option:

```bash
./script.sh -d /path/to/release
```

**Optional: add to your PATH**
- To run a script via filename alone without its full path, add your script directory to your PATH. Example, if your scripts are in ~/bin:

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Then run as usual from the release directory, or specify path with -d.
