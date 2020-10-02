```
   ____       _               ____        _       _
  / ___| ___ (_)_ __   __ _  |  _ \ _   _| |_ ___| |__        ___________
 | |  _ / _ \| | '_ \ / _` | | | | | | | | __/ __| '_ \      /    /     /\
 | |_| | (_) | | | | | (_| | | |_| | |_| | || (__| | | |    /____/____ /  \
  \____|\___/|_|_| |_|\__, | |____/ \__,_|\__\___|_| |_|   /    /     /\  /\
                 _   _|___/        ____ ____  _   _       /____/_____/  \/  \
    ___  _ __   | |_| |__   ___   / ___|  _ \| | | |      \    \     \  /\  /
   / _ \| '_ \  | __| '_ \ / _ \ | |  _| |_) | | | |       \____\_____\/  \/
  | (_) | | | | | |_| | | |  __/ | |_| |  __/| |_| |        \    \     \  /
   \___/|_| |_|  \__|_| |_|\___|  \____|_|    \___/          \____\_____\/
```

# Going dutch on the GPU

<b>Boilerplate for fractional GPU sharing on Kubernetes</b>

By: Alexander Comerford (alexanderjcomerford@gmail.com)

## What is this?

This repo lets you get up and running executing your [containerized](https://medium.com/faun/the-missing-introduction-to-containerization-de1fbb73efc5)
workloads with fractional GPU sharing. In a few simple steps you
can setup your own GPU enabled [Kubernetes](https://kubernetes.io/) cluster on your machine.

## Why is this useful?

More and more Data Scientists, Machine Learning Engineers, and
Developers are shifting to "containerizing" their projects and
using GPU hardware to accelerate them. This project is an ode
to effective resource utilitzation and a message to programmers
to take into consideration the resources their software needs.


## Running this project

This repo assumes that you have [libvirt](https://libvirt.org/) and [vagrant](https://www.vagrantup.com/)
installed, and have your machine configured to do PCIe passthrough (check references for more).

This repo is run in a *step-wise* fashion where the user needs ensures each step
runs properly.

0. Find host PCIe Nvidia GPU devices

```shell
$ ./bin/00_host_get_gpu_devices.sh
```

You can verify that devices have been found by `cat`ing the file `PCI_GPUS.env`

```shell
$ cat ./PCI_GPUS.env
```

1. Install vagrant plugins.

``` shell
$ ./bin/10_host_setup_vagrant.sh
```

2. Bring up the VM with PCI passthrough and setup `nvidia-docker` and `cuda` inside

``` shell
$ source PCI_GPUS.env && vagrant up
$ vagrant ssh -c "./bin/20_guest_setup_cuda_docker.sh"
```

To test that the `nvidia-toolkit` is installed

``` shell
$ vagrant ssh -c "./bin/21_guest_test_docker_runtime.sh"
```

You should see the `nvidia-smi` table with your gpus listed

3. Install some tools into the VM (`golang`, `arkade`, `docker-compose`, `ctop`)

``` shell
$ vagrant ssh -c "./bin/31_guest_install_golang.sh"
$ vagrant ssh -c "./bin/32_guest_install_arkade.sh"
$ vagrant ssh -c "./bin/33_guest_install_docker_compose.sh"
$ vagrant ssh -c "./bin/34_guest_install_ctop.sh"
```

4. Setup a `k3s` cluster inside the VM

``` shell
$ vagrant ssh -c "./bin/40_guest_setup_k3s_cluster.sh"
```

To verify that the cluster is up and running, check the status of all the pods for the cluster

```shell
$ vagrant ssh -c "kubectl get pods -A"
```

5. Setup `gpu-manager` on `k3s` (If you want to learn more about `gpu-manager`, check out the references).

``` shell
$ vagrant ssh -c "./bin/50_guest_setup_gpu_manager.sh"
```

Test that `gpu-manager` has been installed correctly by running 2 pods with fractional resources

``` shell
$ vagrant ssh -c "./bin/51_guest_test_gpu_manager.sh"
```

If you managed to run all these steps, congratulations! You successfully created a Kubernetes cluster
with fractional GPU sharing!

## References

* Libvirt and PCIe passthrough

    - Github tutorial: https://github.com/bryansteiner/gpu-passthrough-tutorial
    - GrayWolfTech video tutorial: https://www.youtube.com/watch?v=dsDUtzMkxFk
    - Chris Titus Tech video tutorial: https://www.youtube.com/watch?v=3yhwJxWSqXI

* `gpu-manager`

    - Github Repo: https://github.com/tkestack/gpu-manager
    - paper: https://ieeexplore.ieee.org/abstract/document/8672318
