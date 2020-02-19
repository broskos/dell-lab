Name:           fpga-drivers
Version:        1.0
Release:        1%{?dist}
License: 	apache2
Summary:        load igb_uio kernel module configure 2 VFs on each FPGA
Source0:        fpga-drivers.tgz


%description
simple rpm to install the bare miminum to bring up the FPGA cards

%{?systemd_requires}
BuildRequires: systemd
BuildRequires: systemd-rpm-macros

%install
tar -xvf /root/rpmbuild/SOURCES/fpga-drivers.tgz -C $RPM_BUILD_ROOT

%files
/usr/local
/etc

%post
%systemd_post config-fpga.service
      if [ $1 -eq 1 ]; then
        /usr/bin/systemctl daemon-reload
        /usr/bin/systemctl enable --now config-fpga.service
      fi
      if [ $1 -eq 2 ]; then
        /usr/bin/systemctl daemon-reload
        /usr/bin/systemctl enable --now config-fpga.service
      fi

%preun
%systemd_preun config-fpga.service

    if [ $1 -eq 0 ]; then
      /usr/bin/systemctl --no-reload disable config-fpga.service
      /usr/bin/systemctl stop config-fpga.service >/dev/null 2>&1 ||:
      /usr/bin/systemctl disable config-fpga.service

    fi
    if [ $1 -eq 1 ]; then
      /usr/bin/systemctl --no-reload disable config-fpga.service
      /usr/bin/systemctl stop config-fpga.service
    fi

%postun
%systemd_postun_with_restart config-fpga.service
