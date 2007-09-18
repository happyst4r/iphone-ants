#include <signal.h>
#include <kvm.h>
#include <fcntl.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#import <UIKit/UIKit.h>
#import "AntsControllerApp.h"

int main(int argc, char **argv)
{
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
     return UIApplicationMain(argc, argv, [AntsControllerApp class]);
} 
