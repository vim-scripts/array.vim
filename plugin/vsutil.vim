" Vim plugin of vim script utilities
" Language:    vim script
" Maintainer:  Dave Silvia <dsilvia@mchsi.com>
" Date:        7/16/2004
"

function! IsVimNmr(var)
	let l:omega=matchend(a:var,'^\%[0x]\d*')
	return ((match(a:var,'\%[0x]\d*$') <= l:omega) && (l:omega == strlen(a:var)))
endfunction

function! IsVimIdent(var)
	if match(a:var,'^\h\w*') != -1
		return 1
	endif
	return 0
endfunction

" returns 1 if valid and exists, -1 if valid and doesn't exist, 0 if not valid
function! IsVimVar(var)
	if IsVimIdent(a:var)
		if exists(a:var)
			return 1
		else
			return -1
		endif
	endif
	return 0
endfunction

function! IsStrLit(var)
	let sglQuote=match(a:var,"^'") != -1 && match(a:var,"'$") != -1
	let dblQuote=match(a:var,'^"') != -1 && match(a:var,'"$') != -1
	return (sglQuote || dblQuote)
endfunction

" returns 1 if valid and exists, -1 if valid and doesn't exist, 0 if not valid
function! IsArrayDecl(decl)
	if match(a:decl,'^\(b\|w\|g\):\h\w*:\(\d*:\)*$') == 0
		if exists(a:decl)
			return 1
		else
			return -1
		endif
	endif
	return 0
endfunction
