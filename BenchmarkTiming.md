# Timing Comparison Between pre-logic cutting and post-logic cutting.
- "PreLC" means pre-logic cutting. (before the [break_timing_path.tcl](benchGen/break_timing_path_ng45.tcl))
- "PostLC" means post-logic cutting. (after the [break_timing_path.tcl](benchGen/break_timing_path_ng45.tcl))
- Note that all timing results were measured using OpenSTA with PrePlace engine. We followed the commercial tool's PrePlace timing convention. (e.g., ignoring timing paths for every net where fanout is >= 100).

| Design (PDK / Academic Bookshelf)   | PreLC Effective Clock Periods (ns)     | PreLC # Stage on the Worst Timing Path | PostLC Effective Clock Periods (ns) | PostLC # Stage on the Worst Timing Path |
|:------------------------------------|----------------------:|-----------------:|---------------------:|----------------:|
| asap7/DAC2012_superblue11           |                 70.47 |             2497 |                 2.37 |              27 |
| asap7/DAC2012_superblue12           |                  3.91 |              141 |                 3.11 |              20 |
| asap7/DAC2012_superblue14           |                 16.76 |              450 |                 2.78 |              26 |
| asap7/DAC2012_superblue16           |                  4.72 |              144 |                 1.31 |              21 |
| asap7/DAC2012_superblue19           |                  7.25 |              279 |                 1.79 |              18 |
| asap7/DAC2012_superblue2            |                  8.55 |              327 |                 2.47 |              11 |
| asap7/DAC2012_superblue3            |                 13.28 |              495 |                 1.89 |              24 |
| asap7/DAC2012_superblue5            |                  7.26 |              271 |                 2.62 |              26 |
| asap7/DAC2012_superblue6            |                  7.18 |              267 |                 2.67 |              26 |
| asap7/DAC2012_superblue7            |                  5.42 |              211 |                 2.87 |              10 |
| asap7/DAC2012_superblue9            |                  8.14 |              308 |                 2.05 |              82 |
| asap7/ISPD2006_adaptec1             |                 42.71 |             1070 |                 1.36 |              27 |
| asap7/ISPD2006_adaptec2             |                 68.83 |             2412 |                 1.54 |              27 |
| asap7/ISPD2006_adaptec3             |                498.73 |            16255 |                 2.16 |              27 |
| asap7/ISPD2006_adaptec4             |                405.11 |            13884 |                 1.34 |              27 |
| asap7/ISPD2006_adaptec5             |               1005.98 |            31906 |                 2.04 |              26 |
| asap7/ISPD2006_bigblue1             |                175.31 |             5939 |                 1.33 |              27 |
| asap7/ISPD2006_bigblue2             |                148.37 |             4315 |                 1.69 |              25 |
| asap7/ISPD2006_bigblue3             |                 85.4  |             3174 |                 1.49 |              27 |
| asap7/ISPD2006_bigblue4             |                540.97 |            15045 |                 4.45 |              77 |
| asap7/ISPD2006_newblue1             |                 67.88 |             2953 |                 1.19 |              26 |
| asap7/ISPD2006_newblue2             |                418.63 |            11588 |                 1.52 |              27 |
| asap7/ISPD2006_newblue3             |                 44.95 |             1213 |                 1.66 |              20 |
| asap7/ISPD2006_newblue4             |                355.09 |            11178 |                 1.37 |              27 |
| asap7/ISPD2006_newblue5             |                 45.6  |             1504 |                 1.56 |              26 |
| asap7/ISPD2006_newblue6             |                461.99 |            13655 |                 1.83 |              27 |
| asap7/ISPD2006_newblue7             |                279.39 |             8253 |                 1.96 |              27 |
| asap7/ISPD2011_superblue10          |                  8.47 |              268 |                 2.57 |              25 |
| asap7/ISPD2011_superblue12          |                  3.91 |              141 |                 3.11 |              20 |
| asap7/ISPD2011_superblue15          |                  2.44 |               27 |                 2.37 |              29 |
| asap7/ISPD2011_superblue18          |                  5.72 |              189 |                 2.72 |              16 |
| asap7/ISPD2011_superblue1           |                  8.11 |              302 |                 1.87 |              28 |
| asap7/ISPD2011_superblue2           |                  8.55 |              327 |                 2.47 |              11 |
| asap7/ISPD2011_superblue4           |                 21.68 |              533 |                 1.74 |              14 |
| asap7/ISPD2011_superblue5           |                  7.26 |              271 |                 2.62 |              26 |
| ng45/DAC2012_superblue11            |                117.2  |             2482 |                10.97 |              28 |
| ng45/DAC2012_superblue12            |                  8.72 |              141 |                 3.08 |              14 |
| ng45/DAC2012_superblue14            |                 66.19 |              440 |                 4.52 |              19 |
| ng45/DAC2012_superblue16            |                 11.29 |              143 |                 2.38 |              27 |
| ng45/DAC2012_superblue19            |                 13.98 |              279 |                 3.91 |              17 |
| ng45/DAC2012_superblue2             |                 16.7  |              325 |                 4.2  |              23 |
| ng45/DAC2012_superblue3             |                 24.22 |              485 |                 4.36 |              26 |
| ng45/DAC2012_superblue5             |                 29.88 |              447 |                 4.94 |              19 |
| ng45/DAC2012_superblue6             |                 45.35 |              879 |                 6.75 |              12 |
| ng45/DAC2012_superblue7             |                 10.3  |              208 |                 4.58 |               8 |
| ng45/DAC2012_superblue9             |                 16.05 |              320 |                 3.31 |              23 |
| ng45/ISPD2006_adaptec1              |                 53.06 |              847 |                 2.34 |              26 |
| ng45/ISPD2006_adaptec2              |                180.77 |             3408 |                 2.41 |              26 |
| ng45/ISPD2006_adaptec3              |                188.48 |             3942 |                 2.39 |              26 |
| ng45/ISPD2006_adaptec4              |                270.59 |             5447 |                 2.37 |              27 |
| ng45/ISPD2006_adaptec5              |                364.15 |             6731 |                 2.92 |              24 |
| ng45/ISPD2006_bigblue1              |                243.91 |             4128 |                 2.37 |              25 |
| ng45/ISPD2006_bigblue2              |                297.02 |             4312 |                 2.61 |              26 |
| ng45/ISPD2006_bigblue3              |                843.3  |            16991 |                 3    |              26 |
| ng45/ISPD2006_bigblue4              |                944.62 |            16728 |                 3.07 |              26 |
| ng45/ISPD2006_newblue1              |                166.28 |             3787 |                 2.58 |              26 |
| ng45/ISPD2006_newblue2              |                842.98 |            15361 |                 2.33 |              26 |
| ng45/ISPD2006_newblue3              |                128.47 |             2443 |                 2.41 |              26 |
| ng45/ISPD2006_newblue4              |                600.24 |            12320 |                 2.61 |              25 |
| ng45/ISPD2006_newblue5              |                 59.16 |             1152 |                 3.13 |              26 |
| ng45/ISPD2006_newblue6              |                274.1  |             5142 |                 2.74 |              26 |
| ng45/ISPD2006_newblue7              |                555.64 |             9820 |                 2.6  |              26 |
| ng45/ISPD2011_superblue10           |                 19.48 |              267 |                 3.23 |              24 |
| ng45/ISPD2011_superblue12           |                  8.72 |              141 |                 3.08 |              14 |
| ng45/ISPD2011_superblue15           |                 13.08 |              105 |                 7.53 |              23 |
| ng45/ISPD2011_superblue18           |                 12.98 |              187 |                 4.05 |               7 |
| ng45/ISPD2011_superblue1            |                 15.74 |              308 |                 3.77 |              18 |
| ng45/ISPD2011_superblue2            |                 16.7  |              325 |                 4.2  |              23 |
| ng45/ISPD2011_superblue4            |                 87.03 |              513 |                 7.31 |              14 |
| ng45/ISPD2011_superblue5            |                 29.88 |              447 |                 4.94 |              19 |
| sky130hd/DAC2012_superblue11        |                478.38 |             2473 |                27.47 |              22 |
| sky130hd/DAC2012_superblue12        |                 30.99 |              139 |                18.11 |              21 |
| sky130hd/DAC2012_superblue14        |                126.27 |              447 |                17.24 |              38 |
| sky130hd/DAC2012_superblue16        |                 39.39 |              144 |                 8.78 |              20 |
| sky130hd/DAC2012_superblue19        |                 55.55 |              272 |                13.79 |              16 |
| sky130hd/DAC2012_superblue2         |                 66.27 |              327 |                13.87 |              23 |
| sky130hd/DAC2012_superblue3         |                 82.78 |              490 |                15.01 |              24 |
| sky130hd/DAC2012_superblue5         |                 88.15 |              453 |                18.91 |              21 |
| sky130hd/DAC2012_superblue6         |                161.58 |              875 |                12.91 |              24 |
| sky130hd/DAC2012_superblue7         |                 41.13 |              209 |                21.56 |              10 |
| sky130hd/DAC2012_superblue9         |                 62.78 |              319 |                17.18 |              26 |
| sky130hd/ISPD2006_adaptec1          |                168.27 |              846 |                 9.94 |              26 |
| sky130hd/ISPD2006_adaptec2          |                524.11 |             3401 |                 7.99 |              27 |
| sky130hd/ISPD2006_adaptec3          |                667.84 |             3913 |                10.76 |              26 |
| sky130hd/ISPD2006_adaptec4          |                876.87 |             5422 |                10.12 |              26 |
| sky130hd/ISPD2006_adaptec5          |               1318.44 |             6712 |                12.98 |              26 |
| sky130hd/ISPD2006_bigblue1          |                734.37 |             4108 |                10.47 |              24 |
| sky130hd/ISPD2006_bigblue2          |               1269.62 |             4304 |                12.14 |              22 |
| sky130hd/ISPD2006_bigblue3          |               2870.04 |            16870 |                10.08 |              26 |
| sky130hd/ISPD2006_bigblue4          |               3370.62 |            16582 |                15.09 |              26 |
| sky130hd/ISPD2006_newblue1          |                492.84 |             3776 |                 8.57 |              25 |
| sky130hd/ISPD2006_newblue2          |               2853.07 |            15276 |                12.51 |              26 |
| sky130hd/ISPD2006_newblue3          |                419.11 |             2413 |                 9.6  |              25 |
| sky130hd/ISPD2006_newblue4          |               2029.4  |            10320 |                 9.93 |              26 |
| sky130hd/ISPD2006_newblue5          |                215.79 |             1152 |                13.22 |              26 |
| sky130hd/ISPD2006_newblue6          |                878.14 |             5107 |                15.84 |              26 |
| sky130hd/ISPD2006_newblue7          |               1806.75 |             9804 |                11.62 |              26 |
| sky130hd/ISPD2011_superblue10       |                 70.83 |              267 |                10.64 |              23 |
| sky130hd/ISPD2011_superblue12       |                 30.99 |              139 |                18.11 |              21 |
| sky130hd/ISPD2011_superblue15       |                 35.43 |              104 |                18.52 |              24 |
| sky130hd/ISPD2011_superblue18       |                 51.89 |              188 |                15.17 |               6 |
| sky130hd/ISPD2011_superblue1        |                 61.99 |              306 |                12.05 |              27 |
| sky130hd/ISPD2011_superblue2        |                 66.27 |              327 |                13.87 |              23 |
| sky130hd/ISPD2011_superblue4        |                194.99 |              523 |                29.55 |              19 |
| sky130hd/ISPD2011_superblue5        |                 88.15 |              453 |                18.91 |              21 |
| sky130hs/DAC2012_superblue11        |                369.53 |             2480 |                11.22 |              26 |
| sky130hs/DAC2012_superblue12        |                 27.89 |              140 |                 8.79 |              37 |
| sky130hs/DAC2012_superblue14        |                 84.45 |              449 |                11.76 |              36 |
| sky130hs/DAC2012_superblue16        |                 32.65 |              144 |                 6.84 |              27 |
| sky130hs/DAC2012_superblue19        |                 48.25 |              275 |                13.39 |              13 |
| sky130hs/DAC2012_superblue2         |                 58.05 |              327 |                10.12 |              18 |
| sky130hs/DAC2012_superblue3         |                 59.38 |              495 |                 8.39 |              20 |
| sky130hs/DAC2012_superblue5         |                 60.57 |              452 |                17.53 |              13 |
| sky130hs/DAC2012_superblue6         |                117.18 |              862 |                11.61 |              23 |
| sky130hs/DAC2012_superblue7         |                 35.69 |              210 |                16.19 |              10 |
| sky130hs/DAC2012_superblue9         |                 55.25 |              319 |                10.98 |              16 |
| sky130hs/ISPD2006_adaptec1          |                144.14 |              846 |                 8.16 |              26 |
| sky130hs/ISPD2006_adaptec2          |                419.71 |             3400 |                 6.31 |              25 |
| sky130hs/ISPD2006_adaptec3          |                545.85 |             3925 |                 9.27 |              26 |
| sky130hs/ISPD2006_adaptec4          |                704.69 |             5419 |                 8.44 |              26 |
| sky130hs/ISPD2006_adaptec5          |               1010.99 |             6682 |                 9.13 |              26 |
| sky130hs/ISPD2006_bigblue1          |                597.81 |             4098 |                 7.87 |              26 |
| sky130hs/ISPD2006_bigblue2          |                866.63 |             4314 |                10.02 |              26 |
| sky130hs/ISPD2006_bigblue3          |               2266.2  |            16801 |                 8.87 |              26 |
| sky130hs/ISPD2006_bigblue4          |               2579.79 |            16625 |                 9.87 |              26 |
| sky130hs/ISPD2006_newblue1          |                388.33 |             3800 |                 7.57 |              22 |
| sky130hs/ISPD2006_newblue2          |               2149.87 |            15200 |                 8.74 |              26 |
| sky130hs/ISPD2006_newblue3          |                411.92 |             2387 |                 8.99 |              26 |
| sky130hs/ISPD2006_newblue4          |               1646.6  |            10340 |                 7.39 |              26 |
| sky130hs/ISPD2006_newblue5          |                150.39 |             1136 |                 8.73 |              26 |
| sky130hs/ISPD2006_newblue6          |                715.32 |             5057 |                10.7  |              26 |
| sky130hs/ISPD2006_newblue7          |               1425.84 |             9694 |                 9.72 |              26 |
| sky130hs/ISPD2011_superblue10       |                 64.98 |              266 |                 9.22 |              26 |
| sky130hs/ISPD2011_superblue12       |                 27.89 |              140 |                 8.79 |              37 |
| sky130hs/ISPD2011_superblue15       |                 24.16 |              122 |                 9.86 |              19 |
| sky130hs/ISPD2011_superblue18       |                 45.84 |              187 |                10.88 |               6 |
| sky130hs/ISPD2011_superblue1        |                 54.78 |              307 |                 8.8  |              31 |
| sky130hs/ISPD2011_superblue2        |                 58.05 |              327 |                10.12 |              18 |
| sky130hs/ISPD2011_superblue4        |                 88.29 |              546 |                10.86 |              23 |
| sky130hs/ISPD2011_superblue5        |                 60.57 |              452 |                17.53 |              13 |
