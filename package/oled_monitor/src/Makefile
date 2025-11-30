TARGET = oled_monitor
# On utilise ?= pour laisser Buildroot surcharger CC et CFLAGS
CC ?= gcc
CFLAGS ?= -Wall -O2
LIBS = -lncurses

SRCS = monitor_light.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(TARGET) $(OBJS) $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJS)
