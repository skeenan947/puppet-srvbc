# /etc/puppet/manifests/nodes.pp

node base {
   include ssh
   include ntp
}

node ubuntubase inherits base {
   include apt
}

node 'puppet', 'puppet.ops.srvbc.net' inherits 'ubuntubase' {
   class {'dashboard':
     dashboard_ensure       => 'present',
     dashboard_user         => 'www-data',
     dashboard_group        => 'www-data',
     dashboard_password     => 'netday',
     dashboard_db           => 'dashboard_prod',
     dashboard_charset      => 'utf8',
     dashboard_site         => $fqdn,
     dashboard_port         => '8080',
     mysql_root_pw          => 'sRv4gYf#',
     passenger              => true,
   }
   include dashboard
}
node 'srvbc01', 'srvbc01.ops.srvbc.net' inherits 'ubuntubase' {
 class { 'openstack::all':
   public_address         => '192.168.1.200',
   public_interface       => br100,
   private_interface      => br100,
   bridge_interface       => br100,
   internal_address       => '192.168.1.210',
   mysql_root_password    => 'sRv4gYf#',
   allowed_hosts          => ['127.0.0.%', '192.168.1.%'],
   admin_email            => 'skeenan@gmail.com',
   admin_password         => 'netday',
   keystone_db_password   => 'changeme',
   keystone_admin_token   => '12345',
   glance_db_password     => 'changeme',
   glance_user_password   => 'changeme',
   nova_db_password       => 'changeme',
   nova_user_password     => 'changeme',
   secret_key             => 'dummy_secret_key',
   cinder_user_password   => 'changeme',
   cinder_db_password     => 'changeme',
   rabbit_password        => 'changeme',
   neutron_user_password  => 'changeme',
   neutron_db_password    => 'changeme',
   metadata_shared_secret => 'shared_md_secret',
   fixed_range            => '10.1.1.0/24',
   multi_host             => true,
   enable_ovs_agent       => true,
 }

   include openstack::all
}
