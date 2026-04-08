# Networking Core Module Release TBD

Welcome to the latest release of the `Networking` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by team SIGHUP by ReeVo.


## Component Images 🚢


## Bug fixes 🐞

- [[#105]](https://github.com/sighupio/module-networking/pull/105) **Add whisker observability**: enable Calico's Whisker observability UI and its required Goldmane flow aggregator as defaults in the tigera/on-prem package.

## Breaking Changes 💔



## Update Guide 🦮

### Process

1. Just deploy as usual:

```bash
kustomize build katalog/tigera/on-prem | kubectl apply -f -
# OR
kustomize build katalog/cilium | kubectl apply -f -
```
