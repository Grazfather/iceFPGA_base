PROJ = base
ADD_SRC = src/top.v
TOPMODULE = top

# Icebreaker
PIN_DEF = syn/icebreaker.pcf
DEVICE = up5k
PACKAGE = sg48

# Icestick
#PIN_DEF = syn/icestick.pcf
#DEVICE = hx1k
#PACKAGE = tq144

include main.mk
