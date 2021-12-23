# RosettaStone
This repository contains **RosettaStone**, which leverages a standard physical design data model (LEF/DEF 5.8) and open-source database implementation ([OpenDB](https://github.com/The-OpenROAD-Project/OpenROAD/blob/master/src/odb/README.md) in [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD)) to effectively connect the academic physical design field's past, present and future. RosettaStone's shared data model enables richer integrations, flow contexts, and assessments for research. 

RosettaStone in theory works with any technology, and we have validated RosettaStone using four open-source technologies ASAP7, NanGate45 and SkyWater130HS/HD). 
This project provides the following:
1. Integration of academic Bookshelf benchmarks into real open-source technologies (ASAP7, NanGate45, SKY130HD, SKY130HS). 
    - Supports ISPD05, ISPD06, ISPD11, DAC2012 benchmark conversions
    - Used odbpy python module from OpenROAD binary
    - Flow consists of 1) OpenDB for std cell mapping and 2) OpenSTA for logic loop breaking
  
2. Converter toolkits to run Bookshelf-based academic tools using OpenDB/OpenROAD.
    - Supporting communication between Bookshelf (*.aux, *.scl, *.nodes, *.route, *.nets, *.pl, *.shapes) and OpenDB
    - OpenDB generation script from LEF/DEF formats
    - OpenDB to Bookshelf converter
    - Bookshelf to OpenDB uploader
    - Supporting additional physical considerations
        - Cell padding for global placement
        - Layer capacity adjustments for global routing
  
3. Sharing more than 30 academic benchmarks integrated with real open-source technologies.


## Supported Benchmark Conversion List.

- Available PDKs
    - ASAP7
    - SKY130HD (Skywater130 HD)
    - SKY130HS (Skywater130 HS)
    - NanGate45

- Bookshelf benchmarks
    - ISPD05 (adaptec1-4, bigblue1-5)
    - ISPD06 (adaptec5, newblue1-7)
    - ISPD11 (superblue{1, 2, 4, 5, 10, 12, 15, 18}) 
    - DAC2012 (superblue{2, 3, 5, 6, 7, 9, 11, 12, 14, 16, 19}) 

## Supported Academic Tool List.

- Placement 
    - NTUPlace3
    - NTUPlace4h
    - RePlAce

- Global Routing
    - FastRoute
    - NCTUgr

- Detailed Routing 
    - TritonRoute

## Getting Started

### Prerequisite

A complied binary of [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) is a prerequisite for RosettaStone to utilize [OpenDB](https://github.com/The-OpenROAD-Project/OpenROAD/blob/master/src/odb/README.md).

- [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) and related packages

### How to Run

#### Integration of academic Bookshelf benchmarks into real open-source technologies (ASAP7, NanGate45, SKY130HD, SKY130HS)
To integrate academic Bookshelf benchmarks into real open-source technologies for a standard physical design data model (LEF/DEF), users can run scripts in the `benchGen` directory.
```shell
cd benchGen
${OpenROAD_binary_path}/openroad -python convert_ng45.py
```

#### Communication between Bookshelf (*.aux, *.scl, *.nodes, *.route, *.nets, *.pl, *.shapes) and OpenDB
- Standard physical design data model (LEF/DEF) formats -> OpenDB

The central database in RosettaStone is OpenDB. This script creates OpenDB from LEF/DEF formats.

```shell
cd odbComm
${OpenROAD_binary_path}/openroad -python make_odb.py
```
Below is a sample of the setting section defined by the user located at the top of the script. 
By adding designs to the design_list, you can create multiple designs of OpenDB.

```shell
################ Settings #################
# Platform for ODB generation
platform = 'sky130hd'
# Contest name
contest = 'ISPD2006'
# OpenROAD-flow-scripts path
orfs_path = '../OpenROAD-flow-scripts'
# Benchmark path (for DEF)
bench_path = '../bench'

# LEF lists
lef_list = [ 
    '%s/flow/platforms/sky130hd/lef/sky130_fd_sc_hd.tlef' %
    orfs_path,
    '%s/flow/platforms/sky130hd/lef/sky130_fd_sc_hd_merged.lef' %
    orfs_path,
    '%s/flow/platforms/sky130hd/lef/sky130io_fill.lef' %
    orfs_path,
    '%s/%s/%s_%s/%s_macro.lef' %
    (bench_path,
     platform,
     contest,
     design,
     design),
]
# Design List
design_list = ['adaptec1', \
               ]   
###########################################
```


- OpenDB -> Bookshelf conversion

Creating Bookshelf format files from OpenDB.
```shell
cd odbComm
${OpenROAD_binary_path}/openroad -python convert_odb2bookshelf.py
```
Below is a sample of the setting section defined by the user located at the bottom of the script. 
```shell
    ################ Settings #################
    odbPath = './odbFiles/'

    # The number of sites for cell padding (+left, +right)
    cellPaddings = [0, 1, 2, 3, 4]
    
    # Format list of Bookshelf to be created.
    modeFormats = ['ISPD04', 'ISPD11']
    
    # OpenDB list for Bookshelf generation
    odbList = [ 
        'sky130hd_ISPD2006_adaptec1',
    ]   

    # Layer capacity adjustment tcl file for global routing
    #layerCapacity = 'layeradjust_sky130hd.tcl'
    layerCapacity = 'layeradjust_empty.tcl'
    ###########################################   
```

- Bookshelf -> OpenDB upload

Uploading the Bookshelf file that passed through the academic tool to OpenDB. This script creates OpenDB and DEF format files.
```shell
cd odbComm
${OpenROAD_binary_path}/openroad -python convert_bookshelf2odb.py
```
Below is a sample of the setting section defined by the user located at the bottom of the script. 
```shell
    ################ Settings #################
    odbPath = './odbFiles'

    # The number of sites for cell padding (+left, +right)
    cellPaddings = [0, 1, 2, 3, 4]

    # Format list of Bookshelf to be created
    modeFormats = ['ISPD04', 'ISPD11']

    # OpenDB list for Bookshelf generation
    odbList = [ 
        'sky130hd_ISPD2006_adaptec1',
    ]   
    ###########################################
```
