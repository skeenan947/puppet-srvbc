# /etc/puppet/manifests/nodes.pp

node base {
   include ssh
   include ntp
}

node ubuntubase inherits base {
   include apt
}

node puppet.ops.srvbc.net inherits ubuntubase {
   include dashboard
}
