#-------------------------------------------------------------------------------
# @file      run.do
# @author    Saba Janamian
# @date      11/17/2025
#
# @brief     Simulation do file for testing Width Converter module
#
# @section changelog
# - 11/17/2025: Saba Janamian - Initial implementation
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Questa Lib config
#-------------------------------------------------------------------------------
set origin_dir [file normalize "."]
set build_folder ${origin_dir}/build
set work_lib_folder "${build_folder}/work"

#-------------------------------------------------------------------------------
# TB config
#-------------------------------------------------------------------------------

set src_folder [file normalize "../src"]
set src_file "${src_folder}/sec_lowest.sv"
set testbench_folder [file normalize "."]/tb
set testbench_file   ${testbench_folder}/sec_lowest_tb.sv
set testbench_module "sec_lowest_tb"


if {![file exists $build_folder]} {
    file mkdir $build_folder
}

proc compile_hdl_files {source_folder target_lib} {
    set file_list {}

    foreach pattern {*.sv *.v *.vhd} {
        set file_list [concat $file_list [glob -nocomplain -directory $source_folder -type f $pattern]]
        set file_list [concat $file_list [glob -nocomplain -directory $source_folder -type f **/$pattern]]
    }

    foreach file $file_list {
        set hdl_file [file normalize ${file}]
        vlog -sv +acc -work ${target_lib} ${hdl_file}
    }
}
#-------------------------------------------------------------------------------
# Generate QuestaSim working library
#-------------------------------------------------------------------------------
if {[file exists ${work_lib_folder}/_info]} {
   echo "INFO: Simulation library ${work_lib_folder} already exists"
} else {
   file delete -force ${work_lib_folder}
   vlib ${work_lib_folder}
}

#-------------------------------------------------------------------------------
# Map Logical lib name to physical directory path
#-------------------------------------------------------------------------------
vmap work          ${work_lib_folder}

#-------------------------------------------------------------------------------
# Compile sources
#-------------------------------------------------------------------------------

vlog -sv +acc -work ${work_lib_folder} ${src_file}
vlog "+incdir+${testbench_folder}" -sv +acc -work ${work_lib_folder} ${testbench_file}

vsim -L work \
     -t 1ps \
     +acc \
     "work.${testbench_module}"

source ./wave.do

restart -force

run -all
