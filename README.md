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

The preferable way to contribute is to submit your patches to the 
xs-devel@lists.xenserver.org mailing list rather than submitting pull requests. 
Please see the CONTRIB file for some general guidelines on submitting changes.

License
-------

This code is licensed under the BSD 2-Clause license. Please see the LICENSE
file for more information.

How to build Operating System Fixup ISO
---------------------------------------
The repository contains a Makefile, so the OS Fixup ISO can be easily built 
with the make utility.
