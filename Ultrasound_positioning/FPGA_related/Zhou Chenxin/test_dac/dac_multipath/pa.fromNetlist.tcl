
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name dac_multipath -dir "C:/Users/SJTU/Desktop/Zhou Chenxin/test_dac/dac_multipath/planAhead_run_1" -part xc5vlx50tff1136-2
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/SJTU/Desktop/Zhou Chenxin/test_dac/dac_multipath/main.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/SJTU/Desktop/Zhou Chenxin/test_dac/dac_multipath} }
set_property target_constrs_file "main.ucf" [current_fileset -constrset]
add_files [list {main.ucf}] -fileset [get_property constrset [current_run]]
link_design
