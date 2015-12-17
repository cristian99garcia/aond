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

    public class VideoPipeline: Gst.Pipeline {

        public double saturacion = 50.0;
        public double contraste = 50.0;
        public double brillo = 50.0;
        public double hue = 50.0;
        public double gamma = 10.0;
        public double rotacion = 0;

        public VideoPipeline() {
            this.set_name("aond_video_pipeline");

            Gst.Element convert = Gst.ElementFactory.make("videoconvert", "videoconvert");
            Gst.Element rate = Gst.ElementFactory.make("videorate", "rate");
            Gst.Element videobalance = Gst.ElementFactory.make("videobalance", "videobalance");
            Gst.Element gamma = Gst.ElementFactory.make("gamma", "gamma");
            Gst.Element videoflip = Gst.ElementFactory.make("videoflip", "videoflip");
            Gst.Element screen = Gst.ElementFactory.make("xvimagesink", "screen");
            screen.set_property("force-aspect-ratio", true);

            this.add(convert);
            this.add(rate);
            this.add(videobalance);
            this.add(gamma);
            this.add(videoflip);
            this.add(screen);

            convert.link(rate);
            rate.link(videobalance);
            videobalance.link(gamma);
            gamma.link(videoflip);
            videoflip.link(screen);

            Gst.GhostPad ghost_pad = new Gst.GhostPad("sink", convert.get_static_pad("sink"));
            ghost_pad.set_target(convert.get_static_pad("sink"));
            this.add_pad(ghost_pad);
        }
    }

    public class AudioPipeline: Gst.Pipeline{

        public AudioPipeline() {

            this.set_name("aond_audio_pipeline");

            Gst.Element convert = Gst.ElementFactory.make("audioconvert", "convert");
            Gst.Element sink = Gst.ElementFactory.make("autoaudiosink", "sink");

            this.add(convert);
            this.add(sink);

            convert.link(sink);

            Gst.GhostPad ghost_pad = new Gst.GhostPad("sink", convert.get_static_pad("sink"));
            ghost_pad.set_target(convert.get_static_pad("sink"));
            this.add_pad(ghost_pad);
        }
    }
}
