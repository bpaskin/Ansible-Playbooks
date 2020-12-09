This upgrades liberty from one version and level to another.  Liberty can be under `/usr/WebSphere/versions` with a softlink from `/usr/WebSphere/wlp` and a new version will be added to the `/usr/WebSphere/versions` directory and update the `/usr/WebSphere/usr/` directories.

This can also do an "in place" upgrade where the `/usr/WebSphere/wlp/usr` directory remains in place while the other parts of Liberty is upgraded. 

The following yaml parameters are taken:
```
level: '200012'
version: base
```
