class pve::profiles::config::agent (
  $consul_server
) {

  $init_style = $::initsystem ? {
    /systemd/ => 'systemd',
    default   => 'debian'
  }

  class { '::consul':
    extra_options => ' -disable-host-node-id true ',
    init_style    => $init_style,
    version       => '0.9.3',
    config_hash   => {
      'bind_addr'            => $::ipaddress_eth0,
      'data_dir'             => '/opt/consul',
      'datacenter'           => 'pve',
      'log_level'            => 'INFO',
      'node_name'            => $::hostname,
      'retry_join'           => [$consul_server],
      'enable_script_checks' => true
    }
  }

  ::consul::check { 'check_disk_usage':
    script   => '/usr/lib/nagios/plugins/check_disk -w20% -c10% -p /',
    interval => '30s'
  }

  ::consul::check { 'check_cpuload':
    script   => '/usr/lib/nagios/plugins/check_load -r -w 0.7 -c 1',
    interval => '30s'
  }

}