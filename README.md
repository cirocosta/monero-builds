# monero builds

_probably_ the fastest way of getting a full linux build of [monero].

_ps.: **if you don't have that many cores, it's not going to be fast anyway**.
the trick here is to make use of a build stage for each dependency that we care
about compiling from scratch, feeding their compilation with a high job count
and leveraging buildkit's sweet caching wit ccache for the monero build stage
so we can recompile multiple times if we want while doing it so quickly._


## why

there are several ways to build `monero` depending on what you're trying to
achieve: for those not constantly developing but in need of getting a fast
build of a particular pull-request or commit that hasn't been tagged yet, I
believe this strikes a nice balance between consistency library-wise (builds
the most important libraries from source) and simplicity (no use `depends` all
the necessary tweaks that gitian uses to create reproducible binaries).


## consuming

this repository continuously (well, more like manually tbh) builds images of
[monero] whenever new commits to `master`, `release-v0.17`, or a new tag is
pushed.

```bash
# tagged release
#
docker run --rm utxobr/monero:v0.17.2.3 monerod --version


# whatever is current master
#
docker run --rm utxobr/monero:master


# release branch
#
docker run --rm utxobr/monero:release-v0.17
```

## why should i trust you?

well, maybe you should't! i provide no guarantees at all that things haven't
been compromised. as mentioned before, no efforts here are put into producible
bit-by-bit reproducible builds - if you care about that, make sure you consume
tagged releases (which yes, are reproducibly built by multiple collaborators -
see [monero-project/gitian.sigs])[^1]

see [./images.lock.yaml](./images.lock.yaml) for the digests.

[^1]: no, not boostrappable builds .. yet. maybe you'll be the one working on
  it?


## ok, i trust you, but not dockerhub

well, in this case, you can make sure that I built the images by verifying that
I signed the commits in this repository with my PGP key.

see [9CD1 1313 8578 59CC 0FAD  E93B 6B93 177A 62D0 1DB8](https://utxo.com.br/pgp/public-key.txt)


## usage

to build the images yourself, all it takes is having a recent-enough version of
Docker (17.05+) enabled with experimental features and buildkit, and then
running a plain `docker build` tweaking any arguments you care about.

```console
$ cat ./Dockerfile | grep ARG

        ARG NPROC
        ARG BOOST_VERSION=1_77_0
        ARG BOOST_VERSION_DOT=1.77.0
        ARG BOOST_HASH=fc9f85fc030e233142908241af7a846e60630aa7388de9a5fafb1f3a26840854
        ...
        ARG PROTOBUF_HASH=6973c3a5041636c1d8dc5f7f6c8c1f3c15bc63d6
        ARG MONERO_REPOSITORY=https://github.com/monero-project/monero
        ARG MONERO_REVISION=master
```

unless you're experimenting with a new version of a dependency, modifying the
default `MONERO_*` ones is probably all you care and are looking for:

```bash
#
#
#       """
#       hey, build an image called `myuser/monerfoo` 
#       using the current directory as the build context
#       and overriding the build argument MONERO_REVISION
#       with this git revision I want.
#       """
#
#
docker build \
  --tag myuser/monerofoo \
  --build-arg MONERO_REVISION=8fde011 \
  .
```

## license

see [license](http://www.wtfpl.net/).

[monero]: https://github.com/monero-project/monero
[monero-project/gitian.sigs]: https://github.com/monero-project/gitian.sigs
