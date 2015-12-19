/*
Copyright (C) 2015, Cristian García <cristian99garcia@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

namespace Aond {

    public enum State {
        PLAYING,
        PAUSED,
        NONE,
    }

    public string get_local_path() {
        GLib.Application glib_app = GLib.Application.get_default();
        AondApp app = (glib_app as AondApp);
        GLib.File folder = app.file.get_parent();
        return folder.get_path();
    }

    public Gdk.Pixbuf make_pixbuf(string icon, int size=24, bool local=false) {
        if (!local) {
            try {
                var screen = Gdk.Screen.get_default();
                var theme = Gtk.IconTheme.get_for_screen(screen);
                var pixbuf = theme.load_icon(icon, size, Gtk.IconLookupFlags.FORCE_SYMBOLIC);

                if (pixbuf.get_width() != size || pixbuf.get_height() != size) {
                    pixbuf = pixbuf.scale_simple(size, size, Gdk.InterpType.BILINEAR);
                }

                return pixbuf;
            }
            catch (GLib.Error e) {
                return new Gtk.Image().get_pixbuf();
            }
        } else {
            try {
                string name = icon;
                if (!name.has_suffix(".png")) {
                    name += ".png";
                }

                string path = GLib.Path.build_filename(get_local_path(), "data/icons/" + name);
                return new Gdk.Pixbuf.from_file_at_size(path, size, size);
            } catch (GLib.Error e) {
                return new Gtk.Image().get_pixbuf();
            }
        }
    }

    public Gtk.Image make_image(string icon, int size=24, bool local=false) {
        return new Gtk.Image.from_pixbuf(make_pixbuf(icon, size, local));
    }
}
