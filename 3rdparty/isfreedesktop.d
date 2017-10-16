/**
 * $(B isFreedesktop) is compile-time constant to test if target platform desktop environments usually follow freedesktop specifications.
 * Currently Linux, all *BSD and Hurd are considered to be freedesktop-compatible, hence isFreedesktop is evaluated to true on these platforms.
 * This guess is somewhat optimistic, since there are vendor-specific operating systems based on these kernels in the world while their desktops don't implement freedesktop specifications.
 * Authors: 
 *  $(LINK2 https://github.com/FreeSlave, Roman Chistokhodov)
 * Copyright:
 *  Roman Chistokhodov, 2016
 * License: 
 *  $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 */

module isfreedesktop;

version(OSX) {
    enum isFreedesktop = false;
} else version(Android) {
    enum isFreedesktop = false;
} else version(linux) {
    enum isFreedesktop = true;
} else version(FreeBSD) {
    enum isFreedesktop = true;
} else version(OpenBSD) {
    enum isFreedesktop = true;
} else version(NetBSD) {
    enum isFreedesktop = true;
} else version(DragonFlyBSD) {
    enum isFreedesktop = true;
} else version(BSD) {
    enum isFreedesktop = true;
} else version(Hurd) {
    enum isFreedesktop = true;
} else version(Solaris) {
    enum isFreedesktop = true;
} else {
    enum isFreedesktop = false;
}
