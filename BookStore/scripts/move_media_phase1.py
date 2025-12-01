import re
from pathlib import Path
import shutil

root = Path('d:/Bookstore-JspServlet-main/Bookstore-JspServlet-main/Bookstore-JspServlet-main/BookStore')
css_dir = root / 'web' / 'CSS'
build_css_dir = root / 'build' / 'web' / 'CSS'

style_file = css_dir / 'style.css'
responsive_file = css_dir / 'responsive.css'

build_style_file = build_css_dir / 'style.css'
build_responsive_file = build_css_dir / 'responsive.css'

patterns = [r"@media\s*\(max-width:\s*991px\)", r"@media\s*\(max-width:\s*768px\)"]

print('Phase1: move @media blocks for 991px and 768px')

if not style_file.exists():
    print('style.css not found at', style_file)
    raise SystemExit(1)
if not responsive_file.exists():
    print('responsive.css not found at', responsive_file)
    raise SystemExit(1)

# read
style_text = style_file.read_text(encoding='utf-8')
responsive_text = responsive_file.read_text(encoding='utf-8')

# backups
shutil.copy2(str(style_file), str(style_file) + '.backup')
shutil.copy2(str(responsive_file), str(responsive_file) + '.backup')
print('Backups created')

# find all blocks
blocks = []
for pat in patterns:
    for m in re.finditer(pat, style_text):
        start_idx = m.start()
        # find the opening brace
        brace_pos = style_text.find('{', start_idx)
        if brace_pos == -1:
            continue
        idx = brace_pos + 1
        depth = 1
        while idx < len(style_text) and depth > 0:
            ch = style_text[idx]
            if ch == '{':
                depth += 1
            elif ch == '}':
                depth -= 1
            idx += 1
        end_idx = idx  # end_idx is after the closing brace
        block_text = style_text[start_idx:end_idx]
        blocks.append((start_idx, end_idx, block_text))

# deduplicate overlapping by sorting and merging
blocks_sorted = sorted(blocks, key=lambda x: x[0])
merged = []
for s,e,txt in blocks_sorted:
    if not merged:
        merged.append([s,e,txt])
    else:
        if s <= merged[-1][1]:
            # overlap
            merged[-1][1] = max(merged[-1][1], e)
            merged[-1][2] = style_text[merged[-1][0]:merged[-1][1]]
        else:
            merged.append([s,e,txt])

if not merged:
    print('No matching @media blocks found for these breakpoints.')
    raise SystemExit(0)

# Append to responsive.css with comment header
from datetime import datetime
now = datetime.utcnow().isoformat() + 'Z'
append_text = '\n\n/* Moved media blocks (phase1) from style.css on %s */\n' % now
for s,e,txt in merged:
    append_text += txt + '\n\n'

responsive_text_new = responsive_text + append_text
responsive_file.write_text(responsive_text_new, encoding='utf-8')
print('Appended', len(merged), 'blocks to', responsive_file)

# In style.css comment out original blocks
new_style = ''
last = 0
for s,e,txt in merged:
    new_style += style_text[last:s]
    commented = '\n/* MOVED TO responsive.css (phase1) START */\n' + txt + '\n/* MOVED TO responsive.css (phase1) END */\n'
    new_style += commented
    last = e
new_style += style_text[last:]
style_file.write_text(new_style, encoding='utf-8')
print('Updated', style_file, 'with commented moved blocks')

# Mirror to build directory if present
if build_style_file.exists():
    shutil.copy2(str(style_file), str(build_style_file) + '.backup')
    build_style_file.write_text(new_style, encoding='utf-8')
    print('Updated build style.css')
if build_responsive_file.exists():
    build_responsive_text = build_responsive_file.read_text(encoding='utf-8')
    build_responsive_file.write_text(build_responsive_text + append_text, encoding='utf-8')
    print('Appended to build responsive.css')

print('Phase1 complete. Please test pages and let me know any regressions.')
