
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name test -dir "C:/Users/SJTU/Desktop/test/test/planAhead_run_1" -part xc5vlx50tff1136-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "test.ucf" [current_fileset -constrset]
add_files [list {ipcore_dir/sin.ngc}]
set hdlfile [add_files [list {ipcore_dir/sin.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {test.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top test $srcset
add_files [list {test.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/sin.ncf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc5vlx50tff1136-2
