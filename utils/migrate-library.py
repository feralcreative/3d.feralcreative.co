#!/usr/bin/env python3
"""Plan and apply no-overwrite moves into model folders, retaining old path aliases."""
import argparse
from collections import defaultdict
import hashlib
import json
import os
from pathlib import Path
import re
import sys
from urllib.parse import unquote, quote

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / 'library'
NATIVE = {
 'awl-sheath': ('hand-tools', ['awl-sheath']),
 'overture-spool': ('3d-printer-tools', ['overture-spool-main-body-ribbed','overture-spool-screwtop-ribbed']),
 'desk-cup-holder': ('office',['desk-cup-holder','desk-cup-holder-starbucks']),
 'slim-can-holder': ('slim-can-holder', ['slim-can-screwdriver-stubby','slim-can-holder-3in-12oz-middle-finger-02','slim-can-holder-12oz','slim-can-adapter','slim-can-holder-8-3oz','slim-can-adapter-ring-fish-12oz-to-8-3oz','slim-can-holder-3in-12oz-wagon-queen','slim-can-adapter-ring-12oz-to-8-3oz','middle-finger-emboss','middle-finger-wrist-emboss','slim-can-holder-3in-12oz-fish']),
 'wire-shelf': ('house',['wire-shelf-box-platform','wire-shelf-cup-holder','wire-shelf-dovetail']),
 'hobbs-chalk-holder': ('hand-tools',['hobbs-chalk-holder','chalk-holder-handle','chalk-holder-tip']),
 'hobbs-painters-pyramid': ('hand-tools',['hobbs-painters-pyramid']),
 'deck-door-stop': ('house',['deck-door-stop','deck-door-stop-truss']),
 'plant-screen': ('cats',['plant-screen','plant-screen-130']),
 'fabric-cube-placard': ('office',['fabric-cube-placard-60x40','fabric-cube-placard-6x4']),
 'gridfinity': ('gridfinity',[]),
}
SINGLE = {
 'roku-stand':'office','roma-tomato-slicing-guide':'kitchen','reversible-door-stop':'house',
 'nightlight-floor-hood':'lighting','kirkland-13gal-tall-kitchen-garbage-bag-dispenser':'house',
 'cat-gap-wedge':'house','tpu-door-stop':'house','batleth':'misc','screen-fence-rail':'cats',
 'beverage-station':'kitchen','door-stop':'house','door-closer-casing-plate':'house',
 'salt-pepper-grinder-tray':'kitchen','large-door-stop':'house','bin-stacking-clip':'storage',
 'phone-shower-holder':'bathroom','zr-monogram-stamp-2026':'branding','can-light-trim':'lighting',
 'magnet-polarity-tool-10x2':'3d-printer-tools','doorbell-wire-channel':'house',
 'sofa-monitor-stand':'office','delonghi-heater-stand':'house','4k-camera-window-mount':'camera',
 'swatch-box':'3d-printer-tools','simplisafe-wire-guide':'house','bong-stabilizer':'drugs',
 'bong-liftout-cradle':'drugs','pumpkin-body':'holiday',
}
for name, category in SINGLE.items(): NATIVE[name] = (category,[name])
CATEGORIES = {
 'printer-tools':'3d-printer-tools','filament-swatch':'3d-printer-tools','bed-scraper':'3d-printer-tools',
 'the-magic-magnet-polarity-tool-v2-model_files':'3d-printer-tools','version+2+-+springs+profile+(a1+mini)_stls':'3d-printer-tools',
 'tools':'hand-tools','woodworking-tools':'hand-tools','bit-holder-test':'hand-tools','soldering-iron-stand':'hand-tools',
 'house':'house','deck':'house','command-hooks':'house','door-stop':'house','window-stop':'house','simplisafe':'house',
 'desk':'office','office':'office','monitor-stand':'office','roku':'office','roku-remote-holder':'office',
 'kitchen':'kitchen','fruit-molds':'kitchen','1.2gal-compost-frame':'kitchen',
 'coke':'slim-can-holder','bumper-dumper':'slim-can-holder','red-bull-cupholder':'slim-can-holder','fish-can-koozie-model_files':'slim-can-holder',
 'bathroom':'bathroom','Tube roller - 44200':'bathroom','bedroom':'bedroom','cats':'cats',
 'storage':'storage','paracord-pull-sphere':'storage','skadis':'skadis','lighting':'lighting','holiday':'holiday',
 'tesla':'automotive','vmc':'automotive','kia-sportage':'automotive','magsafe':'electronics','esp32':'electronics',
 'bx':'branding','feral-creative':'branding','ziad':'branding','frames':'frames','gridfinity':'gridfinity',
 'middle-finger':'misc','star-trek':'misc',"Klingon Bat'Leth - 55100":'misc',
 'Dogs v Cats Chess Set - 7181220':'games','_projects':'projects','garage':'house','water':'house',
}
HOMOGENEOUS = {
 'red-bull-cupholder':'slim-can-holder','bumper-dumper':'slim-can-holder','coke':'slim-can-holder','fish-can-koozie-model_files':'slim-can-holder',
 'the-magic-magnet-polarity-tool-v2-model_files':'magnet-polarity-tool-10x2',
 "Klingon Bat'Leth - 55100":'batleth','gridfinity':'gridfinity','door-stop':'door-stop',
 'tpu-door-stop-model_files':'tpu-door-stop','reversible-tpu-door-stop-firm-or-flexible-model_files':'reversible-door-stop',
 'middle-finger':'slim-can-holder','window-stop':'window-stop','skadis':'skadis','bed-scraper':'bed-scraper',
 'filament-swatch':'filament-swatches','monitor-stand':'sofa-monitor-stand','soldering-iron-stand':'soldering-iron-stand','bit-holder-test':'bit-holder-test',
 'roku':'roku-stand','roku-remote-holder':'roku-stand','simplisafe':'simplisafe-entry-sensor-cover',
 '1.2gal-compost-frame':'compost-frame','Tube roller - 44200':'tube-roller','paracord-pull-sphere':'paracord-pull-sphere',
 'Dogs v Cats Chess Set - 7181220':'dogs-v-cats-chess','magsafe':'magsafe-mount','esp32':'esp32-case',
 'version+2+-+springs+profile+(a1+mini)_stls':'spool-springs','frames':'check-frame','vmc':'vmc-spoiler','ziad':'ziad-sign',
}
PREFIXES = {
 'overture-spool':'overture-spool','cardboardspooladapter':'overture-spool','reusable-spool-for-overture':'overture-spool',
 'chalk-holder':'hobbs-chalk-holder','chalk_holder':'hobbs-chalk-holder','9-mm-chalk-holder':'hobbs-chalk-holder','simple-chalk-holder':'hobbs-chalk-holder',
 'hobbs-painters-pyramid':'hobbs-painters-pyramid','painters-pyramid':'hobbs-painters-pyramid','hobbs-pyramid-box':'hobbs-painters-pyramid','pyramid':'hobbs-painters-pyramid',
 'slim-can':'slim-can-holder','fish_koozie':'slim-can-holder','fish-can-koozie':'slim-can-holder','middlefinger':'slim-can-holder','middle-finger':'slim-can-holder','can-stand':'slim-can-holder','can-light-lens':'can-light-trim',
 'phone-shower-holder':'phone-shower-holder','coffee-station':'beverage-station','beverage-station':'beverage-station',
 'door-stop':'door-stop','large-door-stop':'large-door-stop','large+door+stop':'large-door-stop',
 'reversible tpu door stop':'reversible-door-stop','tpu-door-stop':'tpu-door-stop',
 'screen-fence':'screen-fence-rail','wire-shelf':'wire-shelf','wire-tower-hook':'wire-shelf',
 'flashforge-tool-tray':'flashforge-tool-tray','flashforge tool tray':'flashforge-tool-tray',
 '5mp-riser':'5mp-riser','5mp':'5mp-riser','drawer':'5mp-riser',
 'feral-filament-swatch':'filament-swatches','feral-swatch':'filament-swatches',
 'bitstorage':'gridfinity','heater-stand':'delonghi-heater-stand','bambu-lab-led-lamp-kit':'led-lamp-kit','check-frame':'check-frame','check-mat':'check-frame','lantern-base':'lantern-base',
 'octogon-lamp':'octogon-lamp','decagon':'decagon-lamp','twist-lamp':'twist-lamp',
 'toofstation':'toofstation','sonicare':'toofstation','sanding-block':'sanding-block',
 'chargingstand':'charging-stand','apple-watch':'apple-watch-stand','obj_1_applewatch':'apple-watch-stand','bedside-caddy':'bedside-caddy','cpap':'cpap-accessories','resmed-airsense':'cpap-accessories',
 'roku':'roku-stand','bit-holder':'bit-holder','bit-holders':'bit-holder','dewalt':'bit-holder',
 'feral-xacto':'xacto-stand','xacto':'xacto-stand','stackable-storage-cadd':'stackable-storage-caddy',
 'iris-45qt':'tote-handle','handle-replacement-for-greenmade':'tote-handle','hat-rack':'hat-rack-holder',
 'feral-creative':'feral-creative-sign','feral-work-mat':'feral-work-mat','feral-sign-hook':'sign-hook',
 'bin-label':'fabric-cube-placard','new-fabric-bin-tag':'fabric-cube-placard','name-badge':'name-badge','hobbs-sign':'hobbs-sign','vday-box':'vday-box',
}
MODEL_EXTS = {'.stl','.3mf','.skp','.skb','.scad','.step','.obj','.f3d','.fcstd','.amf','.sldprt','.3ds','.usdz','.usda','.gltf','.dxf'}
SKIP_GROUPS = {'_settings','_sketchup','presets','skb','test'}


