" Example file for Vim plugin for multi-dimensional array manipulation
" Language:    vim script
" Maintainer:  Dave Silvia <dsilvia@mchsi.com>
" Date:        7/16/2004
"

ARRAYDEL g:addrbk:
ARRAYDEL b:frank:
ARRAYNEW g:addrbk: 10:2:3:
			\ Dave,1010\ Silicon\ Way,123\ Elm\ St.,5552447\ x300,5552355,5554663,
			\John,1010\ Silicon\ Way,986\ Walnut\ Grove,5552447\ x304,5551776,5552004,
			\Frank,1180\ Industry\ Park,836\ Cherry\ Ave.,5551212,5552355,5554663,
			\Harry,1180\ Industry\ Park,7734\ Dogwood,5551212,<Nul>,5553320
ARRAYSET g:addrbk:4: Debbie,1010\ Silicon\ Way,<Nul>,5552447\ x314
" all info
ARRAYGET g:addrbk:2:
" just phones
ARRAYGET g:addrbk:2:1:
" business address
ARRAYGET g:addrbk:2:0:1:
" home address
ARRAYGET g:addrbk:2:0:2:
ARRAYCPY g:addrbk:2: b:frank:
ARRAYGET b:frank:
" execute these commands with an index #
command! -nargs=* AllInfo ARRAYGET g:addrbk:<args>:
command! -nargs=* Phones echo g:addrbk:<args>:0:0: | ARRAYGET g:addrbk:<args>:1:
command! -nargs=* BusAddr echo g:addrbk:<args>:0:0: | ARRAYGET g:addrbk:<args>:0:1:
command! -nargs=* HomeAddr echo g:addrbk:<args>:0:0: | ARRAYGET g:addrbk:<args>:0:2:
" execute this command with a name
" optional second argument of phone, bus, or home
command! -nargs=* GetEntry call s:getEntry(<f-args>)

function! s:getEntry(name,...)
	let dims=ArrayDim("g:addrbk:")
	let entries=strpart(dims,0,match(dims,' X '))
	while entries > 0
		let index=entries-1
		let entry='g:addrbk:'.index.':0:0:'
		if {entry} ==? a:name
			break
		endif
		let entries=entries-1
	endwhile
	if !entries
		echomsg a:name." not found in g:addrbk:"
		return
	endif
	let entry='g:addrbk:'.index.":"
	if a:0
		if a:1 ==? "phone"
			let entry=entry."1:"
		elseif a:1 ==? "bus"
			let entry=entry."0:1:"
		elseif a:1 ==? "home"
			let entry=entry."0:2:"
		endif
	endif
	call ArrayGet(entry)
endfunction
