#!/bin/bash

# Автоопределение языка
if locale | grep -qi "LANG.*ru" || locale | grep -qi "LC_.*ru"; then
    LANG_RU=true
else
    LANG_RU=false
fi

# Тексты на русском
if $LANG_RU; then
    TXT_TITLE="=== Настройка главного дисплея для Gaming Mode в Bazzite ==="
    TXT_SEARCH="Поиск подключённых дисплеев..."
    TXT_FOUND="Найдены подключённые дисплеи:"
    TXT_PROMPT="Введи номер дисплея, который хочешь сделать главным в Gaming Mode: "
    TXT_ERROR_NO_DISPLAY="Ошибка: Не найдено ни одного подключённого дисплея."
    TXT_ERROR_INVALID="Ошибка: Неверный выбор. Введи только номер из списка."
    TXT_SELECTED="Выбран дисплей: %s"
    TXT_SAVED="Конфигурация сохранена в %s"
    TXT_CONTENT="Содержимое файла:"
    TXT_DONE="Готово! Теперь %s будет главным дисплеем в Gaming Mode."
    TXT_REBOOT="Перезагрузить систему сейчас? (y/N): "
    TXT_REBOOTING="Перезагружаемся..."
    TXT_MANUAL="Перезагрузи вручную командой 'reboot', чтобы изменения вступили в силу."
else
    TXT_TITLE="=== Setting Primary Display for Gaming Mode in Bazzite ==="
    TXT_SEARCH="Searching for connected displays..."
    TXT_FOUND="Found connected displays:"
    TXT_PROMPT="Enter the number of the display you want to set as primary in Gaming Mode: "
    TXT_ERROR_NO_DISPLAY="Error: No connected displays found."
    TXT_ERROR_INVALID="Error: Invalid choice. Enter only a number from the list."
    TXT_SELECTED="Selected display: %s"
    TXT_SAVED="Configuration saved to %s"
    TXT_CONTENT="File contents:"
    TXT_DONE="Done! %s will now be the primary display in Gaming Mode."
    TXT_REBOOT="Reboot the system now? (y/N): "
    TXT_REBOOTING="Rebooting..."
    TXT_MANUAL="Reboot manually with 'reboot' for changes to take effect."
fi

CONFIG_DIR="$HOME/.config/environment.d"
CONFIG_FILE="$CONFIG_DIR/10-gamescope-session.conf"

echo "$TXT_TITLE"
echo

mkdir -p "$CONFIG_DIR"

echo "$TXT_SEARCH"
mapfile -t CONNECTORS < <(for dir in /sys/class/drm/card*-*; do
    [ -f "$dir/status" ] && grep -q "^connected$" "$dir/status" && basename "$dir"
done | sed 's/^card[0-9]*-//' | sort -u)

if [ ${#CONNECTORS[@]} -eq 0 ]; then
    echo "$TXT_ERROR_NO_DISPLAY"
    echo "Check your monitor connections and try again." >&2
    exit 1
fi

echo "$TXT_FOUND"
echo
for i in "${!CONNECTORS[@]}"; do
    echo "$((i+1))) ${CONNECTORS[i]}"
done
echo

read -p "$TXT_PROMPT" choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#CONNECTORS[@]}" ]; then
    echo "$TXT_ERROR_INVALID"
    exit 1
fi

SELECTED="${CONNECTORS[$((choice-1))]}"

echo
printf "$TXT_SELECTED\n" "$SELECTED"
echo

cat > "$CONFIG_FILE" << EOF
OUTPUT_CONNECTOR=$SELECTED
EOF

printf "$TXT_SAVED\n" "$CONFIG_FILE"
echo "$TXT_CONTENT"
echo "-------------------"
cat "$CONFIG_FILE"
echo "-------------------"
echo
printf "$TXT_DONE\n" "$SELECTED"
echo
read -p "$TXT_REBOOT" reboot_now
if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
    echo "$TXT_REBOOTING"
    reboot
else
    echo "$TXT_MANUAL"
fi
