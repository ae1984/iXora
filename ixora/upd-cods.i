/*переприсваиваем значения trxcods*/
    for each bjl where  bjl.jh = s-jh and  bjl.gl = v-gl no-lock .
     find last trxcods where trxcods.trxh = s-jh and trxcods.trxln = bjl.ln and  trxcods.codfr = 'cods' no-error. 
     if not avail trxcods then next.
     find first cods where cods.gl  = v-gl and cods.arc = no and cods.acc = v-tarif no-lock no-error.
     if avail cods then do: v-code = cods.code.   v-dep = getdep(bxcif.cif). end.
     if v-code <> ""  then  trxcods.code = v-code + v-dep.
   end.