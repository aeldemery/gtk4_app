/*
 * File: Gtk4App.vala
 * Created Date: Sunday May 31st 2020
 * Author: Ahmed Eldemery
 * Email: aeldemery.de@gmail.com
 * ---------
 * MIT License
 *
 * Copyright (c) 2020 Ahmed Eldemery
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

namespace Gtk4AppDemo {
    public class Gtk4App : Gtk.Application {

        // Member variables
        // Gtk4AppDemo.MainWindow main_win;

        public const GLib.ActionEntry[] action_entries = {
            { "preferences", preferences_activated },
            { "quit", quit_activated }
        };
        public const string[] QUIT_ACCEL = { "<Ctrl>Q" };


        construct {
        }

        public Gtk4App () {
            Object (application_id: "github.aeldemery.gtk4_app",
                    flags : ApplicationFlags.HANDLES_OPEN);
        }

        protected override void activate () {
            var main_win = this.active_window as Gtk4AppDemo.MainWindow;
            if (main_win == null) {
                main_win = new Gtk4AppDemo.MainWindow (this);
            }
            main_win.present ();
        }

        protected override void open (GLib.File[] files, string hint) {
            var main_win = this.active_window as Gtk4AppDemo.MainWindow;
            if (main_win == null) {
                main_win = new Gtk4AppDemo.MainWindow (this);
            }
            foreach (var file in files) {
                main_win.open_file (file);
            }
            main_win.present ();
        }

        protected override void startup () {
            set_accels_for_action ("app.quit", QUIT_ACCEL);
            add_action_entries (action_entries, this);

            base.startup ();
        }

        void preferences_activated (SimpleAction action, Variant ? variant) {
            var main_win = this.active_window as Gtk4AppDemo.MainWindow;
            if (main_win == null) {
                main_win = new Gtk4AppDemo.MainWindow (this);
            }
            var preferences_dialog = new PreferencesDialog (main_win);
            preferences_dialog.present ();
        }

        void quit_activated (SimpleAction action, Variant ? variant) {
            this.quit ();
        }

        public static int main (string[] args) {
            var gtk4_app_demo = new Gtk4AppDemo.Gtk4App ();
            return gtk4_app_demo.run (args);
        }
    }
}
