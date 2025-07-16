#!/bin/bash

# Ensures that the package is ready for a release.
# 
# Will update the CHANGELOG.md using git-cliff and prepare for a new version.
#
# Usage:
# `./release_ready.sh` - автоматическое определение версии
# `./release_ready.sh <version>` - указание конкретной версии

set -e

# Проверяем, что мы на ветке main
currentBranch=$(git symbolic-ref --short -q HEAD)
if [[ ! $currentBranch == "main" ]]; then
    echo "❌ Releasing is only supported on the main branch."
    exit 1
fi

# Проверяем, что рабочая директория чистая
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Working directory is not clean. Please commit or stash your changes."
    exit 1
fi

# Проверяем, что git-cliff установлен
if ! command -v git-cliff &> /dev/null; then
    echo "❌ git-cliff is not installed. Please install it first:"
    echo "   cargo install git-cliff"
    exit 1
fi

# Получаем текущую версию из последнего тега
current_version=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "0.0.0")
echo "📋 Current version: $current_version"

# Определяем новую версию
if [[ -n "$1" ]]; then
    # Версия указана в аргументе
    new_version="$1"
    echo "🎯 Using provided version: $new_version"
else
    # Автоматическое определение версии через git-cliff
    echo "🔍 Determining next version automatically..."
    new_version=$(git cliff --bumped-version)
    
    if [[ -z "$new_version" ]]; then
        echo "❌ Could not determine next version. No commits found since last tag."
        exit 1
    fi
    
    # Убираем префикс 'v' если он есть
    new_version=${new_version#v}
    echo "🚀 Next version: $new_version"
fi

# Проверяем, что новая версия отличается от текущей
if [[ "$new_version" == "$current_version" ]]; then
    echo "❌ Current version is $current_version, can't update to the same version."
    exit 1
fi

# Проверяем, что версия не существует в CHANGELOG
if grep -q "## \[${new_version}\]" "../CHANGELOG.md" 2>/dev/null; then
    echo "❌ CHANGELOG already contains version $new_version."
    exit 1
fi

# Создаем сообщение коммита для генерации changelog
commit_msg="chore(release): update CHANGELOG.md for $new_version"

echo "📝 Generating CHANGELOG.md..."

# Генерируем changelog с помощью git-cliff, используя cliff.toml из корня
git cliff --config ../cliff.toml --with-commit "$commit_msg" --bump -o ../CHANGELOG.md

if [[ $? -ne 0 ]]; then
    echo "❌ Failed to generate CHANGELOG.md"
    exit 1
fi

echo "✅ CHANGELOG.md generated successfully"

# Создаем новую ветку для релиза
branch_name="chore/release-$new_version"
echo "🌿 Creating git branch: $branch_name"

git checkout -b "$branch_name" > /dev/null 2>&1

# Добавляем изменения и сразу коммитим
echo "💾 Committing changes..."
git add ../CHANGELOG.md
git commit -m "$commit_msg"

echo ""
echo "🎉 Release preparation completed!"
echo "📁 Generated files:"
echo "   - CHANGELOG.md"
echo ""
echo "📋 Summary:"
echo "   - Branch: $branch_name"
echo "   - Version: $current_version → $new_version"
echo "   - Commit: $commit_msg"
echo ""
echo "🚀 Next steps:"
echo "   1. Review the changes in CHANGELOG.md"
echo "   2. Push the branch and create a PR"
echo "   3. After merging, create a tag: git tag v$new_version"
