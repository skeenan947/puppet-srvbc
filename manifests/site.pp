# /etc/puppet/manifests/site.pp

$hostgroup = regsubst($::clientcert, '-.*$', '')
hiera_include('classes')
#import "nodes"
