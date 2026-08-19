#!/usr/bin/env bash
set -euo pipefail

# Liên kết (symlink) toàn bộ skill trong repo này tới Claude Code, Codex và Kilo Code
# trên macOS, đồng thời chèn skill BẮT BUỘC (vietnamese-short-answer) vào file
# cấu hình chung của từng công cụ.
#
# Dùng symlink thay vì copy: sửa file trong repo là các công cụ thấy ngay,
# không cần chạy lại script để đồng bộ skill.
#
# Cấu trúc nguồn: <category>/<skill-name>/SKILL.md (category = general, lap-trinh, quang-cao, ...)

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SKILLS_DST="${HOME}/.claude/skills"
CODEX_SKILLS_DST="${HOME}/.codex/skills"
CODEX_LEGACY_SKILLS_DST="${HOME}/.agents/skills"
KILO_SKILLS_DST="${HOME}/.kilocode/skills"

CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
CODEX_AGENTS_MD="${HOME}/.codex/AGENTS.md"
KILO_AGENTS_MD="${HOME}/.config/kilo/AGENTS.md"

MANDATORY_SKILL_DIR="${SRC_DIR}/general/vietnamese-short-answer"
MARKER_START="<!-- MANDATORY_SKILLS_START -->"
MARKER_END="<!-- MANDATORY_SKILLS_END -->"

LINK_COUNT=0

link_skill() {
  local skill_dir="$1" dst_root="$2" skill_name dst_path
  skill_name="$(basename "$skill_dir")"
  dst_path="${dst_root}/${skill_name}"
  mkdir -p "$dst_root"
  if [[ -e "$dst_path" || -L "$dst_path" ]]; then
    rm -rf "$dst_path"
  fi
  ln -s "$skill_dir" "$dst_path"
}

echo
echo "==== LIEN KET SKILLS (macOS) ===="
echo "Source: ${SRC_DIR}"

for category_dir in "${SRC_DIR}"/*/; do
  [[ -d "$category_dir" ]] || continue
  category_name="$(basename "$category_dir")"
  for skill_dir in "${category_dir}"*/; do
    [[ -f "${skill_dir}SKILL.md" ]] || continue
    skill_dir="${skill_dir%/}"
    echo "  [${category_name}] $(basename "$skill_dir")"
    link_skill "$skill_dir" "$CLAUDE_SKILLS_DST"
    link_skill "$skill_dir" "$CODEX_SKILLS_DST"
    link_skill "$skill_dir" "$CODEX_LEGACY_SKILLS_DST"
    link_skill "$skill_dir" "$KILO_SKILLS_DST"
    LINK_COUNT=$((LINK_COUNT + 1))
  done
done

# ---- Skill bat buoc: vietnamese-short-answer ----

if [[ ! -f "${MANDATORY_SKILL_DIR}/SKILL.md" ]]; then
  echo "[CANH BAO] Khong thay ${MANDATORY_SKILL_DIR}/SKILL.md, bo qua buoc chen skill bat buoc." >&2
