# add_cppcheck_target(cpp_target [suppress_file1 suppress_file2 ...])
#
# Create a target named `${cpp_target}_cppcheck` to run cppcheck on the source
# files that are part of cpp_target, suppressing messages from files that
# follow the target name; add it as a dependency of the `cppcheck` target.
#
# Only include directories inside the current `PROJECT_SOURCE_DIR` are added.
# This function has to be called in the same file where the target is defined.
#
# External requirements:
#
#     - cppcheck
#
# Example:
#
#     # Create `newtarget` target.
#     add_executable(newtarget newtarget.h newtarget.cpp anotherfile.cpp)
#
#     # Create `newtarget_cppcheck` target and add it to `cppcheck`,
#     # suppressing messages from `anotherfile.cpp`.
#     add_cppcheck_target(newtarget anotherfile.cpp)
#

find_program(CPPCHECK cppcheck)

if(CPPCHECK)
    message("** Found cppcheck")

    add_custom_target(cppcheck)

    function(add_cppcheck_target cpp_target)
        # Convert extra arguments into a list.
        set(ignored_files "")
        foreach(name ${ARGN})
            get_filename_component(name ${name} REALPATH)
            list(APPEND excluded_files ${name})
            set(suppressed_files --suppress=*:${name} ${suppressed_files})
        endforeach()

        get_target_property(cpp_srcs ${cpp_target} SOURCES)

        set(cpp_src_list "")
        foreach(src_file ${cpp_srcs})
            get_filename_component(src_file ${src_file} REALPATH)
            list(FIND excluded_files ${src_file} file_index)
            if(${file_index} EQUAL -1)
                set(cpp_src_list ${cpp_src_list} ${src_file})
            endif()
        endforeach(src_file)

        get_target_property(cpp_inc_dirs ${cpp_target} INCLUDE_DIRECTORIES)

        set(cpp_inc_list "")
        foreach(inc_dir ${cpp_inc_dirs})
            # Check if directory is inside current project.
            string(FIND "${inc_dir}" "${PROJECT_SOURCE_DIR}" INDEX)
            if(INDEX EQUAL 0)
                # Directory is inside project, add it to includes.
                set(cpp_inc_list -I${inc_dir} ${cpp_inc_list})
            endif(INDEX EQUAL 0)
        endforeach(inc_dir)

        add_custom_target(
            "${cpp_target}_cppcheck"
            COMMAND echo ""
            COMMAND echo "-- cppcheck report for ${cpp_target}: --"
            COMMAND cppcheck
                --error-exitcode=1
                --force
                --quiet
                --inline-suppr
                --enable=all
                --suppress=missingIncludeSystem
                ${suppressed_files}
                ${cpp_inc_list}
                ${cpp_src_list}
            COMMAND echo "--  End of report for ${cpp_target}.  --"
            COMMAND echo ""
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        )

        add_dependencies(cppcheck "${cpp_target}_cppcheck")
    endfunction(add_cppcheck_target)
else(CPPCHECK)
    message("** cppcheck not found")

    function(add_cppcheck_target cpp_target)
        message("** add_cppcheck_target: target ${name}_cppcheck not created")
    endfunction(add_cppcheck_target)
endif(CPPCHECK)
