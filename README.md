qwifi-emulation
===============

Scripts and tools to configure a qwifi emulation environment

Inital Setup
===============

1. Checkout repo
2. Initialize and update FreeRADIUS configuration subrepo ("git submodule init" and "git submodule update")
3. Run "sudo make setup" to setup dependencies and configure the MySQL database.

Usage
===============

Run "sudo make emulate" to enter emulation mode. To return to normality, run "sudo make normal"
