import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null
  property bool opened: false
  property int selectedIndex: 0
  property bool integrated: false
  property int assignmentCount: 0

  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
  readonly property string helperPath: configHome + "/omarchy/plugins/io.github.loedn.workspace-router/bin/omarchy-workspace-apps"
  readonly property color background: Color.menu.background
  readonly property color foreground: Color.menu.text
  readonly property color borderColor: Color.menu.border
  readonly property color scrim: Color.menu.scrim
  readonly property color selectedBackground: Color.menu.selectedBackground
  readonly property color selectedText: Color.menu.selectedText
  readonly property var borderSpec: Border.surfaceSpec("menu", "border", borderColor, Math.max(1, Style.space(2)))
  readonly property string fontFamily: Style.font.menuFamily
  readonly property var actionRows: [
    { icon: "󰓾", label: "Assign running app", command: "assign" },
    { icon: "󰐕", label: "Add app class", command: "add" },
    { icon: "󰒓", label: "Manage assignments", command: "manage" },
    integrated
      ? { icon: "󰌾", label: "Disconnect Hyprland", command: "disconnect" }
      : { icon: "󰌷", label: "Connect Hyprland", command: "setup" }
  ]

  function open(payloadJson) {
    root.selectedIndex = 0
    root.opened = true
    root.refreshStatus()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open("{}")
  }

  function refreshStatus() {
    if (!statusProc.running) statusProc.running = true
  }

  function moveSelection(delta) {
    root.selectedIndex = (root.selectedIndex + delta + root.actionRows.length) % root.actionRows.length
  }

  function runAction(command) {
    root.close()
    Quickshell.execDetached([root.helperPath, command])
  }

  Process {
    id: statusProc
    command: [root.helperPath, "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var status = JSON.parse(text)
          root.integrated = status.integrated === true
          root.assignmentCount = Number(status.assignments || 0)
        } catch (error) {
          root.integrated = false
          root.assignmentCount = 0
        }
      }
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "workspace-router-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.close()
    }

    BorderSurface {
      id: card
      width: Math.min(Style.space(380), panel.width - Style.gapsOut * 2)
      height: Math.min(content.implicitHeight + Style.spacing.panelPadding * 2, panel.height - Style.gapsOut * 2)
      anchors.centerIn: parent
      radius: Style.cornerRadius
      color: root.background
      borderSpec: root.borderSpec
      padding: Style.spacing.panelPadding

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape || event.key === Qt.Key_Left || event.key === Qt.Key_Backspace) {
            root.close()
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            root.moveSelection(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.moveSelection(1)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Right) {
            root.runAction(root.actionRows[root.selectedIndex].command)
            event.accepted = true
          }
        }
      }

      Column {
        id: content
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.space(8)

        Text {
          width: parent.width
          text: "Workspace Router"
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.title
          font.bold: true
        }

        Text {
          width: parent.width
          text: root.integrated
            ? root.assignmentCount + (root.assignmentCount === 1 ? " assignment · connected" : " assignments · connected")
            : "Hyprland integration is not connected"
          color: root.integrated ? Color.accent : Color.urgent
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.WordWrap
        }

        Item { width: 1; height: Style.space(4) }

        Repeater {
          model: root.actionRows

          Button {
            required property var modelData
            required property int index
            width: content.width
            text: modelData.label
            iconText: modelData.icon
            leftAlign: true
            focusable: false
            hasCursor: root.selectedIndex === index
            foreground: root.foreground
            onHovered: function(isHovered) { if (isHovered) root.selectedIndex = index }
            onClicked: root.runAction(modelData.command)
          }
        }

        Item { width: 1; height: Style.space(4) }

        Text {
          width: parent.width
          text: "Rules apply to newly opened windows. Existing windows are not moved."
          color: root.foreground
          opacity: 0.62
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.WordWrap
        }
      }
    }
  }
}
