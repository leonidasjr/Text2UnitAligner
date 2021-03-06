# (c) Text2UnitAligner.psc, version 0.01
# Script implemented by Leônidas Silva Jr (UEPB-UNICAMP/CNPq)
# for forced alignment from a raw text into words and IPA phones
# Copyright (C) 2022, Silva Jr., Leônidas

#####----------------------- HOW TO CITE -----------------------------############## 
###-SILVA Jr., Leônidas (2022). Text2UnitAligner. Computer program for Praat (v0.01)-###

form Praat aligner
	comment The threshold value is for the determination of the onset/offset of the text.
	real Threshold_(dB) 40
	comment Which language is your audio and text to be aligned? 
	choice Language 2
		button English (US)
		button Portuguese (Brazil)
		boolean Save_TextGrid 0
endform

Create Strings as file list... audioDataList *.wav
numberOfFiles = Get number of strings
for y from 1 to numberOfFiles
	select Strings audioDataList
	soundname$ = Get string... y
	Read from file... 'soundname$'
	sound_file$ = selected$("Sound")
	text$ = sound_file$ + ".txt"
	text$ = readFile$(text$)

	select Sound 'sound_file$'
	Edit
	editor Sound 'sound_file$'
		Intensity settings... 40 100 "mean energy" yes
		Close
	endeditor

	select Sound 'sound_file$'
		To TextGrid: "sentence", ""
	select Sound 'sound_file$'
		To Intensity... 100 0 0 yes 
		nframes = Get number of frames
	for k from 1 to nframes
		int = Get value in frame: k
		if int > 'threshold'
			time = Get time from frame: k
			select TextGrid 'sound_file$'
			Insert boundary: 1, time
		endif
		select Intensity 'sound_file$'
	endfor

	select TextGrid 'sound_file$'
	b = 3
	repeat
		intervals = Get number of intervals: 1
		Remove left boundary: 1, b
		intervals = Get number of intervals: 1
	until b = intervals
	Set interval text: 1, 2, text$

	# Write to text file... 'sound_file$'.TextGrid
	select Sound 'sound_file$'
		plus TextGrid 'sound_file$'
	if language = 1
	select Sound 'sound_file$'
			plus TextGrid 'sound_file$'
		View & Edit
		editor TextGrid 'sound_file$'
		Alignment settings: "Portuguese (Brazil)", "yes", "yes", "yes"
		Align interval
		Close
		endeditor
	elsif language = 2
	select Sound 'sound_file$'
			plus TextGrid 'sound_file$'
		View & Edit
		editor TextGrid 'sound_file$'
		Alignment settings: "English (America)", "yes", "yes", "yes"
		Align interval
		Close
		endeditor	
	endif
	select TextGrid 'sound_file$'
		Set tier name: 1, "Text"
		Set tier name: 2, "Words"
		Set tier name: 3, "Phones"
	select Intensity 'sound_file$'
	Remove

	if save_TextGrid = 1
		select TextGrid 'sound_file$'
		Write to text file... 'sound_file$'.TextGrid
	endif
endfor

select all
tg_objects = numberOfSelected ("TextGrid")
selectObject()
writeInfoLine: 'tg_objects', " TextGrid files were created successfully."
