# Copyright 2024, Durable Programming, LLC. All rights reserved.
# See LICENSE for license details.

%define name mysql-change-database-encoding
%define version %{getenv:VERSION}
%define release 1

Name:           %{name}
Version:        %{version}
Release:        %{release}%{?dist}
Summary:        Tool for changing a database's encoding, collation, or both
License:        GPLv3
URL:            https://github.com/durableprogramming/mysql_change_database_encoding
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
BuildRequires:  ruby >= 2.7
Requires:       ruby >= 2.7
Requires:       rubygem-mysql2
Requires:       rubygem-activerecord
Requires:       rubygem-ptools

%description
Tool for changing a database's encoding, collation, or both. Supports online 
schema change via pt-online-schema-change with configurable fallback.

%prep
%setup -q

%build
# No compilation needed for Ruby scripts

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/%{name}
mkdir -p %{buildroot}%{_datadir}/%{name}/lib
mkdir -p %{buildroot}%{_mandir}/man1

# Install main script
install -m 755 mysql_change_database_encoding.rb %{buildroot}%{_bindir}/mysql-change-database-encoding

# Install library files
cp -r lib/* %{buildroot}%{_datadir}/%{name}/lib/

# Install documentation
install -m 644 README.md %{buildroot}%{_datadir}/%{name}/
install -m 644 LICENSE %{buildroot}%{_datadir}/%{name}/

%files
%{_bindir}/mysql-change-database-encoding
%{_datadir}/%{name}
%doc %{_datadir}/%{name}/README.md
%license %{_datadir}/%{name}/LICENSE

%changelog
* %(date "+%a %b %d %Y") Package Builder <builder@durableprogramming.com> - %{version}-%{release}
- Automated build for version %{version}