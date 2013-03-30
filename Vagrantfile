nodes = {
    'controller'  => [1, 200],
    'compute'  => [1, 201],
    'swift'   => [1, 210],
}

Vagrant.configure("2") do |config|
    config.vm.box = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"

    nodes.each do |prefix, (count, ip_start)|
        count.times do |i|
            hostname = "%s-%02d" % [prefix, (i+1)]

            config.vm.define "#{hostname}" do |box|
                box.vm.hostname = "#{hostname}.book"
                box.vm.network :private_network, ip: "172.16.172.#{ip_start+i}", :netmask => "255.255.255.0"
                box.vm.network :private_network, ip: "172.16.200.#{ip_start+i}", :netmask => "255.255.255.0" 

	        box.vm.provision :shell, :path => "#{prefix}.sh"

                # If using Fusion
                box.vm.provider :vmware_fusion do |v|
                    v.vmx["memsize"] = 1024
                    if prefix == "swift"
                        v.gui = true
                    end
                end
                # Otherwise using VirtualBox
                box.vm.provider :virtualbox do |vbox|
		    # Default to 1Gb RAM
                    vbox.customize ["modifyvm", :id, "--memory", 2048]
		    if prefix == "compute"
                    	vbox.customize ["modifyvm", :id, "--memory", 3127]
		    end
                end
            end
        end
    end
end


