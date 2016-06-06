/* cif-bal.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* cif-bal.i
*/


for each aaa of cif where aaa.crc eq crc.crc
   , first lgr of aaa
	break by lgr.led:

  if aaa.cr[1] - aaa.dr[1] lt 0 then do:
     coda = coda + 1.
     toda = toda + aaa.dr[1] - aaa.cr[1].
  end.
  else if aaa.cr[1] - aaa.dr[1] ge 0 then do:
    if aaa.dr[1] ne aaa.cr[1]
       then do:
	    if lgr.led eq "DDA" then cdda = cdda + 1.
	    else if lgr.led eq "SAV" then csav = csav + 1.
	    else if lgr.led eq "CDA" then ccda = ccda + 1.
	    else if lgr.led eq "CSA" then ccsa = ccsa + 1.
    end.
    accumulate aaa.cr[1] - aaa.dr[1] (total by lgr.led).
    if last-of(lgr.led)
       then do:
	   if lgr.led eq "DDA"
	     then tdda = accum total by lgr.led aaa.cr[1] - aaa.dr[1].
	   else if lgr.led eq "SAV"
	     then tsav = accum total by lgr.led aaa.cr[1] - aaa.dr[1].
	   else if lgr.led eq "CDA"
	     then tcda = accum total by lgr.led aaa.cr[1] - aaa.dr[1].
	   else if lgr.led eq "CSA"
	     then tcsa = accum total by lgr.led aaa.cr[1] - aaa.dr[1].
    end.
  end.
end.
taaa = tdda + tsav + tcda + tcsa.
caaa = cdda + csav + ccda + ccsa.

for each lon of cif where lon.crc eq crc.crc break by lon.grp:
  if lon.dam[1] ne lon.cam[1]
    then do:
	    if lon.grp eq 1 then ctrl = ctrl + 1.
       else if lon.grp eq 2 then coll = coll + 1.
       else if lon.grp eq 3 then cpll = cpll + 1.
       else if lon.grp eq 4 then cacl = cacl + 1.
    end.
  accumulate lon.dam[1] - lon.cam[1] (sub-total by lon.grp).
  accumulate lon.dam[1] - lon.ydam[1] (sub-total by lon.grp).
  accumulate lon.cam[2] - lon.ycam[2] (sub-total by lon.grp).
  if last-of(lon.grp)
    then do:
      if lon.grp eq 1
	then do:
	  ttrl[1] = accum sub-total by lon.grp lon.dam[1] - lon.cam[1].
	  ttrl[2] = accum sub-total by lon.grp lon.dam[1] - lon.ydam[1].
	  ttrl[3] = accum sub-total by lon.grp lon.cam[2] - lon.ycam[2].
	end.
      else if lon.grp eq 2
	then do:
	  toll[1] = accum sub-total by lon.grp lon.dam[1] - lon.cam[1].
	  toll[2] = accum sub-total by lon.grp lon.dam[1] - lon.ydam[1].
	  toll[3] = accum sub-total by lon.grp lon.cam[2] - lon.ycam[2].
	end.
      else if lon.grp eq 3
	then do:
	  tpll[1] = accum sub-total by lon.grp lon.dam[1] - lon.cam[1].
	  tpll[2] = accum sub-total by lon.grp lon.dam[1] - lon.ydam[1].
	  tpll[3] = accum sub-total by lon.grp lon.cam[2] - lon.ycam[2].
	end.
      else if lon.grp eq 4
	then do:
	  tacl[1] = accum sub-total by lon.grp lon.dam[1] - lon.cam[1].
	  tacl[2] = accum sub-total by lon.grp lon.dam[1] - lon.ydam[1].
	  tacl[3] = accum sub-total by lon.grp lon.cam[2] - lon.ycam[2].
	end.
    end.
end.
tlon[1] = ttrl[1] + toll[1] + tpll[1] + tacl[1].
tlon[2] = ttrl[2] + toll[2] + tpll[2] + tacl[2].
tlon[3] = ttrl[3] + toll[3] + tpll[3] + tacl[3].
clon    = ctrl    + coll    + cpll    + cacl.

for each lcr of cif where lcr.crc eq crc.crc:
  if lcr.dam[1] ne lcr.cam[1]
    then clcr = clcr + 1.
  find gl where gl.gl eq lcr.gl.
/*  find crc where crc.crc eq gl.crc. */
  accumulate (lcr.dam[1] - lcr.cam[1])  (total).
  accumulate (lcr.dam[1] - lcr.ydam[1]) (total).
  accumulate (lcr.cam[5] - lcr.dam[5]) (total).
end.
tlcr[1] = accum total (lcr.dam[1] - lcr.cam[1]) .
tlcr[2] = accum total (lcr.dam[1] - lcr.ydam[1]).
tigm    = accum total lcr.cam[5] - lcr.dam[5].

for each bill of cif where bill.bill ne "999" and bill.crc eq crc.crc
	      break by bill.grp:
  if bill.grp ne 4
    then do:
      tbil[1] = tbil[1] + bill.dam[1] - bill.cam[1].
      tbil[2] = tbil[2] + bill.dam[1] - bill.ydam[1].
      tbil[3] = tbil[3] + bill.cam[2] - bill.ycam[2].
      tbil[4] = tbil[4] + bill.cam[3] - bill.ycam[3].
    end.
    else do:
      tdbd[1] = tdbd[1] + bill.dam[1] - bill.cam[1].
      tdbd[2] = tdbd[2] + bill.dam[1] - bill.ydam[1].
      tdbd[3] = tdbd[3] + bill.cam[2] - bill.ycam[2].
      tdbd[4] = tdbd[4] + bill.cam[3] - bill.ycam[3].
    end.
end.
/*find clt where clt.cif eq cif.cif.*/
for each clt where clt.cif = cif.cif break by clt.cif by clt.ln:
  cclt = cclt + 1.
  tclt = tclt + clt.cltamt.
end.

for each ucc where ucc.cif eq cif.cif break by ucc.cif by ucc.ln:
   cucc = cucc + 1.
end.

tlen[1] = ttrl[1] + toll[1] + tpll[1] + tdbd[1].
tgua[1] = tacl[1] + tlcr[1].
ttot[1] = tlen[1] + tgua[1].
tlen[2] = ttrl[2] + toll[2] + tpll[2] + tdbd[2].
tgua[2] = tacl[2] + tlcr[2].
ttot[2] = tlen[2] + tgua[2].
tlen[3] = ttrl[3] + toll[3] + tpll[3] + tdbd[3].
tgua[3] = tacl[3].
ttot[3] = tlen[3] + tgua[3].
tlen[4] = tdbd[4].
ttot[4] = tlen[4].

clen    = ctrl    + coll    + cpll    + cdbd.
cgua    = cacl    + clcr.
ctot    = clen    + cgua.
