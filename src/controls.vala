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

    public class ProgressBar: Gtk.DrawingArea {

        public signal void progress_changed(int progress);

        private double _progress = 0;
        private double _pre_progress = 0;
        private double _max_value = 100.0;
        private double[] _color = { 1, 0, 0 };
        private double[] _pre_color = { 0, 0, 1 };

        public bool mouse_pressed = false;
        public bool mouse_in = false;
        public Aond.Player player;
        //public Gtk.Popover popover;
        //public Gtk.Image image;

        public ProgressBar() {
            this.set_size_request(1, 10);

            //this.popover = new Gtk.Popover(this);
            //this.popover.set_border_width(8);
            //this.popover.set_can_focus(false);

            //this.image = Aond.make_image("image-missing", 75);
            //this.popover.add(this.image);

            this.add_events(Gdk.EventMask.POINTER_MOTION_MASK |
                            Gdk.EventMask.BUTTON_PRESS_MASK |
                            Gdk.EventMask.BUTTON_RELEASE_MASK |
                            Gdk.EventMask.ENTER_NOTIFY_MASK |
                            Gdk.EventMask.LEAVE_NOTIFY_MASK);

            this.motion_notify_event.connect(this.motion_notify_cb);
            this.button_press_event.connect(this.button_press_cb);
            this.button_release_event.connect(this.button_release_cb);
            this.enter_notify_event.connect(this.enter_cb);
            this.leave_notify_event.connect(this.leave_cb);
            this.draw.connect(this.draw_cb);
        }

        private bool motion_notify_cb(Gtk.Widget self, Gdk.EventMotion event) {
            //this.make_popover_at((int)event.x);
            Gtk.Allocation alloc;
            this.get_allocation(out alloc);

            int width = alloc.width;

            int p = (int)((double)this.max_value / (double) width * event.x);
            if (this.mouse_pressed) {
                this.progress_changed(p);
                this.progress = p;
                this.pre_progress = 0;
            } else {
                this.pre_progress = p;
            }

            return false;
        }

        private bool button_press_cb(Gtk.Widget self, Gdk.EventButton button) {
            this.mouse_pressed = true;
            this.update();
            return false;
        }

        private bool button_release_cb(Gtk.Widget self, Gdk.EventButton button) {
            this.mouse_pressed = false;
            this.update();
            return false;
        }

        private bool enter_cb(Gtk.Widget self, Gdk.EventCrossing event) {
            this.mouse_in = true;
            this.update();
            return false;
        }

        private bool leave_cb(Gtk.Widget self, Gdk.EventCrossing event) {
            this.pre_progress = 0;
            this.mouse_in = false;
            return false;
        }

        private bool draw_cb(Gtk.Widget self, Cairo.Context context) {
            if (this.max_value <= 0) {
                return false;
            }

            Gtk.Allocation alloc;
            this.get_allocation(out alloc);

            int width = alloc.width;
            int height = alloc.height;
            double progress_width = (double)width / this.max_value * this.progress;
            double pre_progress_width = (double)width / this.max_value * this.pre_progress;

            int real_height = height;
            int y = 0;
            if (!this.mouse_in && !this.mouse_pressed) {
                real_height = height / 2;
                y = real_height / 2;
            }

            context.set_source_rgb(0, 0, 0);
            context.rectangle(0, y, width, real_height);
            context.fill();

            if (this.progress > 0) {
                context.set_source_rgb(this.color[0], this.color[1], this.color[2]);
                context.rectangle(0, y, progress_width, real_height);
                context.fill();
            }

            if (this.pre_progress > 0) {
                context.set_source_rgb(this.pre_color[0], this.pre_color[1], this.pre_color[2]);
                context.rectangle(0, y, pre_progress_width, real_height);
                context.fill();
            }

            return false;
        }

        public double progress {
            get { return this._progress; }
            set {
                this._progress = value;
                this.update();
            }
        }

        public double pre_progress {
            get { return this._pre_progress; }
            set {
                this._pre_progress = value;
                this.update();
            }
        }

        public double max_value {
            get { return this._max_value; }
            set {
                this._max_value = value;
                this.update();
            }
        }

        public double[] color {
            get { return this._color; }
            set {
                this._color = value;
                this.update();
            }
        }

        public double[] pre_color {
            get { return this._pre_color; }
            set {
                this._pre_color;
                this.update();
            }
        }

        public void set_player(Aond.Player player) {
            this.player = player;
            this.player.position_changed.connect((p) => {
                this.progress = p;
                this.update();
            });
        }

        public void make_popover_at(int x) {
            Gtk.Allocation alloc;
            this.get_allocation(out alloc);

            Gdk.Rectangle rect = Gdk.Rectangle();
            rect.x = x - 1;
            rect.y = alloc.height / 2 - 1;
            rect.width = 2;
            rect.height = 2;

            //this.popover.set_pointing_to(rect);
            //this.popover.show_all();
        }

        public void update() {
            GLib.Idle.add(() => {
                this.queue_draw();
                return false;
            });
        }
    }

    public class Controls: Gtk.Box {

        public Aond.Player player;
        public Aond.ProgressBar bar;

        public Controls() {
            this.set_orientation(Gtk.Orientation.VERTICAL);
            this.set_size_request(40, 40);
            this.set_halign(Gtk.Align.FILL);
            this.set_valign(Gtk.Align.END);

            this.bar = new Aond.ProgressBar();
            this.pack_start(this.bar, false, false, 0);

            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            this.pack_start(box, true, true, 0);
        }

        public void set_player(Aond.Player player) {
            this.player = player;
            this.bar.set_player(this.player);
        }
    }
}