else
  echo
  echo "==== CHEN SKILL BAT BUOC VAO CAU HINH CHUNG ===="

  # Ham thay the block giua 2 marker, doc noi dung block tu FILE (khong dung
  # bien awk -v nhieu dong, vi awk tren macOS bao loi "newline in string").
  replace_marker_block() {
    local target="$1" blockfile="$2"
    awk -v s="$MARKER_START" -v e="$MARKER_END" -v blockfile="$blockfile" '
      $0==s {
        while ((getline line < blockfile) > 0) print line
        skip=1
        next
      }
      $0==e { skip=0; next }
      !skip { print }
    ' "$target" > "${target}.tmp" && mv "${target}.tmp" "$target"
  }

  # Claude Code: dung @import -> luon cap nhat theo thoi gian thuc, khong can chay lai script
  mkdir -p "$(dirname "$CLAUDE_MD")"
  touch "$CLAUDE_MD"
  claude_blockfile="$(mktemp)"
  {
    echo "$MARKER_START"
    echo "## Skill bat buoc"
    echo
    echo "@${MANDATORY_SKILL_DIR}/SKILL.md"
    echo "$MARKER_END"
  } > "$claude_blockfile"
  if grep -qF "$MARKER_START" "$CLAUDE_MD" 2>/dev/null; then
    replace_marker_block "$CLAUDE_MD" "$claude_blockfile"
  else
    { echo; cat "$claude_blockfile"; } >> "$CLAUDE_MD"
  fi
  rm -f "$claude_blockfile"
  echo "  - Da cap nhat ${CLAUDE_MD} (dung @import, tu dong cap nhat khi sua SKILL.md)"

  # Codex: AGENTS.md khong ho tro @import dang xac nhan -> nhung noi dung truc tiep.
  # Sua SKILL.md xong thi chay lai script nay de dong bo lai doan nay.
  mkdir -p "$(dirname "$CODEX_AGENTS_MD")"
  touch "$CODEX_AGENTS_MD"
  codex_blockfile="$(mktemp)"
  {
    echo "$MARKER_START"
    echo "## Skill bat buoc: vietnamese-short-answer"
    echo "(Dong bo tu ${MANDATORY_SKILL_DIR}/SKILL.md - chay lai script nay sau khi sua file de cap nhat)"
    echo
    awk '
      NR==1 && $0=="---" { infm=1; next }
      infm && $0=="---" { infm=0; next }
      infm { next }
      { print }
    ' "${MANDATORY_SKILL_DIR}/SKILL.md"
    echo "$MARKER_END"
  } > "$codex_blockfile"
  if grep -qF "$MARKER_START" "$CODEX_AGENTS_MD" 2>/dev/null; then
    replace_marker_block "$CODEX_AGENTS_MD" "$codex_blockfile"
  else
    { echo; cat "$codex_blockfile"; } >> "$CODEX_AGENTS_MD"
  fi
  rm -f "$codex_blockfile"
  echo "  - Da cap nhat ${CODEX_AGENTS_MD} (nhung noi dung, can chay lai script khi SKILL.md doi)"

  # Kilo Code: cau hinh chung la ~/.config/kilo/AGENTS.md (giong Codex) -> nhung noi dung truc tiep.
  # Sua SKILL.md xong thi chay lai script nay de dong bo lai doan nay.
  mkdir -p "$(dirname "$KILO_AGENTS_MD")"
  touch "$KILO_AGENTS_MD"
  kilo_blockfile="$(mktemp)"
  {
    echo "$MARKER_START"
    echo "## Skill bat buoc: vietnamese-short-answer"
    echo "(Dong bo tu ${MANDATORY_SKILL_DIR}/SKILL.md - chay lai script nay sau khi sua file de cap nhat)"
    echo
    awk '
      NR==1 && $0=="---" { infm=1; next }
      infm && $0=="---" { infm=0; next }
      infm { next }
      { print }
    ' "${MANDATORY_SKILL_DIR}/SKILL.md"
    echo "$MARKER_END"
  } > "$kilo_blockfile"
  if grep -qF "$MARKER_START" "$KILO_AGENTS_MD" 2>/dev/null; then
    replace_marker_block "$KILO_AGENTS_MD" "$kilo_blockfile"
  else
    { echo; cat "$kilo_blockfile"; } >> "$KILO_AGENTS_MD"
  fi
  rm -f "$kilo_blockfile"
  echo "  - Da cap nhat ${KILO_AGENTS_MD} (nhung noi dung, can chay lai script khi SKILL.md doi)"
fi

echo
echo "==== XONG ===="
echo "So skill da lien ket: ${LINK_COUNT}"
echo "Khoi dong lai Claude Code / Codex / Kilo Code (hoac VS Code) de nhan thay doi."
