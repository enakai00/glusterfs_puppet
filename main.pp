import 'variables.pp'

class glusterfs {
  ssh_authorized_key { 'vmhost01_key':
    name   => 'root@192.168.122.1',
    ensure => 'present',
    user   => 'root',
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA5W2IynhVezp+DpN11xdsY/8NOqeF8r7eYqVteeWZSBfnYhKn8D85JmByBQnJ7HrJIrdMvfTYwWxi+swfFlryG3A+oSll0tT71FLAWnAYz26ML3HccyJ7E2bD66BSditbDITKH3V66oN9c3rIEXZYQ3A+GEiA1cFD++R0FNKxyBOkjduycvksB5Nl9xb3k6z4uoZ7JQD5J14qnooM55Blmn2CC2/2KlapxMi0tgSdkdfnSSxbYvlbztGiF3M4ey7kyuWwhE2iPBwkV/OhANl3nwHidcNdBrAGC3u78aTtUEwZtNUqrevVKM/yUfRRyPRNivuGOkvjTDUL/9BGquBX9Q==',
  }

  yumrepo { 'glusterfs_repo':
    name     => 'glusterfs',
    descr    => 'Repository for GlusterFS 3.3',
    baseurl  => 'http://download.gluster.org/pub/gluster/glusterfs/3.3/LATEST/EPEL.repo/epel-6Server/x86_64/',
    enabled  => '1',
    gpgcheck => '0',
    before   => Package['glusterfs_server'],
  }

  exec { 'mkfs_data':
    path      => '/sbin',
    command   => "mkfs.ext4 -I 512 $data_device",
    unless    => "tune2fs -l $data_device",
    logoutput => true,
    before    => Mount['data_dir'],
  }

  file { '/data':
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    ensure => directory,
    before => Mount['data_dir'],
  }

  mount { 'data_dir':
    name    => '/data',
    options => 'defaults',
    device  => $data_device,
    fstype  => 'ext4',
    ensure  => 'mounted',
  } 

  file { '/etc/sysconfig/iptables':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    source  => "$manifest_dir/dist/iptables",
    notify  => Service['iptables'],
  }

  service { 'iptables':
    name      => 'iptables',
###    ensure    => 'running',
    enable    => true,
    hasstatus => true,
  }

  service { 'rpcbind':
    name      => 'rpcbind',
###    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => Package['nfstools'],
  }

  service { 'glusterd':
    name      => 'glusterd',
###    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => Package['glusterfs_server'],
  }

  package { 'nfstools':
    name   => [ 'rpcbind', 'nfs-utils' ],
    ensure => installed,
  }   

  package { 'glusterfs_server':
    name   => [ 'glusterfs-server', 'glusterfs-geo-replication', 'glusterfs-fuse' ],
    ensure => installed,
  }   
}

include 'glusterfs'
