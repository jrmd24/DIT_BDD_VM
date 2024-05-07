# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

#Importing the module json 
require "json"

#Opening the File named "file_name.json"
conf_file = open("mongo_vm_conf.json")

#Reading the contents from the file 
opened_conf_file = conf_file.read 

#Parsing the json  contents 
parsed_conf = JSON.parse(opened_conf_file)

#Printing the contents 
puts parsed_conf

 

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.

#Itearting over each elements in the JSON String 
  parsed_conf.each do |machine|
    machineName = machine['name']
    machineIp = machine['ip']
    config.vm.define "#{machineName}" do |mongo_vm|
      
      mongo_vm.vm.box = "ubuntu/jammy64"
      #mongo_vm.vm.box = "ubuntu/bionic64"
      
      
      mongo_vm.disksize.size = '10GB'
      
      mongo_vm.vm.hostname = machineName

      mongo_vm.vm.network "private_network", ip: machineIp
      #mongo_vm.vm.network "forwarded_port", guest: 22, host: 12122, id: "ssh"



      mongo_vm.vm.provider "virtualbox" do |vb|
        #   # Display the VirtualBox GUI when booting the machine
          vb.gui = true
          vb.name=machineName
          vb.cpus = "1" 
          vb.memory = "2048"
        end

        #, before: "vm_mongo"
        mongo_vm.vm.provision "vm_simple_#{machineName}", type: "shell", path: "vm_simple.sh", env: { 'ENABLE_ZSH' => true }

        mongo_vm.vm.provision "mongo_keyfile_#{machineName}", type:"file", source: "mongo_keyfile.txt", destination: "$HOME/"
        #mongo_vm.vm.provision "file", source: "app_index.html", destination: "$HOME/app_index.html"
        #, before: "vm_mongo_storage"
        mongo_vm.vm.provision "vm_mongo_#{machineName}", type: "shell", path: "vm_mongodb.sh", env: { 'ENABLE_ZSH' => true }
        
        dbStorageRootDir = machine['dbStorageRootPath']
        # before: "mongodb_conf",
        mongo_vm.vm.provision "vm_mongo_storage_#{machineName}", type: "shell", inline: <<-SHELL
            
            if [ -d "#{dbStorageRootDir}" ]; then
              echo "'#{dbStorageRootDir}' found"
            else
              sudo mkdir #{dbStorageRootDir}
            fi

            sudo mv /home/vagrant/mongo_keyfile.txt #{dbStorageRootDir}/mongo_keyfile.txt
            sudo chmod 400 #{dbStorageRootDir}/mongo_keyfile.txt
            sudo chown mongodb:mongodb #{dbStorageRootDir}/mongo_keyfile.txt
        SHELL
#cfg={_id: "r2", members:[{_id:0, host: "127.0.0.1:29906"},{_id:1,host: "127.0.0.1:29907"}]}
        cfg={}
        cfg['_id']= machine['mongodbs'][0]['replSet']
        
        members = []
        member_id = 0
         machine['mongodbs'].each do |mongodb|
            mongoName = mongodb['name']
            replSetName = mongodb['replSet']
            mongoType = mongodb['type']
            mongoPort = mongodb['port']
            mongoConfFilePrefix = mongodb['configFilePrefix']
            mongoDbRootFolder = "#{dbStorageRootDir}/#{mongoName}"
            mongoDbDataFolder = "#{mongoDbRootFolder}/data"
            mongoDbConfigfile = "#{mongoDbRootFolder}/#{mongoConfFilePrefix}#{mongoPort}.log"

            mongo_vm.vm.provision "mongodb_conf_#{machineName}_#{mongoName}", type: "shell", run: "always", inline: <<-SHELL
                
              if [ -d "#{mongoDbRootFolder}" ]; then
                echo "'#{mongoDbRootFolder}' found"
              else
                sudo mkdir #{mongoDbRootFolder}
              fi

              if [ -d "#{mongoDbDataFolder}" ]; then
                echo "'#{mongoDbDataFolder}' found"
              else
                sudo mkdir #{mongoDbDataFolder}
              fi
              
              sudo mongod --replSet #{replSetName} --port #{mongoPort} #{mongoType} --dbpath "#{mongoDbDataFolder}" --logpath "#{mongoDbConfigfile}" --transitionToAuth --keyFile #{dbStorageRootDir}/mongo_keyfile.txt --bind_ip_all --logappend --fork
              
              #sudo mongosh --port #{mongoPort} admin --eval 'db.createUser({ user: "mongoadmin", pwd: "ditpass", roles: [{ role: "userAdminAnyDatabase", db: "admin" }, { role: "readWriteAnyDatabase", db: "admin" }] })'

            SHELL

            
            current_member = {}
            current_member['_id']= member_id
            current_member['host']= "#{machineIp}:#{mongoPort}"
            members.append(current_member)
            member_id = member_id + 1
        end

        cfg['members'] = members

        mongo_vm.vm.provision "replset_conf_#{machineName}", type: "shell", run: "once", inline: <<-SHELL
                            
           sudo mongosh --port #{machine['mongodbs'][0]['port']}  admin --eval 'rs.initiate(#{cfg.to_json})'

        SHELL
        #mongo_vm.vm.provision "file", source: "prometheus.yml", destination: "$HOME/prometheus.yml"
        #mongo_vm.vm.provision "shell", path: "vm_node_monitoring.sh", env: { 'ENABLE_ZSH' => true }
        #mongo_vm.vm.provision "shell", path: "vm_apache_monitoring.sh", env: { 'ENABLE_ZSH' => true }
        #mongo_vm.vm.provision "shell", path: "vm_monitoring.sh", env: { 'ENABLE_ZSH' => true }

    end
  end
end
