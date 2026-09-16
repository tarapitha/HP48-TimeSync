# HP48-TimeSync
HP48 calculator utility for synchronizing time over serial interface against computer Kermit server

The utility is meant to be run on the HP48 calculator. It has been tested on

- HP48SX Rev J
- HP48G Rev R
- HP48GX Rev P
- HP48GX Rev R

The utility includes currently only time synchronization. It sends command line to Kermit and expects the hexadecimal representation of TICKS as a response. HP48 TICKS epoch starts from year 0 AD, or put another way year 1 BC, January the 1st, using proleptic Gregorian calendar. Frequency is 8192 or # 2000h ticks per second.

Windows binary expects Kermit to use PowerShell as a default (SET SHELL powershell.exe).

---

Binaries:

| Utility   | Platform   | SHA-256                                                          |
|-----------|------------|------------------------------------------------------------------|
| tsync     | Linux      | 6e29f1e20283f98893bfd0fd5c3910596ac18235f0a9d8cef22e0d515ca9d42a |
| win_tsync | MS Windows | 723ab4f06626d1aa8291ede8619ef74738e3da66198ac604bf530ee0885530a1 |

---

To synchronize the calculator against the computer system time:

- Create variable 'TZ' in the calculator HOME directory. This should contain time shift in hours from UTC as a real number. UTC is assumed by default when the variable is not present 
- Connect calculator to computer via the serial interface
- Run Kermit server on the computer
- Run the provided utility on your calculator, choose *tsync* for Linux and *win_tsync* for MS Windows

Official HP Tools were used for compiling the binaries.

Only binary for Linux has been properly tested.

> [!WARNING]
> **Security Notice:** This utility requests the time by executing a shell command on your computer via the Kermit server. To eliminate any risk of a modified binary acting as an attack vector, **compiling from the source is strongly recommended.** 
> 
> If you choose to run the pre-compiled binaries, please:
> 1. Verify the file integrity using the provided **SHA-256 checksums**.
> 2. Avoid running the Kermit server with root/administrator privileges.
> 
> *Note for Linux users:* C-Kermit logs executed commands directly to the screen, allowing you to monitor the active requests.
