Operating System Fixup ISO
==========================

This repository contains the source code for the Operating System Fixup ISO.

The Operating System Fixup is an advanced hypervisor interoperability feature
included in XenCenter, which aims to ensure a basic level of interoperability
for VMs that are imported to XenServer. You will need to use Operating System
Fixup when importing VMs created on other hypervisors from OVF/OVA packages
and disk images.

Contributions
-------------

The preferable way to contribute patches is to fork the repository on Github and 
then submit a pull request. If for some reason you can't use Github to submit a 
pull request, then you may send your patch for review to the 
xs-devel@lists.xenserver.org mailing list, with a link to a public git repository 
for review. Please see the CONTRIB.md file for some general guidelines on submitting 
changes.

License
-------

This code is licensed under the BSD 2-Clause license. Please see the LICENSE
file for more information.

How to build Operating System Fixup ISO
---------------------------------------
The repository contains a Makefile, so the OS Fixup ISO can be easily built 
with the make utility.
