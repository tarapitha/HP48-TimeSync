# HP48-TimeSync
HP48 calculator utility for synchronizing time over serial interface against computer Kermit server

The utility is meant to be run on the HP48 calculator. It has been tested on

- HP48SX Rev J
- HP48G Rev R
- HP48GX Rev P
- HP48GX Rev R

The utility includes currently only time synchronization. It sends command line to Kermit and expects the hexadecimal representation of TICKS as a response. HP48 TICKS epoch starts from year 0 AD, or put another way year 1 BC, January the 1st, using proleptic Gregorian calendar. Frequency is 8192 or # 2000h ticks per second.

---

Synchronizing the calculator against the computer system time:

- Connect calculator to computer via the serial interface
- Run Kermit server on the computer
- Run the provided utility on your calculator, choose *tsync* for Linux and *win_tsync* for MS Windows

Official HP Tools were used for compiling the binaries.

Only binary for Linux has been properly tested. The win_tsync was tested, using 'pwsh -C "*command*"' with Linux C-Kermit.

**NB! As there are strong security concerns connected to this utility, it runs the command on your computer, then compiling from the source is strongly suggested. Run the binaries if you are brave enough. Linux C-Kermit reports on the screen the commands it is executing.**
