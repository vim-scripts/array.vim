" Vim plugin for multi-dimensional array manipulation
" Language:    vim script
" Maintainer:  Dave Silvia <dsilvia@mchsi.com>
" Date:        7/16/2004
"

command! -nargs=* ARRAYSYN :call ArrayCmdSyntax(<f-args>)
command! -nargs=* ARRAYUSE :call ArrayCmdUse(<f-args>)
command! -nargs=0 ARRAYMAN :call ArrayManual()
command! -nargs=+ ARRAYNEW :call ArrayNew(<f-args>)
command! -nargs=+ ARRAYSET :call ArraySet(<f-args>)
command! -nargs=+ ARRAYGET :call ArrayGet(<f-args>)
command! -nargs=+ ARRAYCPY :call ArrayCpy(<f-args>)
command! -nargs=* ARRAYDIM :call s:CmdArrayDim(<f-args>)
command! -nargs=1 ARRAYDEL :call ArrayDel(<f-args>)


" buffer local variables

if !exists("g:arrayInitVal")
	let g:arrayInitVal='<Nul>'
endif
if !exists("g:arrayVerboseMsg")
	let g:arrayVerboseMsg=1
endif
if !exists("b:cmdExampleTitle")
	let b:cmdExampleTitle='Title'
endif
if !exists("b:cmdDispColor")
	let b:cmdDispColor='Statement'
endif
if !exists("b:cmdDescColor")
	let b:cmdDescColor='Identifier'
endif
if !exists("b:manDispColor")
	let b:manDispColor='Identifier'
endif
if !exists("b:manCmdColor")
	let b:manCmdColor='Statement'
endif
if !exists("b:manArgColor")
	let b:manArgColor='PreProc'
endif
if !exists("b:manEmphColor")
  if has("gui_running")
		let b:manEmphColor='Type'
	else
		let b:manEmphColor='NonText'
	endif
endif


" script local functions and variables

let s:thisScript=expand("<sfile>:t")


function! s:syntaxError()
	call DispErr(" COMMAND SYNTAX ERROR:")
	call DispWarn(" Use 'ARRAYSYN' or 'ARRAYSYN <command-name>'")
	call DispWarn("   to display command syntax and description")
	call DispWarn(" Use 'ARRAYUSE' or 'ARRAYUSE <command-name>'")
	call DispWarn("   to display command syntax only")
	call DispWarn(" Use 'ARRAYMAN' for help/tutorial")
endfunction

function! s:arraymanSyntax(dispAll)
	execute 'echohl '.b:cmdDispColor
	echo "ARRAYMAN"
	if a:dispAll
		execute 'echohl '.b:cmdDescColor
		echo "    displays a help/tutorial text"
	endif
	echohl None
endfunction

function! s:acmduseSyntax(dispAll)
	execute 'echohl '.b:cmdDispColor
	echo "ARRAYUSE [command]"
	if a:dispAll
		execute 'echohl '.b:cmdDescColor
		echo "    command    optional command for syntax and description display"
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYUSE"
		execute 'echohl '.b:cmdDescColor
		echo "    displays syntax and description for all commands"
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYUSE ARRAYNEW"
		execute 'echohl '.b:cmdDescColor
		echo "    displays syntax and description for 'ARRAYNEW' command"
	endif
	echohl None
endfunction

function! s:acmdsynSyntax(dispAll)
	execute 'echohl '.b:cmdDispColor
	echo "ARRAYSYN [command]"
	if a:dispAll
		execute 'echohl '.b:cmdDescColor
		echo "    command    optional command for syntax display"
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYSYN"
		execute 'echohl '.b:cmdDescColor
		echo "    displays syntax for all commands"
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYSYN ARRAYNEW"
		execute 'echohl '.b:cmdDescColor
		echo "    displays syntax for 'ARRAYNEW' command"
	endif
	echohl None
endfunction

