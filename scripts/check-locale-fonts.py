from pathlib import Path
import struct,json,unicodedata
u16=lambda b,o:struct.unpack_from('>H',b,o)[0]
u32=lambda b,o:struct.unpack_from('>I',b,o)[0]
def glyphs(path):
 b=path.read_bytes();tables={b[12+i*16:16+i*16]:u32(b,20+i*16) for i in range(u16(b,4))};base=tables[b'cmap'];out=set()
 for i in range(u16(b,base+2)):
  off=base+u32(b,base+4+i*8+4);fmt=u16(b,off)
  if fmt==12:
   for j in range(u32(b,off+12)):
    start,end,glyph=struct.unpack_from('>III',b,off+16+j*12)
    out.update(range(start+(glyph==0),end+1))
  elif fmt==4:
   count=u16(b,off+6)//2;endpos=off+14;startpos=endpos+2*count+2;deltapos=startpos+2*count;rangepos=deltapos+2*count
   for j in range(count):
    start,end=u16(b,startpos+2*j),u16(b,endpos+2*j);delta=u16(b,deltapos+2*j);ro=u16(b,rangepos+2*j)
    for c in range(start,end+1):
     glyph=u16(b,rangepos+2*j+ro+2*(c-start)) if ro else (c+delta)%65536
     if glyph:out.add(c)
 return out
covered=set()
for font in Path('apps/mobile/assets/fonts').glob('*.ttf'):covered|=glyphs(font)
for path in Path('apps/mobile/lib/l10n').glob('app_*.arb'):
 data=json.loads(path.read_text());missing={c for k,s in data.items() if not k.startswith('@') for c in s if unicodedata.category(c)[0] in ['L','M'] and ord(c) not in covered}
 assert not missing,(path,missing)
print('PASS bundled font cmap coverage for every catalog letter and combining mark')
