
#ifndef netConfigArtila_H
#define netConfigArtila_H

/*+-------------------------------------------------------------------------+*/
/*| include global headers                                                  |*/
/*+-------------------------------------------------------------------------+*/
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <syslog.h>
#include <string.h>
#include <time.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <sys/types.h>

#define DEVICE_UNKNOWN 0
#define DEVICE_ARTILA 1
#define DEVICE_SHEEVA_UBUNTU 2
#define DEVICE_SHEEVA_DEBIAN 3
#define DEVICE_RASPBERRY_PI 4

bool writeNetworkConfig();


#endif //netConfigArtila_H

