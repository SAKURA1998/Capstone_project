
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name test -dir "C:/Users/SJTU/Desktop/Zhou Chenixn/test/test/planAhead_run_4" -part xc5vlx50tff1136-2
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/SJTU/Desktop/Zhou Chenixn/test/test/test.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/SJTU/Desktop/Zhou Chenixn/test/test} {ipcore_dir} }
add_files [list {ipcore_dir/sin.ncf}] -fileset [get_property constrset [current_run]]
set_param project.pinAheadLayout  yes
set_property target_constrs_file "test.ucf" [current_fileset -constrset]
add_files [list {test.ucf}] -fileset [get_property constrset [current_run]]
link_design
