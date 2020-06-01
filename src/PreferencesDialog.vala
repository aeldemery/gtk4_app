namespace Gtk4AppDemo {
    [GtkTemplate (ui = "/github/aeldemery/gtk4_app/preferences-dialog.ui")]
    public class PreferencesDialog : Gtk.Dialog {
        [GtkChild]
        private Gtk.ComboBox transition_combo;
        [GtkChild]
        private Gtk.FontButton font_button;

        private GLib.Settings settings;

        construct {
            settings = new GLib.Settings ("github.aeldemery.gtk4_app");
            settings.bind ("font", font_button, "font", GLib.SettingsBindFlags.DEFAULT);
            settings.bind ("transition", transition_combo, "active-id", GLib.SettingsBindFlags.DEFAULT);
        }

        public PreferencesDialog (Gtk.Window parent) {
            Object (transient_for: parent, use_header_bar: 1);
        }
    }
}
