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

    public class Viewer: Gtk.DrawingArea {

        public signal void hide_controls(bool valor);
        public signal void player_created(Aond.Player player);

        public uint* xid;
        public Aond.Player player;

        public Viewer() {

            this.add_events(
                Gdk.EventMask.KEY_PRESS_MASK |
                Gdk.EventMask.KEY_RELEASE_MASK |
                Gdk.EventMask.POINTER_MOTION_MASK |
                Gdk.EventMask.POINTER_MOTION_HINT_MASK |
                Gdk.EventMask.BUTTON_MOTION_MASK |
                Gdk.EventMask.BUTTON_PRESS_MASK |
                Gdk.EventMask.BUTTON_RELEASE_MASK
            );

            this.realize.connect(this.realize_cb);
            this.motion_notify_event.connect(this.motion_cb);

            this.show_all();
        }

        private void realize_cb() {
            this.xid = (uint*)Gdk.X11Window.get_xid(this.get_window());
            this.player = new Aond.Player(this.xid);
            this.player_created(this.player);
        }

        private bool motion_cb(Gdk.EventMotion event){
            //Gtk.Allocation alloc;
            //this.get_allocation(out alloc);

            //int x = (int)event.x;
            //int y = (int)event.y;
            //int ww = alloc.width;
            //int hh = alloc.height;

            //int minw = ww - 60;
            //int minh = hh - 60;

            //if ((x > minw && x < ww) || (y > 0 && y < 60) || (y < hh && y > minh)){
            //    this.hide_controls(false);
            //} else {
            //    this.hide_controls(true);
            //}

            return false;
        }

        public void load(string path) {
            this.player.load(path);
            this.player.play();
        }
    }
}
