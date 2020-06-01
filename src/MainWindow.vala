/*
 * File: MainWindow.vala
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

    [GtkTemplate (ui = "/github/aeldemery/gtk4_app/main-window.ui")]
    public class MainWindow : Gtk.ApplicationWindow {

        private MenuModel app_menu;
        private GLib.Settings settings;
        private Gtk.ScrolledWindow scrolled_window;
        private Gtk.TextView text_view;

        // Member variables
        [GtkChild]
        private Gtk.Stack stack;
        [GtkChild]
        private Gtk.MenuButton gears;
        [GtkChild]
        private Gtk.SearchBar searchbar;
        [GtkChild]
        private Gtk.ToggleButton search_button;

        construct {
            var builder = new Gtk.Builder.from_resource ("/github/aeldemery/gtk4_app/gears-menu.ui");
            app_menu = builder.get_object ("app-menu") as GLib.MenuModel;
            assert_nonnull (app_menu);
            gears.set_menu_model (app_menu);

            settings = new GLib.Settings ("github.aeldemery.gtk4_app");
            settings.bind ("transition", stack, "transition-type", GLib.SettingsBindFlags.DEFAULT);
            search_button.bind_property ("active", searchbar, "search-mode-enabled", BindingFlags.BIDIRECTIONAL);
        }

        public MainWindow (Gtk.Application app) {
            Object (application: app);
            // if ((this as Gtk.Widget) != null) {
            // set_template_from_resource ("/github/aeldemery/gtk4_app/ui/main_window.ui");
            // init_template ();
            // }
        }

        void init_ui () {
            scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.hexpand = true;
            scrolled_window.vexpand = true;

            text_view = new Gtk.TextView ();
            text_view.editable = false;
            text_view.cursor_visible = false;

            scrolled_window.set_child (text_view);
        }

        public void open_file (File file) {
            init_ui ();
            var file_basename = file.get_basename ();
            stack.add_titled (scrolled_window, file_basename, file_basename);

            try {
                uint8[] contents = null;
                string etag_out;
                if (file.load_contents (null, out contents, out etag_out)) {
                    text_view.buffer.text = (string) contents;
                }
            } catch (Error e) {
                message ("Can't open file" + e.message);
            }

            var tag = text_view.buffer.create_tag (null);
            var start_iter = Gtk.TextIter ();
            var end_iter = Gtk.TextIter ();
            settings.bind ("font", tag, "font", SettingsBindFlags.DEFAULT);
            text_view.buffer.get_start_iter (out start_iter);
            text_view.buffer.get_end_iter (out end_iter);
            text_view.buffer.apply_tag (tag, start_iter, end_iter);

            search_button.sensitive = true;
        }

        [GtkCallback]
        void search_text_changed (Gtk.SearchEntry entry) {
            if (entry.text == "") {
                return;
            }
            var tab = (Gtk.ScrolledWindow)stack.visible_child;
            var view = (Gtk.TextView)tab.get_first_child ();
            var buffer = view.get_buffer ();

            var start_iter = Gtk.TextIter ();
            var match_start = Gtk.TextIter ();
            var match_end = Gtk.TextIter ();

            buffer.get_start_iter (out start_iter);
            if (start_iter.forward_search (
                    entry.text, Gtk.TextSearchFlags.CASE_INSENSITIVE, out match_start, out match_end, null
                )) {
                buffer.select_range (match_start, match_end);
                view.scroll_to_iter (match_start, 0, false, 0, 0);
            }
        }

        [GtkCallback]
        void visible_child_changed (GLib.Object object, ParamSpec pspec) {
            searchbar.search_mode_enabled = false;
        }
    }
}