def slug(value):
    value = re.sub(r'[- _]+model_files$|[- _]+stls$| - \d{4,}(?:-\d+)?$','',value,flags=re.I)
    return re.sub(r'[^a-z0-9]+','-',value.lower()).strip('-') or 'unnamed-model'


def normalized(value):
    value = value.rstrip('~')
    value = re.sub(r'(?:[ _-](?:copy|fixed|repaired|original|test|poc|final)(?:[ _-]*\d+)?)$','',value,flags=re.I)
    value = re.sub(r'(?:-v\d+(?:\.\d+)?|[ _-]v\d+(?:\.\d+)?)$','',value,flags=re.I)
    return value


def source_owner(stem, owners):
    if stem in owners: return owners[stem]
    matches = [(len(name), model) for name,model in owners.items() if stem.startswith(name+'-')]
    if matches: return max(matches)[1]
    lower = stem.lower()
    for prefix in sorted(PREFIXES,key=len,reverse=True):
        if lower.replace(' ','-').startswith(prefix.replace(' ','-')): return PREFIXES[prefix]
    return None


def category_for_loose(stem):
    s=stem.lower()
    for prefix,cat in [('grillo','kitchen'),('bottle','kitchen'),('bin-stacking','storage'),('iris','storage'),('stackable','storage'),('bedside','bedroom'),('cpap','bedroom'),('resmed','bedroom'),('fireplace','house'),('725','house'),('coffee table','house'),('usbc','electronics'),('miter','hand-tools'),('razor','hand-tools'),('scraperite','hand-tools'),('hotend','3d-printer-tools'),('filament','3d-printer-tools'),('orca','3d-printer-tools'),('plate-holder','3d-printer-tools'),('tool-shelf','3d-printer-tools'),('fanttik','office'),('ivar','office'),('yamaha','office'),('lable','office'),('label','office'),('lantern','lighting'),('circular-lamp','lighting'),('octogon','lighting'),('tesla','automotive'),('truckster','automotive'),('ziad','branding'),('sign-hook','branding'),('screen','cats'),('window-stop','house')]:
        if s.startswith(prefix):return cat
    return 'misc'


