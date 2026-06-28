/* This file intentionally re-exports Classes/packageManagement.h
 * so that #import "packageManagement.h" works regardless of
 * whether -I$(THEOS_PROJECT_DIR) or -I$(THEOS_PROJECT_DIR)/Classes
 * is searched first.
 */
#import "Classes/packageManagement.h"
