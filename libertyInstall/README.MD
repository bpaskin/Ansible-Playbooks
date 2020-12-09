Install liberty using a Liberty prepackaged that is retrieved from a remote systems.  The following yaml parameters are taken:

```
level: '200012'
version: base
```
Where level is the level os liberty 20.0.0.12 = 200012, and version is core, base or nd.

This will create a directory under `/usr/WebSphere` called `versions`.  Under the `versions` directory the correct will be downloaded and called `wlp-version-level`, i.e. wlp-base-200012

a softlink will be made from `/usr/WebSphere/wlp` -> `/usr/WebSphere/versions/wlp-version-level` and the `usr` directory will be placed under `/usr/WebSphere/usr` or it will be upgraded.
