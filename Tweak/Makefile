TWEAK_NAME = BatteryBuddy
$(TWEAK_NAME)_FILES = $(shell find Sources/BatteryBuddy -name '*.swift') $(shell find Sources/BatteryBuddyC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
$(TWEAK_NAME)_SWIFTFLAGS = -ISources/BatteryBuddyC/include
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DTHEOS_LEAN_AND_MEAN
$(TWEAK_NAME)_FRAMEWORKS = UIKit

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
