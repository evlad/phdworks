# unlist listValue outVar0 outVar1 ...
# Implies [lindex $listValue 0] -> outVar0
#         [lindex $listValue 1] -> outVar1
# and so on.
# Returns number of assigned variables
proc unlist {listValue args} {
    set i 0
    foreach param $args {
	if { $i >= [llength $listValue] } { return $i }
	#puts "-> $param"
	upvar 1 $param outVar
	set outVar [lindex $listValue $i]
	incr i
    }
    return $i
}
