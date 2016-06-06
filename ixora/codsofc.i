if v-dep = "000" and lookup(g-ofc, v-supusr) = 0  then do:
 find ofc where ofc.ofc = g-ofc no-lock no-error.
 find codfr where codfr.codfr = 'sproftcn' and codfr.code = ofc.titcd no-lock
   no-error.
    if avail codfr then  v-dep = codfr.name[4] . else v-dep = '000'.
 end.
