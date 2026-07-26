#!/usr/bin/env python3

from pathlib import Path
import subprocess
import sys
from PySide6.QtWidgets import (
    QApplication,
    QWidget,
    QListWidget,
    QListWidgetItem,
    QLabel,
    QVBoxLayout,
    QHBoxLayout,
)
from PySide6.QtGui import (
    QPixmap,
    QKeyEvent,
)
from PySide6.QtCore import (
    Qt,
    QSize,
)
from enum import Enum

sys.path.append(str(Path(__file__).parent))
from colors import *

#count of first fetch rows
COLD_FETCH = 50


class Type(Enum):
    TEXT = "text"
    JPEG = "jpeg"
    PNG = "png"

    UNKNOWN = "unknown"

class ClipboardElement:
    def __init__(self, line: str):
        self.is_raw = True
        self.line = line

        self.identifier = None
        self.preview = None
        self.file_type = None
        self.data = None
        
    def unrawing(self):
        self.is_raw = False

        self.validateData()
        
        if self.file_type is Type.UNKNOWN:
            self.data = self.preview
            return
        result = subprocess.run(['cliphist', 'decode', str(self.identifier)], capture_output=True, check=True)
        if self.file_type == Type.TEXT:
            self.data = result.stdout.decode("utf-8")
            return
        self.data = result.stdout
        
    def validateData(self):
        if self.is_raw:
            return
        num, preview, = self.line.split("\t")

        start = self.line.find("[[ binary data")
        if start == -1:
            self.identifier, self.preview, self.file_type = int(num), preview, Type.TEXT
            return

        end = self.line.find("]]", start)
        if end == -1:
            self.identifier, self.preview, self.file_type = int(num), preview, Type.TEXT
            return

        binary_info = self.line[start + 14 : end]
        if "png" in binary_info:
            self.identifier, self.preview, self.file_type = int(num), preview, Type.PNG
            return
        elif "jpeg" in binary_info or "jpg" in binary_info:
            self.identifier, self.preview, self.file_type = int(num), preview, Type.JPEG
            return

        self.identifier, self.preview, self.file_type = int(num), preview, Type.UNKNOWN

class ClipboardItem(QWidget):
    def __init__(self, text = None, pixmap = None):
        super().__init__()

        self.setObjectName("ClipboardItem")
        self.setProperty("selected", False)
        self.setAttribute(Qt.WidgetAttribute.WA_StyledBackground, True)

        layout = QHBoxLayout(self)

        if pixmap:
            image = QLabel()
            image.setPixmap(pixmap)
            layout.addWidget(image)

        if text:
            label = QLabel(text)
            label.setObjectName("ClipboardText")
            layout.addWidget(label)
    
class ClipboardList(QListWidget):
    def __init__(self, elements: list[ClipboardElement]):
        super().__init__()

        self.elements = elements
        self.elements_counter = 0

        self.setVerticalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)
        self.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAlwaysOff)

        self.verticalScrollBar().valueChanged.connect(self.on_scroll)
        self.itemDoubleClicked.connect(self.on_item_double_clicked)
        self.itemSelectionChanged.connect(self.update_selection)

    def addNextItem(self):
        if self.elements_counter == len(self.elements):
            return
        self.elements[self.elements_counter].unrawing()
        element = self.elements[self.elements_counter]

        item = QListWidgetItem()

        if element.file_type == Type.PNG or element.file_type == Type.JPEG:
            pixmap = QPixmap()
            pixmap.loadFromData(element.data)

            pixmap = pixmap.scaled(
                self.viewport().width() - 20,
                500,
                Qt.KeepAspectRatio,
                Qt.SmoothTransformation
            )
        
            widget = ClipboardItem(pixmap = pixmap)
            item.setSizeHint(widget.sizeHint())
            
        elif element.file_type == Type.TEXT or element.file_type == Type.UNKNOWN:
            widget = ClipboardItem(text = element.data)

            height = int(self.viewport().height() * 0.2)
            item.setSizeHint(QSize(int(self.viewport().width() * 0.5), height))

        item.setData(Qt.UserRole, element.identifier)
        
        self.addItem(item)
        self.setItemWidget(item, widget)
        
        self.elements_counter += 1

    def on_item_double_clicked(self, item):
        clip_id = item.data(Qt.UserRole)
        subprocess.run(f"cliphist decode {str(clip_id)} | wl-copy", shell=True, check=True)
        self.window().close()
        return

    def update_selection(self):
        for i in range(self.count()):
            item = self.item(i)
            widget = self.itemWidget(item)

            if widget:
                selected = "true" if item.isSelected() else "false"

                label = widget.findChild(QLabel, "ClipboardText")

                if label:
                    label.setProperty("selected", selected)

                    label.style().unpolish(label)
                    label.style().polish(label)
                    label.update()

    def keyPressEvent(self, event):
        if event.key() == Qt.Key_Return:
            item = self.currentItem()
            if item:
                clip_id = item.data(Qt.UserRole)
                subprocess.run(f"cliphist decode {str(clip_id)} | wl-copy", shell=True, check=True)
                self.window().close()
                return
                
        elif event.key() == Qt.Key_Escape:
            self.window().close()
            return
            
        super().keyPressEvent(event)

    def on_scroll(self, value):
        scrollbar = self.verticalScrollBar()
        if value >= scrollbar.maximum() - 10:
            for i in range(COLD_FETCH):
                self.addNextItem()

class MainWindow(QWidget):
    def __init__(self, elements: list[ClipboardElement]):
        self.elements = elements
        super().__init__()

        self.setObjectName("MainWindow")
        self.setAttribute(Qt.WidgetAttribute.WA_StyledBackground, True)

        self.setWindowTitle("clipboard_manager")

        self.setup_ui()

    def setup_ui(self):
        self.list = ClipboardList(self.elements)
        layout = QVBoxLayout()
        for i in range(COLD_FETCH):
            self.list.addNextItem()
        layout.addWidget(self.list)
        self.setLayout(layout)

def main():
    result = subprocess.run(['cliphist', 'list'], capture_output=True, text=True, check=True)
    result = list(map(ClipboardElement, result.stdout.splitlines()))
    
    app = QApplication(sys.argv)
    app.setApplicationName("clipboard-manager")
    app.setDesktopFileName("clipboard-manager")
    
    with open(Path(__file__).parent / "style.qss", "r", encoding="utf-8") as file:
        qss = file.read()
        qss = qss.format(background = BACKGROUND, text = TEXT, selected_background = BACKGROUND_SELECTED, selected_text = TEXT_SELECTED, border = BORDER)
        app.setStyleSheet(qss)
    
    window = MainWindow(result)
    window.show()

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
