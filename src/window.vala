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

    public class Window: Gtk.ApplicationWindow {

        public AondApp app;
        public Aond.Viewer viewer;

        public Window(AondApp app) {
            this.app = app;
            this.set_application(this.app);
            this.set_title("Aond Player");

            this.viewer = new Aond.Viewer();
            this.add(this.viewer);
        }

        public void open_filechooser(string? path=null) {
            Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog(
                "Open file",
                this,
                Gtk.FileChooserAction.OPEN,
                Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
                Gtk.Stock.OPEN, Gtk.ResponseType.ACCEPT
            );

            if (chooser.run() == Gtk.ResponseType.ACCEPT) {
                string file = chooser.get_filename();
                if (!file.has_suffix("file://")) {
                    file = "file://" + file;
                }

				this.viewer.load(file);
            }

            chooser.destroy();
        }
    }
}
