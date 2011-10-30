Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '384', 
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'Ubuntu',
  :iso_file => "ubuntu-11.04-server-i386.iso",
  :iso_src => "http://releases.ubuntu.com/11.04/ubuntu-11.04-server-i386.iso",
  :iso_md5 => "ce1cee108de737d7492e37069eed538e",
  :iso_download_timeout => "1000",
  :boot_wait => "1", :boot_cmd_sequence => [
    '<Esc><Esc><Enter>',
    '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    'debian-installer=de_DE auto locale=de_DE kbd-chooser/method=de ',
    'hostname=%NAME% ',
    'fb=false debconf/frontend=noninteractive ',
    'keyboard-configuration/layout=DE keyboard-configuration/variant=DE console-setup/ask_detect=false ',
    'initrd=/install/initrd.gz -- <Enter>'
  ],
  :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "deploy", :ssh_password => nil, :ssh_key => "",
  :ssh_host_port => "2222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => "10000"
})
