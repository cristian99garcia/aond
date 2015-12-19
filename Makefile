VALAC = valac

PKG = --pkg gtk+-3.0 \
      --pkg gstreamer-1.0 \
      --pkg gstreamer-video-1.0 \
      --pkg gdk-x11-3.0

SRC = src/aond.vala \
      src/controls.vala \
      src/headerbar.vala \
      src/pipelines.vala \
      src/player.vala \
      src/utils.vala \
      src/viewer.vala \
      src/window.vala

OPTIONS = --ignore-warnings

BIN = aond

all:
	$(VALAC) $(PKG) $(SRC) -o $(BIN)

