# /etc/puppet/manifests/site.pp

$hostgroup = regsubst($hostname, '-*\d+$', '')
hiera_include('classes')
#import "nodes"
