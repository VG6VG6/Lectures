#!/bin/bash

# Создаем папку build, если её нет
mkdir -p build

echo "Начинаю компиляцию (1-й проход для оглавления и ссылок)..."
pdflatex -output-directory=build -synctex=1 -interaction=nonstopmode main.tex

echo "Начинаю компиляцию (2-й проход для обновления оглавления)..."
pdflatex -output-directory=build -synctex=1 -interaction=nonstopmode main.tex

echo "✅ Компиляция успешно завершена!"
echo "📄 PDF-файл находится в папке: build/main.pdf"
