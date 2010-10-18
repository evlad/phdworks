# Assign all parameters set in $params list {name1 value1 name2 value2
# ...} to fields in $filepath saving structure of the file and comments.

proc ParFileAssign {filepath params} {
    file rename -force $filepath $filepath.bak
    if [catch {open $filepath.bak r} fd1] {
	puts stderr "Failed to read $filepath.bak"
	return
    }
    if [catch {open $filepath w} fd2] {
	puts stderr "Failed to create $filepath"
	close $fd1
	return
    }

    # Make associative array for fast search and fetch
    array set parArray $params

    # Scan all lines of the file and substitute value from params if
    # name matches
    set fileContents [split [read $fd1] \n]
    close $fd1
    set lineNo 0
    foreach line $fileContents {
	incr lineNo
	switch -regexp -- $line {
	    {^\s*#.*$} {
		# Comment line - leave it as is
	    }
	    {^\s*$} {
		# Empty line - leave it as is
	    }
	    {^\s*\w+\s*=.*$} {
		# Parameter name = value - lets try to find substitute
		if {[regexp {\s*(\w+)\s*=\s*(.*)$} $line input name value]} {
		    if {[info exist parArray($name)]} {
			# Let's replace by new value
			set line "$name = $parArray($name)"
		    }
		}
	    }
	    default {
		# Something strange - leave it as is or produce warning
		puts stderr "$filepath:$lineNo: suspicious line '$line'"
	    }
	} 
	puts $fd2 $line
    }
    close $fd2
    file delete $filepath.bak
}

proc ParFileAssignTest {} {
    set params {aa 177 dd "another text"}

    file copy -force testdata/orig.test.par testdata/test.par
    ParFileAssign testdata/test.par $params
}

ParFileAssignTest
