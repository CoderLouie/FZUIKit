# FZUIKit

Swift AppKit/UIKit extensions and useful Classes & utilities.

## Notable Extensions & Classes

### NSView background color
A background color property that automatically adjusts on light/dark mode changes.

```
view.backgroundColor = .red
```

### AVPlayer looping
Easy looping of AVPlayer.

```
player.isLooping = true
```

### NSImage preparingForDisplay & preparingThumbnail
An UIImage port for generating thumbnails and to prepare and decode images to provide much better performance displaying them. It offers synchronous and asynchronous (either via asyc/await or completionHandler) implementations.
```
// prepared decoded image for better performance
if let preparedImage = await image.preparingForDisplay() {
    //
}

// thumbnail image
let maxThumbnailSize = CGSize(width: 512, height: 512)
image.preparingThumbnail(of: maxThumbnailSize) { thumbnailImage in
    if let thumbnailImage = thumbnailImage {
    //
    }
}
```

### ContentConfiguration
Configurate several aspects of views, windows, etc. Examples:
- VisualEffect
```
window.visualEffect = .darkAqua
```
- Shadow
```
let view = NSView()
let shadowConfiguration = ContentConfiguration.Shadow(opacity: 0.5, radius: 2.0)
            view.configurate(using: shadowConfiguration)
```
- Border
```
let borderConfiguration = ContentConfiguration.Border(color: .black, width: 1.0)
view.configurate(using: borderConfiguration)
```
- Text
```
let textField = NSTextField()
let textConfiguration = ContentConfiguration.Text(font: .ystemFont(ofSize: 12), textColor: .red, numberOfLines: 1)
textField.configurate(using: textConfiguration)

### NSSegmentedControl Segments
Configurate the segments of a NSSegmentedControl.
```
let segmentedControl = NSSegmentedControl() {
    Segment("Segment 1", isSelected: true)
    Segment("Segment 2"), 
    Segment(NSImage(named: "Image")!)
    Segment(symbolName: "photo")
}
```

### NSToolbar
Configurate the items of a NSToolbar.
```
let toolbar = Toolbar("ToolbarIdentifier") {
        Button("OpenItem", title: "Open…")
            .onAction() { /// Button pressed }
        FlexibleSpace()
        Segmented("SegmentedItem") {
            Segment("Segment 1", isSelected: true)
            Segment("Segment 2"), 
        }
        Space()
            .onAction() { /// Segmented pressed }
        Search("SearchItem")
            .onSearch() { searchField, stringValue, state in /// Searching }
}
```

### NSMenu
Configurate the items of a Menu.
```
let menu = NSMenu() {
        MenuItem("Open…")
            .onSelect() { // Open item Pressed }
        MenuItem("Delete")
            .onSelect() { // Delete item Pressed }
        SeparatorItem()
        MenuItemHostingView() {
            HStack {
                Circle().forgroundColor(.red)
                Circle().forgroundColor(.blue)
            }
        }
    }
```
