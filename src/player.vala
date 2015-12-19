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

    public class Player: GLib.Object {

        public signal void endfile();
        public signal void state_changed(Aond.State state);
        public signal void video_changed(bool _value);
        public signal void position_changed(double position);
        public signal void loading_buffer(int position);

        private dynamic Gst.Element player = Gst.ElementFactory.make("playbin", "play");
        private string file = "";
        private Gst.State state = Gst.State.NULL;
        private uint* xid;

        private Aond.VideoPipeline video_bin;
        private Aond.AudioPipeline audio_bin;
        private bool progressbar = false;
        private bool video = false;
        private uint updater = 0;
        private double duration = 0;
        private double position = 0;

        public Player(uint* xid) {
            this.xid = xid;
            this.player.set_property("buffer-size", 50000);

            this.audio_bin = new Aond.AudioPipeline();
            this.video_bin = new Aond.VideoPipeline();

            this.player.set_property("video-sink", this.video_bin);
            this.player.set_property("audio-sink", this.audio_bin);

            Gst.Bus bus = this.player.get_bus();
            bus.add_watch(100, this.sync_message_cb);
        }

        private bool sync_message_cb(Gst.Bus bus, Gst.Message message) {
            switch (message.type) {
                case Gst.MessageType.ELEMENT:
                    if (message.get_structure().get_name() == "prepare-window-handle") {
                        Gst.Video.Overlay overlay = message.src as Gst.Video.Overlay;
                        assert(overlay != null);
                        overlay.set_window_handle(this.xid);
                    }
                    break;

                case Gst.MessageType.STATE_CHANGED:
                    Gst.State oldstate;
                    Gst.State newstate;
                    Gst.State pending;

                    message.parse_state_changed(out oldstate, out newstate, out pending);

                    if (this.state != newstate) {
                        this.state = newstate;
                        if (oldstate == Gst.State.PAUSED && newstate == Gst.State.PLAYING) {
                            if (this.state == Gst.State.PLAYING) {
                                this.state_changed(Aond.State.PLAYING);
                                this.new_handle(true);
                            }
                        } else if (oldstate == Gst.State.READY && newstate == Gst.State.PAUSED) {
                            if (this.state == Gst.State.PAUSED) {
                                this.state_changed(Aond.State.PAUSED);
                                this.new_handle(false);
                            }
                        } else if (oldstate == Gst.State.READY && newstate == Gst.State.NULL) {
                            if (this.state == Gst.State.NULL) {
                                this.state_changed(Aond.State.NONE);
                                this.new_handle(false);
                            }
                        } else if (oldstate == Gst.State.PLAYING && newstate == Gst.State.PAUSED) {
                            if (this.state == Gst.State.PAUSED) {
                                this.state_changed(Aond.State.PAUSED);
                                this.new_handle(false);
                            }
                        }
                    }
                    break;

                case Gst.MessageType.TAG:
                    Gst.TagList taglist;
                    message.parse_tag(out taglist);
                    string data = taglist.to_string();

                    if ("video-codec" in data) {
                        if (this.video == false) {
                            this.video = true;
                            this.video_changed(this.video);
                        }
                    }
                    break;

                case Gst.MessageType.LATENCY:
                    break;

                case Gst.MessageType.ERROR:
                    GLib.Error err;
                    string debug;
                    message.parse_error(out err, out debug);
                    this.new_handle(false);
                    break;

                case Gst.MessageType.BUFFERING:
                    GLib.Value dat = message.get_structure().get_value("buffer-percent");
                    int buf = dat.get_int();
                    if (this.state == Gst.State.PLAYING) {
                        this.loading_buffer(buf);
                    }
                    break;

                case Gst.MessageType.EOS:
                    this.new_handle(false);
                    this.endfile();
                    break;
                }
                return true;
            }

        private void new_handle(bool reset) {
            if (this.updater > 0) {
                GLib.Source.remove(this.updater);
                this.updater = 0;
            }

            if (reset == true) {
                this.updater = GLib.Timeout.add(200, this.handle);
            }
        }

        private void pause() {
            this.player.set_state(Gst.State.PAUSED);
        }

        private bool handle() {
            if (!this.progressbar) {
                return true;
            }

            int64 d;
            int64 p;
            this.player.query_duration(Gst.Format.TIME, out d);
            this.player.query_position(Gst.Format.TIME, out p);

            double duration = (double)d;
            double position = (double)p;

            duration = duration / Gst.SECOND;
            position = position / Gst.SECOND;

            double pos = position * 100.0 / duration;
            if (this.duration != duration) {
                this.duration = duration;
            }

            if (pos != this.position) {
                this.position = pos;
                this.position_changed(this.position);
            }
            return true;
        }

        public void play() {
            if (this.file != "") {
                this.player.set_state(Gst.State.PLAYING);
            }
        }

        public void pause_play() {
            if (this.state == Gst.State.PAUSED || this.state == Gst.State.NULL || this.state == Gst.State.READY) {
                this.play();
            } else if (this.state == Gst.State.PLAYING) {
                this.pause();
            }
        }

        public void stop() {
            this.new_handle(false);
            this.player.set_state(Gst.State.NULL);
            this.position_changed(0);
        }

        public bool load(string uri) {
            if (uri == "") {
                return false;
            }

            this.duration = 0;
            this.position = 0;
            this.position_changed(this.position);
            this.loading_buffer(100);

            this.file = uri;
            if (GLib.FileUtils.test(uri, GLib.FileTest.IS_REGULAR)) {
                GLib.File file = GLib.File.parse_name(uri);
                this.file = file.get_uri();
                this.progressbar = true;
            } else{
                this.progressbar = false;
            }

            this.player.set_property("uri", this.file);
            return false;
        }

        public bool set_position(double position) {
            if (this.progressbar == false) {
                return false;
            }

            if (this.duration < position) {
                return false;
            }

            if (this.duration == 0 || position == 0) {
                return false;
            }

            position = this.duration * position / 100;

            // Event.seek (double rate, Format format,
            // SeekFlags flags, SeekType start_type, int64 start,
            // SeekType stop_type, int64 stop)
            Gst.Event event = new Gst.Event.seek(
                1.0, Gst.Format.TIME,
                Gst.SeekFlags.FLUSH | Gst.SeekFlags.ACCURATE,
                Gst.SeekType.SET, (int64)position * 1000000000,
                Gst.SeekType.NONE, (int64)this.duration * 1000000000);

            this.player.send_event(event);
            return true;
        }

        public void set_volumen(double volumen) {
            this.player.set_property("volume", volumen);
        }
    }
}
