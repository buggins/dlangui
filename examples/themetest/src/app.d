module app;
import dlangui;
mixin APP_ENTRY_POINT;
/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // embed and register app resources listed in file views/resources.list
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());
    // load theme from file "theme_custom.xml"
    Platform.instance.uiTheme = "theme_custom";
    // create window
    Window window = Platform.instance.createWindow("DlangUI example - HelloWorld", null);
    // create some widget to show in window
    window.mainWidget = parseML(q{
        VerticalLayout {
            margins: 10pt
            padding: 10pt
            layoutWidth: fill
            // red bold text with size = 150% of base style size and font face Arial
            TextWidget { text: "Theme test for ThemeTest" }
            Button { text: "Sample button 1 (enabled)" }
            Button { text: "Sample button 2 (enabled)" }
            Button { text: "Sample button 3 (disabled)"; enabled: false }
        }
    });
    // show window                        ; styleId: CUSTOM_BUTTON
    window.show();
    // run message loop
    return Platform.instance.enterMessageLoop();
}
