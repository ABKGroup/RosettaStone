from BookshelfToOdb import BookshelfToOdb
import odbpy as odb

def PreProcessNanGate45(db, ffClkPinList):
  for lib in db.getLibs():
    for master in lib.getMasters():
      for mTerm in master.getMTerms():
        if mTerm.getName() in ffClkPinList:
          master.setSequential(1)
          print("[INFO] Set %s as sequential masters" %(master.getName()))
          break

db = odb.dbDatabase.create()

odb.read_lef(db, "../sky130_lib/lef/sky130_fd_sc_hd.tlef")
odb.read_lef(db, "../sky130_lib/lef/sky130_fd_sc_hd_merged.lef")

# PreProcessNanGate45(db, ['CK'])

design = "superblue18"

bs = BookshelfToOdb( opendbpy = odb, 
    opendb = db,
    auxName = "%s.aux" % (design), 
    siteName = 'unithd', 
    macroInstObsLayer = ['li1', 'mcon', 'met1', 'via', 'met2', 'via2'],
    macroInstPinLayer = ['met3', 'met4'],
    primaryLayer = 'met3', 
    mastersFileName = 'cellList_sky130hd.txt',
    ffClkPinList = ['CLK'],
    customFPRatio = 2.0)

bs.WriteMacroLef('%s_macro.lef' %(design))

odb.write_def(db.getChip().getBlock(), '%s.def' % (design))
odb.write_db(db, '%s.db' % (design))
