# seqcloud

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

Connect to your high-performance computing (HPC) cluster and clone our git repository:

```{bash}
git clone https://github.com/steinbaugh/seqcloud.git ~/seqcloud
```


## [HMS Orchestra](https://wiki.med.harvard.edu/Orchestra/WebHome) setup

### `.bash_profile` file

This will automatically boot an interactive session upon login.

```{bash}
bsub -Is -q interactive bash
```

### `.bashrc` file

The interactive session with now load `seqcloud` and change the default user permissions for better security.

```{bash}
. ~/seqcloud/seqcloud.sh

# Restrict world access
umask 0007
```
