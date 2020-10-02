# -*- mode: ruby -*-
# vi: set ft=ruby :

LIBVIRT_POOL = 'fast'

GPUS = ENV.map{ |key, value|
  if key.start_with?("GPU")
    h = {}

    value.split(ENV['DELIM']).each_with_index{ |s, i|
      case i
      when 0
        # h[:domain] = s
      when 1
        h[:bus] = s
      when 2
        h[:slot] = s
      when 3
        h[:function] = s
      end
    }
    h
  else
    nil
  end
}.compact

if GPUS.length > 0
  puts "These are the passed GPUs"
  puts GPUS
else
  puts "No GPUs passed"
end

Vagrant.configure("2") do |config|
  config.vm.define "datalab" do |config|
    config.tun.enabled = true
    config.vm.hostname = "datalab"
    config.vm.box = "generic/ubuntu1604"
    config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_udp: false
    config.vm.network "private_network", ip: "192.168.18.9"
    config.vm.provider "libvirt" do |v|
      v.driver = "kvm"
      v.host = 'localhost'
      v.uri = 'qemu:///system'
      v.memory = 4096
      v.cpus = 2
      v.machine_type = "q35"
      v.cpu_mode = "host-passthrough"
      v.kvm_hidden = true

      GPUS.each { |gpu|
        v.pci :bus => gpu[:bus], :slot => gpu[:slot], :function => gpu[:function]
      }
    end
  end
end
