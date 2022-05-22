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

lefDir = ""
odb.read_lef(db, "%s/NangateOpenCellLibrary.tech.lef" % (lefDir))
odb.read_lef(db, "%s/NangateOpenCellLibrary.macro.rect.lef" % (lefDir))

PreProcessNanGate45(db, ['CK'])

design = "superblue18"

bs = BookshelfToOdb( opendbpy = odb, 
    opendb = db,
    auxName = "%s.aux" % (design), 
    siteName = 'FreePDK45_38x28_10R_NP_162NW_34O', 
    macroInstObsLayer = ['metal1', 'via1', 'metal2', 'via2'],
    macroInstPinLayer = ['metal3', 'metal4'],
    primaryLayer = 'metal3', 
    mastersFileName = 'cellList_ng45.txt',
    ffClkPinList = ['CK'],
    customFPRatio = 1.2)

bs.WriteMacroLef('%s_macro.lef' %(design))

odb.write_def(db.getChip().getBlock(), '%s.def' % (design))
odb.write_db(db, '%s.db' % (design))
