```
   ____       _               ____        _       _
  / ___| ___ (_)_ __   __ _  |  _ \ _   _| |_ ___| |__        ___________
 | |  _ / _ \| | '_ \ / _` | | | | | | | | __/ __| '_ \      /    /     /\
 | |_| | (_) | | | | | (_| | | |_| | |_| | || (__| | | |    /____/_____/  \
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
using GPU hardware to accelerate them. With these new capabilities
it's easy to forget the importance of making the most of your
hardware. This project is an ode to effective resource utilitzation
and a message to programmers to take into consideration the resources
allocations their software needs.


## Running this project

This repo assumes that you have [libvirt](https://libvirt.org/) and [vagrant](https://www.vagrantup.com/)
installed, and have your machine configured to do PCIe passthrough (check references for more).

This repo is run in a *step-wise* fashion. At every step/command, the is an accompanying
verification step to ensure the step ran successfully.

### 0. Find host PCIe Nvidia GPU devices

This first step uses `lspci` to parse device data into an environment file

```shell
$ ./bin/00_host_get_gpu_devices.sh
```

You can verify that devices have been found by `cat`ing the file `PCI_GPUS.env`

```shell
$ cat ./PCI_GPUS.env
```

### 1. Install vagrant plugins.

After checking you have GPU(s) available, some `vagrant` plugins
will need to be installed to talk with `libvirt` and do some extra networking

``` shell
$ ./bin/10_host_setup_vagrant.sh
```

### 2. Bring up the VM with PCI passthrough and setup `nvidia-docker` and `cuda` inside

Once the GPU(s) have been saved and plugins installed, bring up the vagrant machine
and run the `nvidia-docker` + `cuda` setup script.

``` shell
$ source PCI_GPUS.env && vagrant up
$ vagrant ssh -c "./bin/20_guest_setup_cuda_docker.sh"
```

To test that the `nvidia-toolkit` is successfully installed, run `nvidia-smi`
in a docker container

``` shell
$ vagrant ssh -c "./bin/21_guest_test_docker_runtime.sh"
```

You should see the `nvidia-smi` table with your GPU(s) listed

### 3. Install some tools into the VM

Next the command `arkade` is needed to install some utility kubernetes based clis

``` shell
$ vagrant ssh -c "./bin/32_guest_install_arkade.sh"
```

Here are some extra tools if you feel inclined (optional)

``` shell
$ vagrant ssh -c "./bin/31_guest_install_golang.sh"
$ vagrant ssh -c "./bin/33_guest_install_docker_compose.sh"
$ vagrant ssh -c "./bin/34_guest_install_ctop.sh"
```

### 4. Setup a `k3s` cluster inside the VM

Once the tools have been installed inside the VM, `k3s` can be spun up inside the
VM. This script launches `k3s` with the `DevicePlugins` feature gate so we can interact
with the GPU from `k3s`.

``` shell
$ vagrant ssh -c "./bin/40_guest_setup_k3s_cluster.sh"
```

To verify that the cluster is up and running, check the status of all the pods for the cluster

```shell
$ vagrant ssh -c "kubectl get pods -A"
```

After ensuring that pods are being created, deploy a local registry with `docker` so images that are built locally can be accessed within the `k3s` cluster.

``` shell
$ vagrant ssh -c "./bin/41_guest_setup_docker_registry.sh"
```

Once the registry is deployed, run this script to push some base images to the
registry so they can be easily accessed throughout the cluster when running the
samples

``` shell
$ vagrant ssh -c "./bin/42_guest_push_base_images_to_registry.sh"
```

### 5. Setup `gpu-manager` on `k3s`

`gpu-manager` is an amazing projects that will let us create virtual GPUs that can be assigned to our containers  (If you want to learn more about `gpu-manager`, check out the references). This script build a fresh image of `gpu-manager`

``` shell
$ vagrant ssh -c "./bin/50_guest_setup_gpu_manager.sh"
```

Verify that `gpu-manager` has been installed correctly by running a pods with fractional resources

``` shell
$ vagrant ssh -c "./bin/51_guest_test_gpu_manager.sh"
```

If you managed to run all these steps, congratulations! You successfully created a Kubernetes cluster
with fractional GPU sharing!

### 6. Running samples

To demonstrate some of the gpu sharing capabilities, build then run the sample pods under `yml/samples/`

``` shell
$ vagrant ssh -c "./bin/60_guest_build_sample_images.sh"
```

Run each sample with some time spaced so the scheduler has time to resync

``` shell
vagrant ssh
```

Inside VM

```shell
for f in $(find yml/samples/*)
do
    kubectl apply -f $f;
    sleep 1;
done
```

You can view the memory usage of each process with `nvidia-smi`

## References

* Libvirt and PCIe passthrough

    - Github tutorial: https://github.com/bryansteiner/gpu-passthrough-tutorial
    - GrayWolfTech video tutorial: https://www.youtube.com/watch?v=dsDUtzMkxFk
    - Chris Titus Tech video tutorial: https://www.youtube.com/watch?v=3yhwJxWSqXI

* `gpu-manager`

    - Github Repo: https://github.com/tkestack/gpu-manager
    - paper: https://ieeexplore.ieee.org/abstract/document/8672318
