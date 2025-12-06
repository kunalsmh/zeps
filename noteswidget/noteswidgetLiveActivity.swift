//
//  noteswidgetLiveActivity.swift
//  noteswidget
//
//  Created by Kunal Sharma on 06/12/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct noteswidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct noteswidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: noteswidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension noteswidgetAttributes {
    fileprivate static var preview: noteswidgetAttributes {
        noteswidgetAttributes(name: "World")
    }
}

extension noteswidgetAttributes.ContentState {
    fileprivate static var smiley: noteswidgetAttributes.ContentState {
        noteswidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: noteswidgetAttributes.ContentState {
         noteswidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: noteswidgetAttributes.preview) {
   noteswidgetLiveActivity()
} contentStates: {
    noteswidgetAttributes.ContentState.smiley
    noteswidgetAttributes.ContentState.starEyes
}