def plan():
    models={}; records=[]; destinations=set(); owners={}
    for manifest in LIB.glob('*/*/model.json'):
        m=json.loads(manifest.read_text());m['category']=manifest.parent.parent.name;models[m['id']]=m
        for name in m.get('scad_files',[]):owners[Path(name).stem]=m['id']
    source_paths=sorted((ROOT/'parts').rglob('*.scad'))
    for path in source_paths:
        if path.parent.name=='gridfinity':
            if path.stem not in NATIVE['gridfinity'][1]:NATIVE['gridfinity'][1].append(path.stem)
    for mid,(category,stems) in NATIVE.items():
        actual=[p for p in source_paths if p.stem in stems]
        if not actual: continue
        models[mid]={'id':mid,'category':category,'origin':'authored','status':'testing' if mid=='awl-sheath' else 'unreviewed',
          'scad':actual[0].name,'scad_files':[p.name for p in actual],'exports':[], 'aliases':{}}
        if mid=='gridfinity':models[mid]['scad']='gridfinity-cup.scad'
        if mid in ['overture-spool','slim-can-holder','magnet-polarity-tool-10x2','batleth','gridfinity']:models[mid]['origin']='adapted'
        if mid=='overture-spool':models[mid]['openscad_args']=['--enable=textmetrics'];models[mid]['origin']='adapted'
        for p in actual:owners[p.stem]=mid
    def ensure(mid,cat,origin='legacy'):
        if mid not in models:models[mid]={'id':mid,'category':cat,'origin':origin,'status':'unreviewed','scad':None,'scad_files':[],'exports':[],'aliases':{}}
        return models[mid]
    def add(src,mid,tail,cat=None,origin='legacy',role='asset'):
        src=Path(src); src=src if src.is_absolute() else ROOT/src
        if not src.is_file() or src.is_symlink():return
        model=ensure(mid,cat or 'misc',origin)
        dest=LIB/model['category']/mid/tail
        key=str(dest).casefold()
        if key in destinations or dest.exists():raise ValueError(f'Destination collision: {dest}')
        destinations.add(key)
        rel=str(src.relative_to(ROOT)); target=str(tail)
        model['aliases'][rel]=target
        if src.parent.parts and src.relative_to(ROOT).parts[0] in ['stl','3mf'] and mid in NATIVE:
            model['aliases'].setdefault(src.relative_to(ROOT).parts[0]+'/'+src.name,target)
        records.append({'source':rel,'destination':str(dest.relative_to(ROOT)),'model':mid,'role':role,'sha256':hashlib.sha256(src.read_bytes()).hexdigest()})
    for src in source_paths:
        mid=owners.get(src.stem)
        if mid is None:raise ValueError(f'Unassigned SCAD: {src}')
        add(src,mid,Path(src.name),role='scad')
        custom=src.with_suffix('.json')
        if custom.is_file():add(custom,mid,Path(custom.name))
    originals=sorted(p for p in (ROOT/'_originals').rglob('*') if p.is_file() and not p.is_symlink())
    original_models=[p for p in originals if p.suffix.lower() in MODEL_EXTS]
    for src in originals:
        rel=src.relative_to(ROOT/'_originals'); parts=rel.parts
        if '_PLANS' in parts or src.name=='JOURNAL.md':continue
        if len(parts)>1 and parts[0] in SKIP_GROUPS:continue
        if src.suffix.lower() in {'.dmg','.pkg','.rbz','.orca_printer'}:continue
        group=parts[0] if len(parts)>1 else None
        stem=normalized(src.stem)
        component=parts[1] if len(parts)>2 and parts[1] not in ['files'] else stem
        direct_owner=source_owner(component,owners) or source_owner(stem,owners)
        if src.suffix.lower() not in MODEL_EXTS:
            nested_model=any(p.is_relative_to(ROOT/'_originals'/group/parts[1]) for p in original_models) if group and len(parts)>2 else False
            matching_model=any(p.parent==src.parent and slug(normalized(p.stem))==slug(stem) for p in original_models)
            if not nested_model and not matching_model and not direct_owner and group not in HOMOGENEOUS:continue
        mid=HOMOGENEOUS.get(group)
        cat=CATEGORIES.get(group,category_for_loose(stem))
        if not mid and group=='_projects':
            # Existing architectural projects stay intact, including associated assets.
            project=parts[1] if len(parts)>2 else stem
            if len(parts)>2 and not any(p.suffix.lower() in MODEL_EXTS for p in (ROOT/'_originals'/'_projects'/project).rglob('*') if p.is_file()):continue
            mid=slug(project)
        if not mid and group=='lighting' and stem in ['Base','Level']:mid='twist-lamp'
        if not mid:
            component=parts[1] if len(parts)>2 and parts[1] not in ['files'] else stem
            mid=source_owner(component,owners) or source_owner(stem,owners)
            if not mid:mid=slug(normalized(component))
        origin='imported' if group=='bed-scraper' or any('model_files' in p or re.search(r' - \d{4,}$',p) for p in parts[:-1]) else 'legacy'
        model=ensure(mid,cat,origin)
        if src.suffix.lower()=='.pdf' or src.name.lower() in ['readme.txt','license.txt','license.md','instructions.txt'] or src.suffix.lower()=='.scflicense':
            tail=Path('docs')/rel
        elif mid in NATIVE:
            tail=Path('originals')/rel
        else:
            # Put the useful CAD/print files directly in their model folder.
            tail=Path(src.name) if src.suffix.lower() in MODEL_EXTS-{'.obj','.gltf','.usda'} else Path('originals')/rel
            proposed=LIB/model['category']/mid/tail
            if str(proposed).casefold() in destinations or proposed.exists():tail=Path('originals')/rel
        add(src,mid,tail,cat,origin)
    for tree in ['stl','3mf']:
        for src in sorted((ROOT/tree).rglob('*')):
            if not src.is_file() or src.is_symlink() or src.suffix.lower() not in ['.stl','.3mf','.gcode','.png']:continue
            stem=re.sub(r'-v\d{2,}$','',src.stem)
            mid=source_owner(stem,owners)
            if not mid:
                mid=slug(normalized(stem));ensure(mid,category_for_loose(stem))
            if tree=='stl':
                moving='coupon' in src.name or bool(re.search(r'-v\d{2,}\.stl$',src.name)) or bool(list(src.parent.glob(src.stem+'-v[0-9][0-9]*.stl')))
                tail=Path('_work/stl')/src.name if moving else Path(src.name)
                if not re.search(r'-v\d{2,}$',src.stem) and 'coupon' not in src.stem and src.suffix.lower()=='.stl':
                    if src.stem not in models[mid].setdefault('publish_exports',[]):models[mid]['publish_exports'].append(src.stem)
                if mid in NATIVE and not re.search(r'-v\d{2,}$',src.stem) and 'coupon' not in src.stem and src.suffix.lower()=='.stl':
                    if src.stem not in models[mid]['exports']:models[mid]['exports'].append(src.stem)
            else:tail=Path('saved-jobs')/src.name
            proposed=LIB/models[mid]['category']/mid/tail
            if str(proposed).casefold() in destinations or proposed.exists():tail=Path('originals/previous-exports')/src.relative_to(ROOT)
            add(src,mid,tail,role='work' if '_work' in tail.parts else 'asset')
    for tree in ['renders','slice']:
        if not (ROOT/tree).is_dir():continue
        for src in sorted((ROOT/tree).rglob('*')):
            if not src.is_file() or src.is_symlink():continue
            rel=src.relative_to(ROOT/tree)
            name=rel.parts[0] if len(rel.parts)>1 else re.sub(r'-(?:iso|[xyz](?:plus|minus))\.png$','',src.name)
            mid=source_owner(re.sub(r'-v\d{2,}$','',name),owners)
            if mid not in models:continue
            add(src,mid,Path('_work')/tree/rel,role='work')
    for doc in (ROOT/'docs').glob('*.md'):
        mid=source_owner(doc.stem,owners)
        if mid in models:add(doc,mid,Path('docs')/doc.name)
    for src in ROOT.glob('*.stl'):
        mid='wire-shelf' if src.name=='wire-tower-hook.stl' else source_owner(src.stem,owners)
        if mid in models:add(src,mid,Path('originals/repo')/src.name)
    # Imported source dependencies already on disk can be retained; missing ones
    # are recorded without substituting different geometry.
    incoming={'the-magic-magnet-polarity-tool-v2-model_files':'magnet-polarity-tool-10x2','fish-can-koozie-model_files':'slim-can-holder','MiddleFingerToScale.stl':'slim-can-holder','middle-finger.stl':'slim-can-holder'}
    for name,mid in incoming.items():
        path=ROOT/'_incoming'/name
        files=path.rglob('*') if path.is_dir() else [path]
        for src in files:
            if src.is_file():add(src,mid,Path('originals')/src.relative_to(ROOT))
    for mid,model in models.items():
        for stem in NATIVE.get(mid,('',[]))[1]:
            if stem not in model['exports'] and not stem.endswith(('modules','magnets','dovetail','emboss')):model['exports'].append(stem)
        defaults={'desk-cup-holder':'desk-cup-holder.scad','slim-can-holder':'slim-can-holder-12oz.scad','hobbs-chalk-holder':'hobbs-chalk-holder.scad','deck-door-stop':'deck-door-stop.scad','plant-screen':'plant-screen.scad'}
        if mid in defaults:model['scad']=defaults[mid]
        if mid=='bed-scraper':model['source_url']='https://www.thingiverse.com/thing:6657413'
        model['protected_assets']=sorted(set(model.get('protected_assets',[])) | {new for old,new in model['aliases'].items() if old.startswith('_originals/') or old.startswith('_incoming/')})
        additional=[str(Path(r['destination']).relative_to(Path('library')/model['category']/mid)) for r in records if r['model']==mid and Path(r['source']).suffix.lower()=='.scad' and r['source'].startswith('_originals/')]
        model['additional_scad_files']=sorted(set(model.get('additional_scad_files',[])) | set(additional))
        if not model['scad'] and len(additional)==1:model['scad']=additional[0];model['scad_files']=additional
        if mid not in NATIVE and model['scad']:model.setdefault('output_names',{})[model['scad']]=mid
        if any('textmetrics(' in (ROOT/r['source']).read_text() for r in records if r['model']==mid and Path(r['source']).suffix.lower()=='.scad'):model['openscad_args']=['--enable=textmetrics']
        model['licenses']=list(dict.fromkeys(model.get('licenses',[]) + [str(Path(r['destination']).relative_to(Path('library')/model['category']/mid)) for r in records if r['model']==mid and ('license' in Path(r['source']).name.lower() or Path(r['source']).suffix.lower()=='.scflicense')]))
    return models,records


