import Cocoa
import SwiftUI

@MainActor
final class PopoverController {
    static let shared = PopoverController()

    private var popover: NSPopover?
    private var eventMonitor: Any?

    func toggle(relativeTo button: NSStatusBarButton, viewModel: UsageViewModel) {
        if let popover = popover, popover.isShown {
            close()
        } else {
            show(relativeTo: button, viewModel: viewModel)
        }
    }

    private func show(relativeTo button: NSStatusBarButton, viewModel: UsageViewModel) {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverView(viewModel: viewModel)
        )

        self.popover = popover
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.close()
        }
    }

    private func close() {
        popover?.performClose(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
