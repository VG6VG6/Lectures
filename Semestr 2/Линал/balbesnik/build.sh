#!/bin/bash
mkdir -p build
echo "Очистка старых файлов сборки..."
rm -f build/*.aux build/*.log build/*.toc build/*.out build/*.pdf

echo "Первый проход (сборка структуры)..."
pdflatex -output-directory=build -interaction=nonstopmode main.tex > /dev/null

echo "Второй проход (сборка оглавления)..."
pdflatex -output-directory=build -interaction=nonstopmode main.tex > /dev/null

echo "Третий проход (финализация ссылок)..."
pdflatex -output-directory=build -interaction=nonstopmode main.tex > /dev/null

echo "Готово! PDF находится в build/main.pdf"
