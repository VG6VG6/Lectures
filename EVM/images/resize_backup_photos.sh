#!/bin/bash

# Директория с фото (передаётся как аргумент или текущая)
PHOTO_DIR="${1:-.}"
BACKUP_DIR="$PHOTO_DIR/original_photos"
BACKUP_ARCHIVE="$PHOTO_DIR/original_photos.tar.gz"

# Убедимся, что PHOTO_DIR — абсолютный путь (для надёжности)
PHOTO_DIR="$(realpath "$PHOTO_DIR")"
BACKUP_DIR="$PHOTO_DIR/original_photos"
BACKUP_ARCHIVE="$PHOTO_DIR/original_photos.tar.gz"

# Поддерживаемые расширения изображений
EXTENSIONS=("jpg" "jpeg" "png" "JPG" "JPEG" "PNG")

is_image() {
    local file="$1"
    for ext in "${EXTENSIONS[@]}"; do
        if [[ "$file" == *."$ext" ]]; then
            return 0
        fi
    done
    return 1
}

# --- Логика восстановления/создания BACKUP_DIR ---
if [[ -f "$BACKUP_ARCHIVE" && ! -d "$BACKUP_DIR" ]]; then
    echo "📁 Архив найден, но папки нет. Распаковываем..."
    tar -xzf "$BACKUP_ARCHIVE" -C "$PHOTO_DIR"
elif [[ -d "$BACKUP_DIR" ]]; then
    echo "📁 Папка original_photos уже существует — добавляем новые фото."
elif [[ ! -f "$BACKUP_ARCHIVE" ]]; then
    echo "📁 Создаём новую папку для оригиналов."
    mkdir -p "$BACKUP_DIR"
else
    echo "⚠️ Непредвиденная ситуация с архивом/папкой. Проверьте вручную."
    exit 1
fi

# --- Обработка изображений ---
processed_any=false

for file in "$PHOTO_DIR"/*; do
    if [[ ! -f "$file" ]] || ! is_image "$file"; then
        continue
    fi

    basename_file=$(basename "$file")
    target_orig="$BACKUP_DIR/$basename_file"

    # Пропускаем, если оригинал уже есть (например, при повторном запуске)
    if [[ -f "$target_orig" ]]; then
        echo "⏭️  Файл уже обработан: $basename_file"
        continue
    fi

    echo "🖼️  Обрабатывается: $basename_file"

    # Перемещаем оригинал в BACKUP_DIR
    mv "$file" "$target_orig"

    # Создаём уменьшенную копию
    convert "$target_orig" -resize 1024x1024\> "$file"

    if [[ -f "$file" ]]; then
        echo "✅ Уменьшено: $basename_file"
        processed_any=true
    else
        echo "❌ Ошибка при создании уменьшенной версии. Возвращаем оригинал."
        mv "$target_orig" "$file"
    fi
done

# --- Архивация ---
if [[ "$processed_any" == true || (! -f "$BACKUP_ARCHIVE" && -d "$BACKUP_DIR") ]]; then
    echo "📦 Создаём или обновляем архив: $BACKUP_ARCHIVE"
    tar -czf "$BACKUP_ARCHIVE" -C "$PHOTO_DIR" original_photos

    if [[ $? -eq 0 ]]; then
        echo "🗑️  Архив создан успешно. Удаляем временную папку..."
        rm -rf "$BACKUP_DIR"
    else
        echo "⚠️  Не удалось создать архив. Папка original_photos оставлена на месте."
    fi
else
    echo "ℹ️  Нет новых фото для обработки. Архив не обновлялся."
fi

echo "✅ Готово!"