def rewritten(source,destination,text,mapping):
    oldparent=(ROOT/source).parent;newparent=(ROOT/destination).parent
    def relocation(value):
        old=(oldparent/value).resolve()
        # Ziad authorized the matching retained originals for absent incoming
        # meshes. Their units and all transforms remain defined by the SCAD.
        incoming=ROOT/'_incoming'
        if old.is_relative_to(incoming) and not old.exists():
            relative=old.relative_to(incoming)
            if relative.parts and relative.parts[0] in {'MiddleFingerToScale.stl','middle-finger.stl','fish-can-koozie-model_files','the-magic-magnet-polarity-tool-v2-model_files'}:
                old=(ROOT/'_originals'/relative).resolve()
        if value.startswith('BOSL2/') and (ROOT/'lib'/value).is_file():return os.path.relpath(ROOT/'lib'/value,newparent)
        if old in mapping:return os.path.relpath(mapping[old],newparent)
        if value.startswith('.'):
            # A directory variable can feed many import(str(...)) calls.
            candidates=[]
            for src,dst in mapping.items():
                if src.is_relative_to(old) and src.suffix.lower() in MODEL_EXTS:
                    suffix=src.relative_to(old)
                    target=dst
                    for _ in suffix.parts:target=target.parent
                    candidates.append(target)
            if candidates and len(set(candidates))==1:
                result=os.path.relpath(candidates[0],newparent)
                return result+'/' if value.endswith('/') else result
            # Preserve existing external and missing dependency locations.
            if old.is_relative_to(ROOT):return os.path.relpath(old,newparent)+('/' if value.endswith('/') else '')
        return value
    text=re.sub(r'\b(include|use)\s*<([^>]+)>',lambda m:m[1]+' <'+relocation(m[2])+'>',text)
    text=re.sub(r'"([^"\n]+)"',lambda m:'"'+relocation(m[1])+'"' if m[1].startswith(('./','../')) else m[0],text)
    return text


