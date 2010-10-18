proc TextEditSave {w filepath} {
    if [ catch {open $filepath {WRONLY CREAT TRUNC} 0666} fd ] {
	puts stderr "Failed to save $filepath: $fd"
	return
    }
    puts -nonewline $fd [$w.textarea.text get 1.0 end]
    flush $fd
    close $fd

    # Restore normal attributes
    set normalBg [$w.buttons.cancel cget -bg]
    set normalFg [$w.buttons.cancel cget -fg]
    set activeBg [$w.buttons.cancel cget -activebackground]
    set activeFg [$w.buttons.cancel cget -activeforeground]
    $w.buttons.ok configure -bg $normalBg -fg $normalFg \
	-activebackground $activeBg -activeforeground $activeFg
    $w.buttons.save configure -bg $normalBg -fg $normalFg \
	-activebackground $activeBg -activeforeground $activeFg
}

proc TextEditOk {w filepath} {
    TextEditSave $w $filepath
    destroy $w
}

proc TextEditModified {w text} {
    if [$text edit modified] {
	# Set attributes of modified text contents
	set modifiedFg white
	set modifiedBg red
	$w.buttons.ok configure -bg $modifiedBg -fg $modifiedFg \
	    -activebackground $modifiedBg -activeforeground $modifiedFg
	$w.buttons.save configure -bg $modifiedBg -fg $modifiedFg \
	    -activebackground $modifiedBg -activeforeground $modifiedFg
	$text edit modified 0
    }
}

# Tag text which matches given regular expression
proc TextRegexpHighlight {t re tag} {
    set cur 1.0
    while 1 {
	set cur [$t search -regexp -count length $re $cur end]
	if {$cur == ""} {
	    break
	}
	$t tag add $tag $cur "$cur + $length char"
	set cur [$t index "$cur + $length char"]
    }
}

proc TextSyntaxHighlight {ftype t} {
    global TextEditTags
    foreach tag $TextEditTags {
    $t tag remove $tag 0.0 end
    }

    switch -exact $ftype {
	NeuralNet -
	TrFunc {
	    TextRegexpHighlight $t {;.*$} comment
	    TextRegexpHighlight $t {^[:space:]*\[.*\]} section
	}
	ProgParams {
	    TextRegexpHighlight $t {^\s*\#.*$} comment
	    TextRegexpHighlight $t {^\s*\w+\s*=.*$} parline
	}
    }
}

# w - parent
# title - text to show
# filepath - name of variable where to store filename
proc TextEditWindow {p title filepath} {
    if { [file exists $filepath] && ! [file isfile $filepath] } {
	puts "$filepath is not a file!"
	return
    }
    if [ catch {open $filepath {RDWR CREAT} 0666} fd ] {
	puts stderr "Failed to open/create $filepath: $fd"
	return
    }

    switch -exact [file extension $filepath] {
	".par" {
	    set ftype ProgParams
	}
	".tf" -
	".cof" {
	    set ftype TrFunc
	}
	".nnp" -
	".nnc" -
	".nn" {
	    set ftype NeuralNet
	}
	default {
	    set ftype Undefined
	}
    }

    set w $p.textedit
    catch {destroy $w}
    toplevel $w
    wm title $w $title

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text "OK" -command "TextEditOk $w $filepath"
    button $w.buttons.save -text "Save" -command "TextEditSave $w $filepath"
    button $w.buttons.cancel -text "Cancel" -command "destroy $w"
    pack $w.buttons.ok $w.buttons.save $w.buttons.cancel -side left -expand 1

    set f [frame $w.textarea]
    text $f.text -relief sunken -bd 2 -wrap none \
	-xscrollcommand "$f.xscroll set" \
	-yscrollcommand "$f.yscroll set" \
	-setgrid 1 -width 40 -height 15 -undo 1 -autosep 1
    scrollbar $f.xscroll -orient horizontal -command "$f.text xview"
    scrollbar $f.yscroll -orient vertical -command "$f.text yview"
    grid $f.text $f.yscroll -sticky news
    grid $f.xscroll -sticky news
    grid rowconfigure $f 0 -weight 1
    grid columnconfigure $f 0 -weight 1
    pack $f -side top -fill both -expand true

    $f.text insert 1.0 [read -nonewline $fd]
    close $fd

    # Define tags to highlight syntax
    global TextEditTags
    set TextEditTags {comment section parline}
    $f.text tag configure comment -foreground DarkGreen
    $f.text tag configure section -foreground DarkRed
    $f.text tag configure parline -foreground NavyBlue

    # Make the first syntax highlight
    TextSyntaxHighlight $ftype $f.text 

    $f.text edit modified 0
    bind $f.text <<Modified>> \
	"TextEditModified $w %W ; TextSyntaxHighlight $ftype %W"
}

# test
#TextEditWindow "" "Text editor title" "testdata/plant.tf"
#TextEditWindow "" "Text editor title" "testdata/dcsloop.par"
#TextEditWindow "" "Text editor title" "testdata/res.nnc"
