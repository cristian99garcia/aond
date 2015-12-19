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

public class AondApp: Gtk.Application {

    public GLib.List<Aond.Window> windows;
    public GLib.File file;

    public AondApp(string path) {
        GLib.Object(application_id: "org.desktop.aond");
        this.file = GLib.File.new_for_commandline_arg(path);
    }

    protected override void activate() {
        this.windows = new GLib.List<Aond.Window>();
        this.make_actions();
        this.new_window();
    }

    private void make_actions() {
        GLib.SimpleAction action = new GLib.SimpleAction("open-filechooser", null);
	    this.add_action(action);
        this.add_accelerator(Gtk.accelerator_name(Gdk.Key.o, Gdk.ModifierType.CONTROL_MASK), "app.open-filechooser", null);
	    action.activate.connect((variant) => {
	        this.open_filechooser();
	    });
    }

    public Aond.Window get_current_window() {
        Gtk.Window win = this.get_active_window();
        return (win as Aond.Window);
    }

    public void new_window() {
        Aond.Window win = new Aond.Window(this);
        this.windows.append(win);

        win.show_all();
    }

    public void open_filechooser(string? path=null) {
        Aond.Window win = this.get_current_window();
        win.open_filechooser();
    }
}

void main(string[] args) {
    Gst.init(ref args);
    var aond = new AondApp(args[0]);
    aond.run();
}
