nodes = {
    'keystone'  => [1, 200],
    'swift'   => [1, 210],
}

Vagrant.configure("2") do |config|
    config.vm.box = "precise64"

    nodes.each do |prefix, (count, ip_start)|
        count.times do |i|
            hostname = "%s-%02d" % [prefix, (i+1)]

            config.vm.define "#{hostname}" do |box|
                box.vm.hostname = "#{hostname}.book"
                box.vm.network :private_network, ip: "172.16.172.#{ip_start+i}", :netmask => "255.255.255.0"
                box.vm.network :private_network, ip: "172.16.200.#{ip_start+i}", :netmask => "255.255.255.0" 
                box.vm.provision :shell, :path => "#{prefix}.sh"
                box.vm.provider :vmware_fusion do |v|
                    v.vmx["memsize"] = 1024
                end
            end
        end
    end
end