function! s:arraynewSyntax(dispAll)
	execute 'echohl '.b:cmdDispColor
	echo "ARRAYNEW decl size [init] [s]"
	if a:dispAll
		execute 'echohl '.b:cmdDescColor
		echo "    decl       <scope>:<name>: (- note - ends with ':')"
		echo "    size       <dimension>:<dimension>...: (- note - ends with ':')"
		echo "    init       optional comma separated list of values"
		echo "    s          optional switch to indicate init is string"
		echo "               not a comma separated list"
		echo " "
		echo "    scope      one of 'b w g' for 'buffer', 'window', and 'global'"
		echo "               scope, respectively."
		echo "    name       unique name within the scope."
		echo "    dimension  size of the array in the indicated dimension."
		echo "               must be a non-zero, positive integer."
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYNEW g:myArray: 2:3: 1,2,3,4,5,6"
		execute 'echohl '.b:cmdDescColor
		echo "    denotes a global 2 dimensional array named 'myArray', 2 X 3,"
		echo "    initialized to:"
		echo "        	1	2	3"
		echo "        	4	5	6"
		echo " "
		echo "    NOTE: if more values than array elements, the remaining"
		echo "          values are unused.  If more elements than values, the"
		echo "          remaining elements are initialized to g:arrayInitVal"
		echo "          (default: '<Nul>')"
	endif
	echohl None
endfunction

