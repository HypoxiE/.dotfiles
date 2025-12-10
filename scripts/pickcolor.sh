#!/bin/bash

# Проверяем зависимости
for cmd in hyprctl grim magick wl-copy; do
    if ! command -v $cmd &> /dev/null; then
        echo "Ошибка: $cmd не найден. Установите его."
        exit 1
    fi
done

# Получаем координаты курсора
read CURSOR_X CURSOR_Y <<< $(hyprctl cursorpos | tr ',' ' ')

# Временный файл для скриншота
FILE=$(mktemp /tmp/pixel-XXXX.png)

# Делаем скриншот 1x1 пикселя под курсором
grim -g "${CURSOR_X},${CURSOR_Y} 1x1" "$FILE"

# Получаем цвет пикселя в HEX
COLOR=$(magick "$FILE" -format "%[hex:p{0,0}]" info:)

# Копируем в буфер
echo -n "#$COLOR" | wl-copy

# Убираем временный файл
rm "$FILE"

echo "Цвет #$COLOR скопирован в буфер"
