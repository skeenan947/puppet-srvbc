class role::dnsmasq {
  include dnsmasq
  $domains = hiera_hash('dnsmasq::domains',{})
  create_resources('dnsmasq::domain',$domains)
  $dhcp_ranges = hiera_hash('dnsmasq::dhcp',{})
  create_resources('dnsmasq::dhcp',$dhcp_ranges)
}