function! s:arraydimSyntax(dispAll)
	execute 'echohl '.b:cmdDispColor
	echo "ARRAYDIM decl"
	if a:dispAll
		execute 'echohl '.b:cmdDescColor
		echo "    decl       <scope>:<name>:[<index>:...:]"
		echo " "
		echo "    scope      one of 'b w g' for 'buffer', 'window', and 'global'"
		echo "               scope, respectively."
		echo "    name       unique name within the scope."
		echo "    index      optional index of a sub array."
		echo "               Note: arrays are zero base indexed."
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example: (for an array created as 2:3:4:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYDIM g:myArray:"
		execute 'echohl '.b:cmdDescColor
		echo "    returns the string '2 X 3 X 4'"
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example: (for an array created as 2:3:4:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYDIM g:myArray:1:"
		execute 'echohl '.b:cmdDescColor
		echo "    returns the string '3 X 4'"
	endif
	echohl None
endfunction

function! s:arraysetSyntax(dispAll)
	execute 'echohl '.b:cmdDispColor
	echo "ARRAYSET decl val [s]"
	if a:dispAll
		execute 'echohl '.b:cmdDescColor
		echo "    decl       <scope>:<name>:[<index>:...:]"
		echo "    val        comma separated list of set values"
		echo "    s          optional switch to indicate val is string"
		echo "               not a comma separated list"
		echo " "
		echo "    scope      one of 'b w g' for 'buffer', 'window', and 'global'"
		echo "               scope, respectively."
		echo "    name       unique name within the scope."
		echo "    index      optional index of a sub array."
		echo "               Note: arrays are zero base indexed."
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYSET g:myArray: 2,4,5,7"
		execute 'echohl '.b:cmdDescColor
		echo "    sets the first 4 values in g:myArray:"
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYSET g:myArray:0: 2,4,5,7"
		execute 'echohl '.b:cmdDescColor
		echo "    sets the first 4 values in the sub array g:myArray:0:"
		echo " "
		echo "    NOTE: if more values than array elements, the remaining"
		echo "          values are unused."
	endif
	echohl None
endfunction

function! s:arraygetSyntax(dispAll)
	execute 'echohl '.b:cmdDispColor
	echo "ARRAYGET decl [var]"
	if a:dispAll
		execute 'echohl '.b:cmdDescColor
		echo "    decl       <scope>:<name>:[<index>:...:]"
		echo "    var        optional comma separated list of get variables"
		echo "               if not specified, output is to command line"
		echo " "
		echo "    scope      one of 'b w g' for 'buffer', 'window', and 'global'"
		echo "               scope, respectively."
		echo "    name       unique name within the scope."
		echo "    index      optional index of a sub array."
		echo "               Note: arrays are zero base indexed."
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYGET g:myArray: g:val,b:val,w:val"
		execute 'echohl '.b:cmdDescColor
		echo "    gets the first 3 values in g:myArray: and places them in the"
		echo "    listed variables."
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYGET g:myArray:0: g:val,b:val,w:val"
		execute 'echohl '.b:cmdDescColor
		echo "    gets the first 3 values in the sub array g:myArray:0: and"
		echo "    places them in the listed variables."
		echo " "
		echo "    NOTE: scope letter must be specified and be one of 'b w g'"
		echo "          if more variables than array elements, the remaining"
		echo "          variables are undefined."
	endif
	echohl None
endfunction

function! s:arraycpySyntax(dispAll)
	execute 'echohl '.b:cmdDispColor
	echo "ARRAYCPY srcdecl dstdecl"
	if a:dispAll
		execute 'echohl '.b:cmdDescColor
		echo "    srcdecl    <scope>:<name>:[<index>:...:]"
		echo "    dstdecl"
		echo " "
		echo "    scope      one of 'b w g' for 'buffer', 'window', and 'global'"
		echo "               scope, respectively."
		echo "    name       unique name within the scope."
		echo "    index      optional index of a sub array."
		echo "               Note: arrays are zero base indexed."
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYCPY g:myArray: b:myCopy:"
		execute 'echohl '.b:cmdDescColor
		echo "    copies g:myArray: to b:myCopy:"
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYCPY g:myArray:0: b:myCopy:"
		execute 'echohl '.b:cmdDescColor
		echo "    copies sub array g:myArray:0: to b:myCopy:"
		echo " "
		echo "    NOTE: scope letter must be specified and be one of 'b w g'"
		echo "          if more variables than array elements, the remaining"
		echo "          variables are undefined."
	endif
	echohl None
endfunction

function! s:arraydelSyntax(dispAll)
	execute 'echohl '.b:cmdDispColor
	echo "ARRAYDEL decl"
	if a:dispAll
		execute 'echohl '.b:cmdDescColor
		echo "    decl       <scope>:<name>:"
		echo " "
		echo "    scope      one of 'b w g' for 'buffer', 'window', and 'global'"
		echo "               scope, respectively."
		echo "    name       unique name within the scope."
		echo " "
		execute 'echohl '.b:cmdExampleTitle
		echo "  Example:"
		execute 'echohl '.b:cmdDispColor
		echo "        ARRAYDEL g:myArray:"
		execute 'echohl '.b:cmdDescColor
		echo "    deletes all elements of g:myArray:"
		echo " "
		echo "  Note: Because arrays are symmetrical, sub array deletion is not"
		echo "        permitted."
	endif
	echohl None
endfunction

function! s:allSyntax(dispAll)
	call s:arraymanSyntax(a:dispAll)
	echo " "
	call s:acmdsynSyntax(a:dispAll)
	echo " "
	call s:acmduseSyntax(a:dispAll)
	echo " "
	call s:arraynewSyntax(a:dispAll)
	echo " "
	call s:arraysetSyntax(a:dispAll)
	echo " "
	call s:arraygetSyntax(a:dispAll)
	echo " "
	call s:arraycpySyntax(a:dispAll)
	echo " "
	call s:arraydimSyntax(a:dispAll) 
	echo " "
	call s:arraydelSyntax(a:dispAll)
endfunction

function! s:arrayRef(decl,dim,args,)
	execute 'let '.a:decl."type:='REFERENCE'"
	execute 'let '.a:decl."dim:=".a:dim
	execute 'let '.a:decl."='".a:args."'"
endfunction

function! s:baseName(decl)
	return matchstr(a:decl,'^\(b\|w\|g\):\(\w*\):')
endfunction

function! s:arrayDimension(decl)
	let thisLevel=a:decl
	let desc=''
	while exists(thisLevel) && exists(thisLevel."dim:")
		execute 'let thisDim='.thisLevel."dim:"
		let desc=desc.thisDim." X "
		let thisLevel=thisLevel."0:"
	endwhile
	return strpart(desc,0,match(desc,' X $'))
endfunction

function! s:getArrayRefs(decl)
	let aName=a:decl
	"execute "let refs=".aName
	let refs=aName
	let refs=refs.","
	let nextRef=''
	let lastRef=refs
	let aNameType=aName."type:"
	if exists(aNameType)
		let lastRef=''
		while exists(aNameType)
			let nextRef=''
			let lastRef=lastRef.refs
			while refs != ''
				let commaPos=match(refs,',')
				if commaPos != -1
					let thisRef=strpart(refs,0,commaPos)
					let refs=strpart(refs,commaPos+1)
				else
					let thisRef=refs
					let refs=''
				endif
				execute "let assignRef=".thisRef
				execute "let nextRef='".nextRef.assignRef.",'"
			endwhile
			let refs=nextRef
			let commaPos=match(refs,',')
			let thisRef=strpart(refs,0,commaPos)
			let aNameType=thisRef."type:"
		endwhile
	endif
	if match(lastRef,',$') == -1
		let lastRef=lastRef.","
	endif
	return lastRef
endfunction

function! s:getArrayElems(decl)
	let aName=a:decl
	execute "let value=".aName
	let nextVal=''
	let lastVal=value
	let aNameType=aName."type:"
	if exists(aNameType)
		while exists(aNameType)
			let nextVal=''
			let lastVal=value
			let aNameType=''
			while value != ''
				let commaPos=match(value,',')
				if commaPos != -1
					let thisVal=strpart(value,0,commaPos)
					let value=strpart(value,commaPos+1)
				else
					let thisVal=value
					let value=''
				endif
				let aNameType=thisVal."type:"
				let nextVal=nextVal.{thisVal}.","
			endwhile
			let value=nextVal
		endwhile
	else
		let lastVal=aName
	endif
	if match(lastVal,',$') == -1
		let lastVal=lastVal.","
	endif
	return lastVal
endfunction



" global functions


function! ArrayManual()
	runtime! plugin/arrayman
endfunction

function! DispMsg(msg)
	if !g:arrayVerboseMsg
		return
	endif
	echomsg s:thisScript.":".a:msg
endfunction

function! DispErr(msg)
	echohl ErrorMsg
	echomsg s:thisScript.":".a:msg
	echohl None
endfunction

function! DispWarn(msg)
	if !g:arrayVerboseMsg
		return
	endif
	echohl WarningMsg
	echomsg s:thisScript.":".a:msg
	echohl None
endfunction

function! ArrayCmdUse(...)
	let holdIC=&ic
	set noignorecase
	let dispAll=1
	if a:0
		if a:0 == 2
			let dispAll=a:2
		endif
		let cmdName=tolower(a:1)
		let cmdNameSynFunc="s:".cmdName."Syntax"
		if exists("*".cmdNameSynFunc)
			let callCmd="call ".cmdNameSynFunc."(".dispAll.")"
			execute callCmd
		else
			call DispErr(expand("<sfile>").": Unknown Command: <".a:1.">")
		endif
	else
		call s:allSyntax(dispAll)
	endif
	if holdIC
		set ignorecase
	endif
endfunction

function! ArrayCmdSyntax(...)
	if a:0
		call ArrayCmdUse(a:1,0)
	else
		call s:allSyntax(0)
	endif
endfunction

function! ArrayNew(decl,size,...)
	if match(a:decl,':$') == -1
		call DispErr(expand("<sfile>").": decl does not end with ':' <".a:decl.">")
		call s:syntaxError()
		return
	endif
	if match(a:size,':$') == -1
		call DispErr(expand("<sfile>").": size does not end with ':' <".a:size.">")
		call s:syntaxError()
		return
	endif
	if a:size == ':'
		call DispErr(expand("<sfile>").": no dimension size(s) specified <".a:size.">")
		call s:syntaxError()
		return
	endif
	if exists(a:decl)
		call DispErr(expand("<sfile>").": ".a:decl." exists - use ARRAYDEL ".a:decl." before attempting to create")
		return
	endif
	let aName=a:decl
	let dimArgs=a:size
	let colonPos=match(dimArgs,':')
	let dim=strpart(dimArgs,0,colonPos)
	let dimArgs=strpart(dimArgs,colonPos+1)
	while colonPos != -1
		if dim < 1
			call DispErr(expand("<sfile>").": dimension size must be a non-zero, positive integer <".a:size.">")
			return
		endif
		let colonPos=match(dimArgs,':')
		let dim=strpart(dimArgs,0,colonPos)
		let dimArgs=strpart(dimArgs,colonPos+1)
	endwhile
	let values=''
	let strArg=0
	if a:0
		let values=a:1
		if a:0 > 1
			if match(a:2,'s') != -1 || match(a:2,"s") != -1
				let strArg=1
			endif
		endif
	endif
	let dimArgs=a:size
	let colonPos=match(dimArgs,':')
	let dim=strpart(dimArgs,0,colonPos)
	let dimArgs=strpart(dimArgs,colonPos+1)
	let thisdim=0
	let assignto=''
	while thisdim < dim
		let assignto=assignto.aName.thisdim.":,"
		let thisdim=thisdim+1
	endwhile
	call s:arrayRef(aName,dim,strpart(assignto,0,match(assignto,',$')))
	let colonPos=match(dimArgs,':')
	let dim=strpart(dimArgs,0,colonPos)
	let dimArgs=strpart(dimArgs,colonPos+1)
	let thisdim=0
	while colonPos != -1
		let nextAssign=''
		let nextArgs=''
		while assignto != ''
			let commaPos=match(assignto,',')
			let theVar=strpart(assignto,0,commaPos)
			let theAssign=''
			while thisdim < dim
				let nextAssign=nextAssign.theVar.thisdim.":,"
				let nextArgs=nextArgs.theVar.thisdim.":,"
				let thisdim=thisdim+1
			endwhile
			call s:arrayRef(theVar,dim,strpart(nextArgs,0,match(nextArgs,',$')))
			let nextArgs=''
			let thisdim=0
			let assignto=strpart(assignto,commaPos+1)
		endwhile
		let assignto=nextAssign
		let colonPos=match(dimArgs,':')
		let dim=strpart(dimArgs,0,colonPos)
		let dimArgs=strpart(dimArgs,colonPos+1)
	endwhile
	let theVal=g:arrayInitVal
	while assignto != ''
		let commaPos=match(assignto,',')
		let theVar=strpart(assignto,0,commaPos)
		let assignto=strpart(assignto,commaPos+1)
		if values != ''
			if !strArg
				let commaPos=match(values,',')
				" BEGIN logic appears here and in ArraySet()
				while strpart(values,commaPos-1,1) == '\'
					let commaPos=match(values,',',commaPos+1)
				endwhile
				" END logic appears here and in ArraySet()
				if commaPos != -1
					let theVal=strpart(values,0,commaPos)
					let values=strpart(values,commaPos+1)
				else
					let theVal=values
					let values=''
				endif
				" BEGIN logic appears here and in ArraySet()
				if match(theVal,'\,') != -1
					let theVal=substitute(theVal,'\\,',',','')
				endif
				" END logic appears here and in ArraySet()
			else
				let theVal=strpart(values,0,1)
				let values=strpart(values,1)
			endif
		else
			let theVal=g:arrayInitVal
		endif
		" BEGIN logic appears here and in ArraySet()
		if IsVimNmr(theVal) || IsVimVar(theVal) == 1 || IsStrLit(theVal)
			" a number or a vim identifier with a value or a string literal
			let {theVar}=theVal
		else
			" a vim identifier with no value or an unknown
			execute 'let '.theVar."='".theVal."'"
		endif
		" END logic appears here and in ArraySet()
	endwhile
endfunction

function! ArrayDim(declStr)
	let isdecl=IsArrayDecl(a:declStr)
	if isdecl == 1
		return s:CmdArrayDim(a:declStr,'r')
	elseif isdecl == -1
		call DispErr(expand("<sfile>").": a:declStr <".a:declStr."> is a non-existing decl")
	else
		call DispErr(expand("<sfile>").": a:declStr <".a:declStr."> is an invalid decl")
	endif
	return ''
endfunction

function! s:CmdArrayDim(decl,...)
	let isdecl=IsArrayDecl(a:decl)
	if isdecl != 1
		if isdecl == -1
			call DispErr(expand("<sfile>").": a:decl <".a:decl."> is a non-existing decl")
		else
			call DispErr(expand("<sfile>").": a:decl <".a:decl."> is an invalid decl")
			call s:syntaxError()
		endif
		return
	endif
	if !a:0
		" Command interface - output to command line
		echo a:decl." ".s:arrayDimension(a:decl)
	else
		if match(a:1,'r') != -1
			" Function interface - return value
			if match(expand("<sfile>"),'\.\.') != -1
				" if called from function interface, '<sfile>' expansion will have a
				" '..' between this funtion name and previous function(s) name(s)
				return s:arrayDimension(a:decl)
			else
				" don't know who this is, but they look like a command interface and
				" returning a value just doesn't make sense
				echo a:decl." ".s:arrayDimension(a:decl)
			endif
		else
			" Command interface - output to argument variable
			let {a:1}=s:arrayDimension(a:decl)
		endif
	endif
endfunction

function! ArraySet(decl,values,...)
	let isdecl=IsArrayDecl(a:decl)
	if isdecl != 1
		if isdecl == -1
			call DispErr(expand("<sfile>").": a:decl <".a:decl."> is a non-existing decl")
		else
			call DispErr(expand("<sfile>").": a:decl <".a:decl."> is an invalid decl")
			call s:syntaxError()
		endif
		return
	endif
	let strArg= !a:0 ? 0 : ((match(a:1,'s') != -1 || match(a:1,"s")) ? 1 : 0)
	let values= strArg ? a:values : (match(a:values,',$') == -1) ? a:values."," : a:values
	let arrayElems=s:getArrayElems(a:decl)
	let commaPos=match(arrayElems,',')
	let elem1=strpart(arrayElems,0,commaPos)
	if elem1 == ''
		call DispErr(expand("<sfile>").": empty array - should use ARRAYDEL ".a:decl)
		return
	endif
	while arrayElems != '' && values != ''
		let commaPos=match(arrayElems,',')
		let theVar=strpart(arrayElems,0,commaPos)
		let arrayElems=strpart(arrayElems,commaPos+1)
		if !strArg
			let commaPos=match(values,',')
			" BEGIN logic appears here and in ArrayNew()
			while strpart(values,commaPos-1,1) == '\'
				let commaPos=match(values,',',commaPos+1)
			endwhile
			" END logic appears here and in ArrayNew()
			let theVal=strpart(values,0,commaPos)
			let values=strpart(values,commaPos+1)
			" BEGIN logic appears here and in ArrayNew()
			if match(theVal,'\,') != -1
				let theVal=substitute(theVal,'\\,',',','')
			endif
			" END logic appears here and in ArrayNew()
		else
			let theVal=strpart(values,0,1)
			let values=strpart(values,1)
		endif
		" BEGIN logic appears here and in ArrayNew()
		if IsVimNmr(theVal) || IsVimVar(theVal) == 1 || IsStrLit(theVal)
			" a number or a vim identifier with a value or a string literal
			let {theVar}=theVal
		else
			" a vim identifier with no value or an unknown
			execute 'let '.theVar."='".theVal."'"
		endif
		" END logic appears here and in ArrayNew()
	endwhile
endfunction

function! ArrayGet(decl,...)
	let isdecl=IsArrayDecl(a:decl)
	if isdecl != 1
		if isdecl == -1
			call DispErr(expand("<sfile>").": a:decl <".a:decl."> is a non-existing decl")
		else
			call DispErr(expand("<sfile>").": a:decl <".a:decl."> is an invalid decl")
			call s:syntaxError()
		endif
		return
	endif
	if a:0
		let vars=a:1
		if match(vars,',$') == -1
			let vars=vars.","
		endif
	else
		let vars=''
	endif
	let arrayElems=s:getArrayElems(a:decl)
	let commaPos=match(arrayElems,',')
	let elem1=strpart(arrayElems,0,commaPos)
	if elem1 == ''
		call DispErr(expand("<sfile>").": empty array - should use ARRAYDEL ".a:decl)
		return
	endif
	if vars != ''
		while vars != ''
			let commaPos=match(arrayElems,',')
			let arrayElem=strpart(arrayElems,0,commaPos)
			let arrayElems=strpart(arrayElems,commaPos+1)
			let commaPos=match(vars,',')
			let var=strpart(vars,0,commaPos)
			let vars=strpart(vars,commaPos+1)
			execute 'let '.var."=".arrayElem
		endwhile
	else
		let dispElems=''
		while arrayElems != ''
			let commaPos=match(arrayElems,',')
			let arrayElem=strpart(arrayElems,0,commaPos)
			let arrayElems=strpart(arrayElems,commaPos+1)
			let dispElems=dispElems." - ".{arrayElem}
		endwhile
		let dispElems=dispElems." - "
		echo dispElems
	endif
endfunction

function! ArrayCpy(srcdecl,dstdecl)
	let isdecl=IsArrayDecl(a:srcdecl)
	if isdecl != 1
		if isdecl == -1
			call DispErr(expand("<sfile>").": a:srcdecl <".a:srcdecl."> is a non-existing decl")
		else
			call DispErr(expand("<sfile>").": a:srcdecl <".a:srcdecl."> is an invalid decl")
			call s:syntaxError()
		endif
		return
	endif
	let isdecl=IsArrayDecl(a:dstdecl)
	if isdecl != -1
		if isdecl == 1
			call DispErr(expand("<sfile>").": a:dstdecl <".a:dstdecl."> is an existing decl")
		else
			call DispErr(expand("<sfile>").": a:dstdecl <".a:dstdecl."> is an invalid decl")
			call s:syntaxError()
		endif
		return
	endif
	let arrayElems=s:getArrayElems(a:srcdecl)
	let commaPos=match(arrayElems,',')
	let elem1=strpart(arrayElems,0,commaPos)
	if elem1 == ''
		call DispErr(expand("<sfile>").": empty array - should use ARRAYDEL ".a:srcdecl)
		return
	endif
	let dims=s:arrayDimension(a:srcdecl)
	if dims == ''
		call DispErr(expand("<sfile>").": srcdecl ".a:srcdecl." is not an array")
		return
	endif
	let size=''
	let dim=''
	let Xpos=match(dims,' X ')
	while dims != ''
		if Xpos == -1
			let dim=dims
			let dims=''
			let size=size.dim.":"
		else
			let dim=strpart(dims,0,Xpos)
			let size=size.dim.":"
			let dims=strpart(dims,Xpos+3)
			let Xpos=match(dims,' X ')
		endif
	endwhile
	call ArrayNew(a:dstdecl,size)
	while arrayElems != ''
		let commaPos=match(arrayElems,',')
		let srcelem=strpart(arrayElems,0,commaPos)
		let arrayElems=strpart(arrayElems,commaPos+1)
		let dstelem=a:dstdecl.strpart(srcelem,matchend(srcelem,a:srcdecl))
		execute 'let '.dstelem."=".srcelem
	endwhile
endfunction

function! ArrayDel(decl)
	let isdecl=IsArrayDecl(a:decl)
	if isdecl != 1
		if isdecl == -1
			call DispErr(expand("<sfile>").": a:decl <".a:decl."> is a non-existing decl")
		else
			call DispErr(expand("<sfile>").": a:decl <".a:decl."> is an invalid decl")
			call s:syntaxError()
		endif
		return
	endif
	let baseName=s:baseName(a:decl)
	if baseName != a:decl
		call DispErr(expand("<sfile>").": cannot delete sub arrays <".a:decl.">")
		return
	endif
	let arrayElems=s:getArrayElems(a:decl)
	let arrayRefs=s:getArrayRefs(a:decl)
	let unletDims=substitute(arrayRefs,',','dim: ','g')
	let unletTypes=substitute(arrayRefs,',','type: ','g')
	let unletRefs=substitute(arrayRefs,',',' ','g')
	let commaPos=match(arrayElems,',')
	let elem1=strpart(arrayElems,0,commaPos)
	if elem1 != ''
		let unletVals=substitute(arrayElems,',',' ','g')
		execute 'unlet '.unletVals
	endif
	execute 'unlet '.unletDims
	execute 'unlet '.unletTypes
	execute 'unlet '.unletRefs
endfunction

" STRUCTURE:
"
" <scope>:<name>:
"    EITHER:
"      holds the primary vector of the array
"    OR:
"      is a reference (see below)
"
" <scope>:<name>:<number>:...:
"    EITHER:
"      holds a value of the array
"    OR:
"      is a reference (see below)
"
" <scope>:<name>[:<number>]:type:
"      holds the type of the array vector, either 'REFERENCE' or 'VALUE'
"
" <scope>:<name>[:<number>]:dim:
"      holds the dimension of the array vector at this level
"
" For example:
"      ARRAYNEW g:array:2:3:4:
"   creates the array g:array: of dimension 3 of sizes 2 X 3 X 4
"   with
"      g:array:type: == REFERENCE
"      g:array:dim: == 2
"      g:array:0:type: and g:array:1:type == REFERENCE
"      g:array:0:dim: and g:array:1:dim == 3
"      g:array:0:0:type: thru g:array:1:2:type == REFERENCE
"      g:array:0:0:dim: thru g:array:1:2:dim == 4
"      g:array: is a reference to 2 references
"           its members are g:array:0: and g:array:1:
"      g:array:0: is a reference to 3 references
"           its members are g:array:0:0:, g:array:0:1:, and g:array:0:2:
"      g:array:1: is a reference to 3 references
"           its members are g:array:1:0:, g:array:1:1:, and g:array:1:2:
"   similarly ...
"      g:array:0:0: is a reference to 4 references
"      g:array:0:1: is a reference to 4 references
"      g:array:0:2: is a reference to 4 references
"      g:array:1:0: is a reference to 4 references
"      g:array:1:1: is a reference to 4 references
"      g:array:1:2: is a reference to 4 references
"   finally
"      g:array:0:0:0: thru g:array:1:2:3: contain discrete values
"
"
" NOTE:  Arrays are symmetrical.  Because of this, certain operations are not
"        permissible, such as, deletion of sub arrays.
"
"
" TODO:
"   Construction command:
"      provide a mechanism to build an array from elements of other array(s).
