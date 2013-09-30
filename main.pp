class glusterfs {
  file { '/etc/sysconfig/iptables':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    source  => "$manifest_dir/dist/iptables",
    notify  => Service['iptables'],
  }

  service { 'iptables':
    name      => 'iptables',
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
  }

  service { 'glusterd':
    name      => 'glusterd',
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => Package['glusterfs_server'],
  }

  package { 'glusterfs_server':
    name   => [ 'glusterfs-server', 'glusterfs-geo-replication', 'glusterfs-fuse' ],
    ensure => installed,
  }   
}

include 'glusterfs'

