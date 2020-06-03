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
        private Gtk.SearchEntry searchentry;
        [GtkChild]
        private Gtk.ToggleButton search_button;
        [GtkChild]
        private Gtk.Revealer sidebar;
        [GtkChild]
        private Gtk.ListBox words;
        [GtkChild]
        private Gtk.Label lines;
        [GtkChild]
        private Gtk.Label lines_label;

        construct {
            var builder = new Gtk.Builder.from_resource ("/github/aeldemery/gtk4_app/gears-menu.ui");
            app_menu = builder.get_object ("app-menu") as GLib.MenuModel;
            assert_nonnull (app_menu);
            gears.set_menu_model (app_menu);

            settings = new GLib.Settings ("github.aeldemery.gtk4_app");
            settings.bind ("transition", stack, "transition-type", GLib.SettingsBindFlags.DEFAULT);
            settings.bind ("show-words", sidebar, "reveal-child", GLib.SettingsBindFlags.DEFAULT);

            search_button.bind_property ("active", searchbar, "search-mode-enabled", BindingFlags.BIDIRECTIONAL);
            lines.bind_property ("visible", lines_label, "visible", BindingFlags.DEFAULT);

            var show_words_action = settings.create_action ("show-words");
            this.add_action (show_words_action);

            var lines_action = new GLib.PropertyAction ("show-lines", lines, "visible");
            this.add_action (lines_action);

            sidebar.notify["reveal-child"].connect ((sender, property) => {
                words_changed (sender, property);
            });
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
            update_words ();
            update_lines ();
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
            update_words ();
            update_lines ();
        }

        void words_changed (Object sidebar, GLib.ParamSpec paramspec) {
            update_words ();
        }

        void find_word (Gtk.Button button) {
            searchentry.text = button.label;
        }

        void update_words () {
            // GLib.HashTable strings = new GLib.HashTable<string, string>(str_hash, str_equal);
            Gee.HashSet<string> strings = new Gee.HashSet<string>();
            Gtk.TextIter start, end;

            var tab = stack.visible_child;
            if (tab == null) {
                return;
            }

            var view = (Gtk.TextView)tab.get_first_child ();
            var buffur = view.get_buffer ();
            buffur.get_start_iter (out start);
            end = start;

            while (!start.is_end ()) {
                while (!start.starts_word ()) {
                    if (!start.forward_char ()) break;
                }
                if (!end.forward_word_end ()) break;
                var word = buffur.get_text (start, end, false);
                // debug (word + "\n");
                start = end;
                strings.add (word.down ());
            }

            var child = words.get_first_child ();
            while (child != null) {
                var next = child.get_next_sibling ();
                words.remove (child);
                child = next;
            }

            foreach (var key in strings) {
                var row = new Gtk.Button.with_label (key);
                row.clicked.connect ((w) => { find_word (w); });
                words.prepend (row);
                row.show ();
            }
        }

        void update_lines () {
            var view = stack.visible_child;
            if (view == null) return;

            var text = view.get_first_child () as Gtk.TextView;
            var buffer = text.get_buffer ();
            var count = buffer.get_line_count ();

            lines.label = count.to_string ();
        }
    }
}