def rewritten_markdown(source,destination,text,mapping):
    def link(match):
        value=unquote(match[2]); path,sep,fragment=value.partition('#')
        if not path or re.match(r'[a-z]+:',path):return match[0]
        old=((ROOT/source).parent/path).resolve()
        target=mapping.get(old)
        if target is None and old.is_relative_to(ROOT) and old.exists():target=old
        if target is None:return match[0]
        new=os.path.relpath(target,(ROOT/destination).parent)
        return match[1]+quote(new,safe='/.-')+(sep+fragment if sep else '')+match[3]
    return re.sub(r'(\]\()([^\s)]+)(\))',link,text)


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--apply',action='store_true');p.add_argument('--model',action='append');args=p.parse_args()
    models,records=plan()
    if args.model:
        missing=set(args.model)-set(models)
        if missing:raise ValueError(f'Unknown models: {missing}')
        records=[r for r in records if r['model'] in args.model];models={k:v for k,v in models.items() if k in args.model}
    mapping={(ROOT/old).resolve():LIB/m['category']/m['id']/new for m in models.values() for old,new in m.get('aliases',{}).items()}
    mapping.update({(ROOT/r['source']).resolve():(ROOT/r['destination']) for r in records})
    print(f'{len(models)} model folders; {len(records)} file moves; {sum(r["role"]=="work" for r in records)} workspace files')
    out=ROOT/'docs/library-migration.json'
    if not args.apply:
        Path('/private/tmp/scad-library-migration-plan.json').write_text(json.dumps({'models':models,'moves':records},indent=2))
        return
    previous=json.loads(out.read_text()) if out.exists() else {'moves':[]}
    for r in records:
        if hashlib.sha256((ROOT/r['source']).read_bytes()).hexdigest()!=r['sha256']:
            raise ValueError(f'Source changed since planning: {r["source"]}')
    for r in records:
        src=ROOT/r['source'];dst=ROOT/r['destination'];dst.parent.mkdir(parents=True,exist_ok=True)
        if src.suffix.lower() in {'.scad','.md'}:
            rewrite=rewritten if src.suffix.lower()=='.scad' else rewritten_markdown
            text=rewrite(r['source'],r['destination'],src.read_text(),mapping)
            with dst.open('x') as f:f.write(text)
        else:os.link(src,dst)
        src.unlink()
        r['destination_sha256']=hashlib.sha256(dst.read_bytes()).hexdigest()
    for mid,model in models.items():
        directory=LIB/model.pop('category')/mid;directory.mkdir(parents=True,exist_ok=True)
        (directory/'model.json').write_text(json.dumps(model,indent=2)+'\n')
    previous['moves'].extend(r for r in records if r['role']!='work')
    out.write_text(json.dumps(previous,indent=2)+'\n')
    print(f'Applied {len(records)} moves without replacing any destination.')


if __name__=='__main__':
    try:main()
    except (ValueError,OSError) as exc:print(f'error: {exc}',file=sys.stderr);sys.exit(1)
