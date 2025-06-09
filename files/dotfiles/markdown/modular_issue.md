issue: `modular install mojo`

```
can't open file "/tmp/modular/'/home/bit'/.modular/pkg/packages.modular.com_mojo/scripts/post-install/install-dependencies.py": [Errno 2] No such file or directory
```

environment:
```
modular -v
modular 0.7.0 (487c2f88)
```

```
echo $MODULAR_HOME
'/home/bit'/.modular
```

```
echo $MAX_PATH
/home/bit/.modular/pkg/packages.modular.com_max/
```

```
uname -a
Linux 6.5.0-26-generic 
#26~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC
x86_64 GNU/Linux
```

```
pyenv versions
  system
* 3.12.2 (set by /home/bit/.pyenv/version)
```

traceback:
```
# Found release for https://packages.modular.com/mojo @ 24.2.0-c2427bc5-release
# Downloading archive: packages/24.2.0-c2427bc5-release/mojo-x86_64-unknown-linux-gnu-24.2.0-c2427bc5-release-11-0.tar.gz
Downloaded   [ ██████████████████████████████████████████████████████ ] 100%     198MiB/198MiB
# Extracting downloaded archives.
Extracted    [ ██████████████████████████████████████████████████████ ] 100%     198MiB/198MiB
# Extraction complete, setting configs...
# Configs complete, running post-install hooks...
/home/bit/.pyenv/versions/3.12.2/bin/python3: can't open file "/tmp/modular/'/home/bit'/.modular/pkg/packages.modular.com_mojo/scripts/post-install/install-dependencies.py": [Errno 2] No such file or directory
modular: error: failed to run script
==========================
Failure Information:
        - Script: `PATH=/home/bit/.pyenv/shims:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:'/home/bit/.modular/pkg/packages.modular.com_max/'/bin:/home/bit/.pyenv/bin:/home/bit/.cargo/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:'/home/bit/.modular/pkg/packages.modular.com_max/'/bin:/home/bit/.pyenv/bin:/home/bit/.cargo/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:/home/bit/.pyenv/bin:'/home/bit/.modular/pkg/packages.modular.com_max/'/bin:/home/bit/.pyenv/bin:/home/bit/.cargo/bin:/home/bit/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin:/usr/local/bin/geckodriver:/usr/local/bin/alacritty:/usr/local/bin/geckodriver:/usr/local/bin/alacritty:/usr/local/bin/geckodriver:/usr/local/bin/alacritty HOME=/home/bit MODULAR_HOME='/home/bit'/.modular/home/bit/.pyenv/shims/python3 '/home/bit'/.modular/pkg/packages.modular.com_mojo/scripts/post-install/install-dependencies.py '/home/bit'/.modular/pkg/packages.modular.com_mojo '/home/bit'/.modular/pkg/packages.modular.com_mojo/scripts/post-install/requirements.txt`
        - Result: 2
        - Stderr:
/home/bit/.pyenv/versions/3.12.2/bin/python3: can't open file "/tmp/modular/'/home/bit'/.modular/pkg/packages.modular.com_mojo/scripts/post-install/install-dependencies.py": [Errno 2] No such file or directory

```
