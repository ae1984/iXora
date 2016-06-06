/* r-lncif1.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/* Кредитный рейтинг клиента

*/


{global.i}
{lonlev.i}
def var vyrst like lon.opnamt extent 6 decimals 2.
def var summa like jl.dam init 0.
def var vmost like vyrst.
def var vcu like vyrst.
def shared var  v-cif as char.
def shared var  koef_ust as decimal.

def var v-dat like bal_cif.rdt.
def var stitle as char format "x(25)".
define new shared stream s1.
define variable bilance   as decimal format '->,>>>,>>9.99'.
def var vint as decimal format '->,>>>,>>9.99'.
def var vint1 like jl.dam.
define variable npk       as integer.
define variable vprem like lon.prem.
define variable kreditsp  as decimal format '->,>>>,>>9.99'.
define variable cifs      as character format 'x(6)' label 'Клиент'.
define variable v-name    as character.
define variable v-name1   as character.
def var v-cnt as int.
def var v-cntz as int.
def buffer jl2 for jl.
define new shared temp-table w-amk
       field    nr   as integer
       field    dt   as date
       field    fdt  as date
       field    amt1 as decimal format '->>>,>>>,>>9.99'
       field    amt2 as decimal format '->>>,>>>,>>9.99'.
def var v-am1 as decimal init 0.
def var v-am2 as decimal init 0. 
define stream s3.
define variable f-datc     as character.
define variable f-deb      as decimal.
define variable f-kred     as decimal.
define variable f-dat1     as date.
define variable datums     as date.
define variable f-jh       like jh.jh.
define variable f-who      like jh.who.
define variable des as character extent 20.
define variable docs as character extent 10.
define variable gal as character.
define variable gal1 as character.
define variable sumzal as decimal format '->,>>>,>>9.99'.
define variable sumzalt as decimal format '->,>>>,>>9.99'.
def var cnt as decimal extent 4.
def var god as int.

v-dat = g-today.

def temp-table temp_jl
    field tjh like jl.jh
    field tgl like gl.gl 
    field sumjl like jl.dam
    index tgl tjh tgl.

def temp-table temp_jl1
    field tgl like gl.gl 
    field sumjl like jl.dam
    index tgl tgl.

form
    stitle at 10 skip
    "Клиент" v-cif 
    help "Код клиента; F2-код; F4-выход; F1-далее" skip
    cif.sname  skip
    with centered row 0 no-label frame f-cif.

stitle = 'Кредитный рейтинг клиента'.

/*    display stitle with frame f-cif.
    update v-cif with frame f-cif.
    if keyfunction(lastkey) eq "end-error" then do: hide frame f-cif. return. end.
    display cif.sname with frame f-cif.

pause 0.
hide frame f-cif. 
  */
output stream s1 to rpt.img.
   find cif where cif.cif = v-cif no-lock no-error.

find first ppoint where ppoint.depart = int(substring(cif.jame,4,1)) no-lock no-error.
/*put stream s1 'Наименование банка:     ' ppoint.name format 'x(50)' skip.
put stream s1 'Клиент:                 ' cif.cif '   ' cif.name skip.
put stream s1 'РНН:                    ' cif.jss '' skip.*/

/*if substring(cif.geo,3,1) = '1' then put stream s1 'Резидент' skip.
                                else put stream s1 'Нерезидент' skip.
put stream s1 'Юридический адрес:      ' cif.addr[1] cif.tel format 'x(15)' skip.
  */
for each sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif 
                   and sub-cod.d-cod = 'secek',
    each codfr  where codfr.codfr = 'secek' and codfr.code = sub-cod.ccode:
/*    put stream s1 'Сектор экономики:       ' codfr.name format 'x(50)' skip.*/
end. 

for each sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif 
                   and sub-cod.d-cod = 'lneko',
    each codfr  where codfr.codfr = 'lneko' and codfr.code = sub-cod.ccode:
/*    put stream s1 '' codfr.name format 'x(50)' skip.*/
end. 

for each sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif 
                   and sub-cod.d-cod = 'ecdivis',
    each codfr  where codfr.codfr = 'ecdivis' and codfr.code = sub-cod.ccode:
/*    put stream s1 "Отрасль экономики:      " codfr.name format 'x(50)' skip.*/
end. 

find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif 
                   and sub-cod.d-cod = 'clnchf' no-lock no-error.
/*put stream s1 'Руководитель:           ' sub-cod.rcode skip.*/
   
find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif 
                   and sub-cod.d-cod = 'clnbk' no-lock no-error.
/*put stream s1 'Главный бухгалтер:      ' sub-cod.rcode skip.*/
                                       
find first zllon where zllon.cif = v-cif no-lock no-error.
if avail zllon then do:
end. 


repeat god = 1999 to year(g-today) by 1:   
  cnt[1] = 0. cnt[2] = 0. cnt[3] = 0. cnt[4] = 0.  
  for each aaa where aaa.cif = v-cif and not aaa.lgr begins '5' no-lock.
      for each jl where jl.acc = aaa.aaa  and year(jl.jdt) = god and jl.crc = 1 and (jl.lev = 1 or jl.lev = 2) no-lock.
        accumulate jl.cam (TOTAL).
      end.
      cnt[1] = cnt[1] + accum total jl.cam.
      for each jl where jl.acc = aaa.aaa  and year(jl.jdt) = god and jl.crc = 2 and (jl.lev = 1 or jl.lev = 2) no-lock.
        accumulate jl.cam (TOTAL).
      end.
      cnt[2] = cnt[2] + accum total jl.cam.
  end.
  for each lon where lon.cif = v-cif no-lock.
      for each jl where jl.acc = lon.lon  and year(jl.jdt) = god and jl.crc = 1 and (jl.lev = 1 or jl.lev = 2) no-lock.
        accumulate jl.dam (TOTAL).
      end.
      cnt[3] = cnt[3] + accum total jl.dam.
      for each jl where jl.acc = lon.lon  and year(jl.jdt) = god and jl.crc = 2 and (jl.lev = 1 or jl.lev = 2) no-lock.
        accumulate jl.dam (TOTAL).
      end.
      cnt[4] = cnt[4] + accum total jl.dam.
  end.
/*  put stream s1  ' ' god format '>>>9' '   ' cnt[1] format '->>>,>>>,>>>,>>9.99' ' ' cnt[2]  format '->>>,>>>,>>>,>>9.99' ' ' cnt[3]  format '->>>,>>>,>>>,>>9.99' ' ' cnt[4]  format '->,>>>,>>>,>>9.99' skip.
*/
end.

if month(g-today) > 3 then datums = date(string(day(g-today)) + "/" + string(month(g-today) - 3) + "/" + string(year(g-today))).
if month(g-today) = 1 then datums = date(string(day(g-today)) + "/10/" + string(year(g-today) - 1)).
if month(g-today) = 2 then datums = date(string(day(g-today)) + "/11/" + string(year(g-today) - 1)).
if month(g-today) = 3 then datums = date(string(day(g-today)) + "/12/" + string(year(g-today) - 1)).

  cnt[1] = 0. cnt[2] = 0. cnt[3] = 0. cnt[4] = 0.  
  for each aaa where aaa.cif = v-cif and not aaa.lgr begins '5' no-lock.
      for each jl where jl.acc = aaa.aaa  and jl.jdt >= datums and jl.jdt <= g-today and jl.crc = 1 and (jl.lev = 1 or jl.lev = 2) no-lock.
        accumulate jl.cam (TOTAL).
      end.
      cnt[1] = cnt[1] + accum total jl.cam.
      for each jl where jl.acc = aaa.aaa  and jl.jdt >= datums and jl.jdt <= g-today and  jl.crc = 2 and (jl.lev = 1 or jl.lev = 2) no-lock.
        accumulate jl.cam (TOTAL).
      end.
      cnt[2] = cnt[2] + accum total jl.cam.
  end.
  for each lon where lon.cif = v-cif no-lock.
      for each jl where jl.acc = lon.lon  and jl.jdt >= datums and jl.jdt <= g-today and jl.crc = 1 and (jl.lev = 1 or jl.lev = 2) no-lock.
        accumulate jl.dam (TOTAL).
      end.
      cnt[3] = cnt[3] + accum total jl.dam.
      for each jl where jl.acc = lon.lon  and jl.jdt >= datums and jl.jdt <= g-today and jl.crc = 2 and (jl.lev = 1 or jl.lev = 2) no-lock.
        accumulate jl.dam (TOTAL).
      end.
      cnt[4] = cnt[4] + accum total jl.dam.
  end.
/*  put stream s1  'За 3 мес' cnt[1] format '->>>,>>>,>>>,>>9.99' ' ' cnt[2]  format '->>>,>>>,>>>,>>9.99' ' ' cnt[3]  format '->>>,>>>,>>>,>>9.99' ' ' cnt[4]  format '->,>>>,>>>,>>9.99' skip.
 */
put stream s1 skip(5).

/***************/
datums = date(string(day(g-today)) + "/" + string(month(g-today)) + "/" + string(year(g-today) - 1)).


  for each aaa where aaa.cif = v-cif no-lock.
    for each jl where jl.acc = aaa.aaa and jl.lev = 1 and  jdt >= datums no-lock. 
      for each jl2 where jl2.jh = jl.jh and string(jl2.gl) begins '4'
           and (jl2.gl ne 441160 and jl2.gl ne 441170 and jl2.gl ne 441460 
           and jl2.gl ne 441470 and jl2.gl ne 441760 and jl2.gl ne 441770)
           no-lock.
        find first temp_jl where temp_jl.tjh = jl2.jh and temp_jl.tgl = jl2.gl no-lock no-error.
        if not avail temp_jl then do:
           create temp_jl.
           tjh = jl2.jh.
           tgl = jl2.gl.
            
        find last crchis where crchis.crc = jl2.crc and crchis.regdt le jl2.jdt
                  no-lock no-error.
        temp_jl.sumjl = temp_jl.sumjl + jl2.cam * crchis.rate[1] - jl2.dam * crchis.rate[1].
        end.
      end.
    end.   
  end.
  for each temp_jl where temp_jl.sumjl > 0. 
     find first temp_jl1 where temp_jl1.tgl = temp_jl.tgl no-lock no-error.
     if not avail temp_jl1 then do:
        create temp_jl1.
        temp_jl1.tgl = temp_jl.tgl.
     end.
     temp_jl1.sumjl = temp_jl1.sumjl + temp_jl.sumjl. 
  end.
  for each temp_jl1 break by temp_jl1.sumjl desc:
     find gl where gl.gl =  temp_jl1.tgl no-lock no-error.
   /*  put stream s1  temp_jl1.tgl '  ' gl.des ' ' temp_jl1.sumjl skip. 
*/
     summa = summa + temp_jl1.sumjl.
  end.
/*  put stream s1 'ВСЕГО                                            ' summa   skip(1).
  */

  summa = 0.
  for each temp_jl. delete temp_jl. end.
  for each temp_jl1. delete temp_jl1. end.

  for each lon where lon.cif = v-cif no-lock.
    for each jl where jl.acc = lon.lon and jl.lev = 2 and jdt >= datums no-lock. 
      for each jl2 where jl2.jh = jl.jh
           and (jl2.gl = 441160 or jl2.gl = 441170 or jl2.gl = 441460 
           or jl2.gl = 441470 or jl2.gl = 441760 or jl2.gl = 441770)
           no-lock:
        find first temp_jl where temp_jl.tjh = jl2.jh and temp_jl.tgl = jl2.gl no-lock no-error.
        if not avail temp_jl then do:
           create temp_jl.
           tjh = jl2.jh.
           temp_jl.tgl = jl2.gl.
            
        find last crchis where crchis.crc = jl2.crc and crchis.regdt le jl2.jdt
                  no-lock no-error.
        temp_jl.sumjl = temp_jl.sumjl + jl2.cam - jl2.dam.
        end.
      end.
    end.   
  end.

  for each temp_jl where temp_jl.sumjl > 0. 
     find first temp_jl1 where temp_jl1.tgl = temp_jl.tgl no-lock no-error.
     if not avail temp_jl1 then do:
        create temp_jl1.
        temp_jl1.tgl = temp_jl.tgl.
     end.
     temp_jl1.sumjl = temp_jl1.sumjl + temp_jl.sumjl. 
  end.
  for each temp_jl1 break by temp_jl1.sumjl desc:
     find gl where gl.gl =  temp_jl1.tgl no-lock no-error.
/*     put stream s1  temp_jl1.tgl '  ' gl.des ' ' temp_jl1.sumjl skip. */
     summa = summa + temp_jl1.sumjl.
  end.
/*  put stream s1 'ВСЕГО                                            ' summa   skip(1).

put stream s1 skip(5).
  */
npk = 1.

/**************/


    for each lon where lon.cif = v-cif and lon.dam[1] - lon.cam[1] = 0 break by lon.cif by lon.crc:
    if first-of (lon.cif) then
    do:
    end.
        find first loncon where loncon.lon = lon.lon no-lock no-error.
        find crc where crc.crc = lon.crc no-lock.
        vprem = lon.prem.
/*            put stream s1 skip
                 npk format 'zz9' ' '
                 lon.lon
                 lon.grp format '>>9' ' '
                 lon.rdt format '99/99/99' ' '
                 lon.duedt format '99/99/99' ' '
                 lon.opnamt  format '->,>>>,>>>,>>9.99' '  '
                 crc.code 
                 vprem format 'zzzz9.99'.
*/
                 if lon.gua = 'lo' then put stream s1 '   Кредит   '.
                                   else put stream s1 ' Кред.линия '.
                 v-cnt = 0.
                 for each lonsec1 where lonsec1.lon = lon.lon no-lock:
                     find first crc where crc.crc = lonsec1.crc no-lock no-error.
  /*                   if v-cnt = 0 then  
                        put stream s1 ' ' lonsec1.lonsec '     ' crc.code ' ' lonsec1.secamt skip.
                      else  put stream s1 space (78) lonsec1.lonsec '     ' crc.code ' ' lonsec1.secamt skip.
*/    
                  v-cnt = 1.
                 end. 
          npk = npk + 1.
    end.


for each lon where lon.cif = v-cif and lon.dam[1] - lon.cam[1] ne 0 break by lon.crc by lon.cif:

        find first loncon where loncon.lon = lon.lon no-lock no-error.
    
        find gl where gl.gl = lon.gl no-lock.
        find crc where crc.crc = lon.crc no-lock.
 
        run atl-dat(lon.lon,v-dat,output bilance). /* остаток  ОД*/                        
        run atl-prcl(lon.lon,v-dat - 1, output vint, output vint1, output vint1).  /* остаток % */

             vprem = lon.prem.   /* %% ставка */
             kreditsp =  0.
             for each lnsci where lnsci.lni = lon.lon and lnsci.idat le v-dat
                 and lnsci.f0 > - 1 and lnsci.fpn = 0 and lnsci.flp > 0 no-lock:
                 kreditsp = kreditsp + lnsci.paid-iv. /* погашенные %% */
               
             end.

        vprem = lon.prem.

/*             put stream s1 skip
                 npk format 'zz9' ' '
                 lon.lon
                 lon.rdt format '99/99/99' ' '
                 lon.duedt format '99/99/99' ' '
                 lon.opnamt  format '->,>>>,>>>,>>9.99' '  '
                 crc.code 
                 vprem format 'zzzz9.99'
                 bilance format '->,>>>,>>>,>>9.99'
                 vint  format '->,>>>,>>9.99'
                 lon.opnamt - bilance format '->,>>>,>>>,>>9.99'
                 kreditsp format '->>,>>>,>>9.99'.
  */  

/**********Залоги из COMM**************/
v-cntz = 1.
 
for each zldog where zldog.lon = lon.lon break by zldog.lon.
   sumzal = 0.

    if first-of (zldog.lon) then
    do:
  /*     put stream s1  '    Обеспечение кредита  '  skip.*/
      put stream s1  fill( '-', 100 ) format 'x(50)' skip(1).
    end.

    v-cnt = 1.
    v-cntz = v-cntz + 1.

for each zlzalog where zlzalog.lon = lon.lon and zlzalog.nomz = zldog.nomz break by zlzalog.lon.

  if first-of (zlzalog.lon) then
  do:
  end.

   find first uno where uno.grupa = 5 and uno.uno = zlzalog.uno no-lock.
/*   put stream s1 uno.apr skip.*/
   find first crc where crc.crc = zlzalog.crc no-lock.

put stream s1 v-cnt format '>9' ' |'.
v-cnt = v-cnt + 1.

      if zlzalog.crc = 1 then do:
            find last crchis where crchis.crc = 2 and crchis.regdt le g-today no-lock no-error.
            sumzal = sumzal + zlzalog.amount / crchis.rate[1].
      end.
      if zlzalog.crc = 2 then do:
            sumzal = sumzal + zlzalog.amount.
      end.
      if zlzalog.crc = 11 then do:
            find last crchis where crchis.crc = 11 and crchis.regdt le g-today no-lock no-error.
            sumzalt = zlzalog.amount * crchis.rate[1].
            find last crchis where crchis.crc = 2 and crchis.regdt le g-today no-lock no-error.
            sumzal = sumzal + sumzalt / crchis.rate[1].
      end.


gal = zlzalog.zalog[1].
gal1 = zlzalog.spisdoc[1].

run rin-dal(input-output gal,output des[1],input 80).
run rin-dal(input-output gal1,output docs[1],input 50).
/*   put stream s1 des[1] format "x(80)" ' | ' docs[1] format "x(50)" ' | ' crc.code ' | ' zlzalog.amount format ">>>,>>>,>>>.99" skip.
  */

run rin-dal(input-output gal,output des[2],input 80).
run rin-dal(input-output gal1,output docs[2],input 50).
/*   put stream s1 '   |' des[2] format "x(80)" ' | ' docs[2] format "x(50)" ' | ' skip.
  */

run rin-dal(input-output gal,output des[3],input 80).
run rin-dal(input-output gal1,output docs[3],input 50).

run rin-dal(input-output gal,output des[4],input 80).
run rin-dal(input-output gal1,output docs[4],input 50).

run rin-dal(input-output gal,output des[5],input 80).
run rin-dal(input-output gal1,output docs[5],input 50).

run rin-dal(input-output gal,output des[6],input 80).
run rin-dal(input-output gal1,output docs[6],input 50).

run rin-dal(input-output gal,output des[7],input 80).
run rin-dal(input-output gal1,output docs[7],input 50).

run rin-dal(input-output gal,output des[8],input 80).

run rin-dal(input-output gal,output des[9],input 80).

run rin-dal(input-output gal,output des[10],input 80).

run rin-dal(input-output gal,output des[11],input 80).

run rin-dal(input-output gal,output des[12],input 80).

run rin-dal(input-output gal,output des[13],input 80).

run rin-dal(input-output gal,output des[14],input 80).

run rin-dal(input-output gal,output des[15],input 80).

run rin-dal(input-output gal,output des[16],input 80).

run rin-dal(input-output gal,output des[17],input 80).

run rin-dal(input-output gal,output des[18],input 80).

run rin-dal(input-output gal,output des[19],input 80).
end.     

end.

end.

/*****************/


                if bilance <> 0 then do:
                 put stream s1 skip(1).
                   /* Остатки на нач месяца и года*/
                vyrst = 0.                                                                      
                vmost = 0.                                                                      
                vcu = 0.                                                                        
                for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon          
                no-lock :                                                                       
                    if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then do:           
                        vyrst[1] = vyrst[1] + trxbal.ydam - trxbal.ycam.                        
                        vmost[1] = vmost[1] + trxbal.mdam - trxbal.mcam.                        
                        vcu[1] = vcu[1] + trxbal.dam - trxbal.cam.                              
                    end.                                                                        
                end.                                                                            
                                                                                                
                run atl-prcl(input lon.lon, input date(month(g-today),1,year(g-today)) - 1,     
                output vmost[3], output vmost[4], output vmost[2]).                             
                                                                                                
                run atl-prcl(input lon.lon, input date(1,1,year(g-today)) - 1,                  
                output vyrst[3], output vyrst[4], output vyrst[2]).                             
                                                                                                
                                                                                                
                run atl-prcl(input lon.lon, input g-today,                                      
                output vcu[3], output vcu[4], output vcu[2]).                                   
                                                                                                
                                                                                                
                run atl-prov(input lon.lon, input date(month(g-today),1,year(g-today)) - 1,     
                output vmost[3]).                                                               
                                                                                                
                run atl-prov(input lon.lon, input date(1,1,year(g-today)) - 1,                  
                output vyrst[3]).                                                               
                                                                                                
                                                                                                
                run atl-prov(input lon.lon, input g-today,                                      
                output vcu[3]).                

                put stream s1 "---------------------------------------------------------------------------" skip.
                put stream s1 " Счет "lon.lon "     Кред.остат    Провиз.KZT     Получ. %     Начисл. %   " skip. 
                put stream s1 "---------------------------------------------------------------------------" skip.
                put stream s1 "На начало года    "                                                               
                vyrst[1] format ">>>,>>>,>>>.99"                                                   
                vyrst[3] format ">>>,>>>,>>>.99"                                                     
                vyrst[2] format ">>>,>>>,>>>.99"                                                     
                vyrst[4] format ">>>,>>>,>>>.99-" skip.                                             
                put stream s1 "На начало месяца  "                                                               
                vmost[1] format ">>>,>>>,>>>.99"                                                   
                vmost[3] format ">>>,>>>,>>>.99"                                                     
                vmost[2] format ">>>,>>>,>>>.99"                                                     
                vmost[4] format ">>>,>>>,>>>.99-" skip.                                             
                put stream s1 "На текущий момент "                                                               
                vcu[1]   format ">>>,>>>,>>>.99"                                                   
                vcu[3]   format ">>>,>>>,>>>.99"                                                     
                vcu[2]   format ">>>,>>>,>>>.99"                                                     
                vcu[4]   format ">>>,>>>,>>>.99-" skip(3).                                             




                 put stream s1 '--------------------------------------------------------' skip.
                 put stream s1 '   Графики погашения             Фактически погашено ' skip.
                 put stream s1 '--------------------------------------------------------' skip. 
                 put stream s1 '    Дата          Сумма          Дата          Сумма' skip.
                 put stream s1 '--------------------------------------------------------' skip.
                 put stream s1 '   Основного долга' skip(1).
                 v-am1 = 0. v-am2 = 0.

                 run r-lncal(lon.lon,1).
                 for each w-amk by w-amk.nr:
                     put stream s1 w-amk.fdt 
                                   w-amk.amt1 '        '
                                   w-amk.dt 
                                   w-amk.amt2 skip.
                     v-am1 = v-am1 + w-amk.amt2.
                 end. 
                 put stream s1 '--------------------------------------------------------' skip.
                 put stream s1 'Итого                              ' v-am1 format "->>>,>>>,>>>,>>9.99". 

/*                 for each lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 
                       and lnsch.fpn = 0 and lnsch.f0 > 0 no-lock.
                    put stream s1  lnsch.stdat  lnsch.stval skip.
                 end.
*/
                 v-am1 = 0.
                 put stream s1 skip(1).
                 put stream s1 '   Процентов' skip(1).
                 run r-lncal(lon.lon,2).
                 for each w-amk where w-amk.fdt <= g-today or w-amk.amt2 > 0 by w-amk.nr:
                     run atl-prcl(input lon.lon, input w-amk.fdt - 1,                                      
                                 output vcu[3], output vcu[4], output vcu[2]).                                   
                     w-amk.amt1 = vcu[3].  
                     if w-amk.fdt > g-today and w-amk.amt2 > 0 then     
                        put stream s1 '                               '
                                      w-amk.dt 
                                      w-amk.amt2 skip.
                     else
                        put stream s1 w-amk.fdt 
                                      w-amk.amt1 '        '
                                      w-amk.dt 
                                      w-amk.amt2 skip.
 
                    /* v-am1 = v-am1 + w-amk.amt2.*/
                 end. 
                 put stream s1 '--------------------------------------------------------' skip.

      /*           find last w-amk where w-amk.amt2 > 0 no-lock no-error.
                 if avail w-amk then do:
                    f-dat1 = w-amk.dt. */
                                  
                 find last w-amk where w-amk.fdt < g-today no-lock no-error.
                 if avail w-amk then do:
                    f-dat1 = w-amk.fdt.
                    v-am2 = w-amk.amt1.
                 end.
 
                 for each w-amk:
                     if w-amk.dt >= f-dat1 then  v-am1 = v-am1 + w-amk.amt2.
                 end.  
                 put stream s1 'Задолженность на дату посл. платежа' v-am2 - v-am1 format "->>>,>>>,>>>,>>9.99" skip. 
               

/*                 for each lnsci where lnsci.lni = lon.lon 
                      and lnsci.f0 > - 1 and lnsci.fpn = 0 and lnsci.flp = 0 no-lock:
                    put stream s1 lnsci.idat  lnsci.iv-sc skip.
                 end.  
*/

                 put stream s1 '---------------------------------------------------------' skip(3).

/*Обороты по счету - основная сумма*/
    
         put stream s1 '   Выдача и погашение основной суммы ' skip.

         v-am1 = 0. v-am2 = 0.
         clear frame jl all.
         output stream s3 to drb.1.

      g1:
         for each lnscg where lnscg.lng = lon.lon and
             lnscg.f0 > - 1 and lnscg.fpn = 0 and lnscg.flp > 0
             no-lock by lnscg.stdat descending:

             f-datc = string(lnscg.stdat,"99/99/9999").
             f-datc = substring(f-datc,7,4) +
                      substring(f-datc,3,4) + substring(f-datc,1,2).
             export  stream s3
                     f-datc
                     lnscg.stdat
                     lnscg.jh
                     lnscg.paid
                     0.
                     
         end.
         for each lnsch where lnsch.lnn = lon.lon and lnsch.flp > 0
             no-lock by lnsch.flp descending:
             f-deb = 0.
             do:
                  if lnsch.flp <= 0
                  then leave.
                  f-dat1 = lnsch.stdat.
                  f-datc = string(f-dat1,"99/99/9999").
                  f-datc = substring(f-datc,7,4) +
                           substring(f-datc,3,4) + substring(f-datc,1,2).
                  f-kred = lnsch.paid.
                  export  stream s3
                          f-datc
                          f-dat1
                          lnsch.jh
                          0
                          f-kred.
             end.
         end.

         output stream s3 close.
         unix silent sort drb.1 > drb.2.
 
          put stream s1 fill( '-', 100 ) format 'x(50)' skip.
          put stream s1
          "   Дата    "
          "            Дебет"
          "            Кредит"
          skip.
          put stream s1 fill( '-', 100 ) format 'x(50)' skip.

         input stream s3 from drb.2 no-echo.
         repeat on endkey undo,leave:
            import stream s3
                   f-datc
                   f-dat1
                   f-jh
                   f-deb
                   f-kred.
              put stream s1 
     f-dat1 format "99/99/9999"      
     f-deb  format "->>>,>>>,>>>,>>9.99" 
     f-kred format "->>>,>>>,>>>,>>9.99" 
     /*f-jh*/  skip.
     v-am1 = v-am1 + f-deb.
     v-am2 = v-am2 + f-kred.

         end.
         input stream s3 close.
         put stream s1  fill( '-', 100 ) format 'x(50)' skip.
         put stream s1 '  ИТОГО   ' v-am1 format "->>>,>>>,>>>,>>9.99" v-am2 format "->>>,>>>,>>>,>>9.99" skip.
         put stream s1  fill( '-', 100 ) format 'x(50)' skip.
         put stream s1 '  Задолженность              ' v-am1 - v-am2 format "->>>,>>>,>>>,>>9.99" skip.
         put stream s1  fill( '-', 100 ) format 'x(50)' skip.
    

              end.
                 npk = npk + 1.
    put stream s1 skip(5).


    find last bal_cif where bal_cif.cif = v-cif and bal_cif.nom begins 'a' 
            use-index rdt no-lock no-error.
      if avail bal_cif then do:
          v-dat = bal_cif.rdt.
          run r-lnrsk10(v-cif,v-dat).
          run r-lnrsk20(v-cif,v-dat).
          run r-lnrsk30(v-cif,v-dat).
          run r-lnkof10(v-cif,v-dat).
      

      define var w-lona like bal_cif.amount extent 27.
      define var w-lonp like bal_cif.amount extent 21.
      define var w-lond like bal_cif.amount extent 17.
      define var w-lonaold like bal_cif.amount extent 27.
      define var w-lonpold like bal_cif.amount extent 21.
      def var vk1 as deci.
      def var vk2 as deci.
      def var vk3 as deci.
      def var vk4 as deci.
      def var vk5 as deci.
      def var v-datold like bal_cif.rdt.
      def var i as integer.
      def var k4 as deci.
      def var k5 as deci.
      def var sum1 like bal_cif.amount.
      def var sum2 like bal_cif.amount.
      def var sum1sum2 like bal_cif.amount.

      v-datold = v-dat.
      
      do i = 1 to extent(w-lona):
         w-lona[i] = 0.
      end.
      do i = 1 to extent(w-lonp):
         w-lonp[i] = 0.
      end.
      do i = 1 to extent(w-lond):
         w-lond[i] = 0.
      end.
      do i = 1 to extent(w-lonaold):
         w-lonaold[i] = 0.
      end.
      do i = 1 to extent(w-lonpold):
         w-lonpold[i] = 0.
      end.


      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat 
          and bal_cif.nom begins 'a' use-index nom:
          w-lona[i] = bal_cif.amount.
          i = i + 1.
      end.

      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat 
          and bal_cif.nom begins 'p' use-index nom:
          w-lonp[i] = bal_cif.amount.
          i = i + 1.
      end.

      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat 
          and bal_cif.nom begins 'd' use-index nom:
          w-lond[i] = bal_cif.amount.
          i = i + 1.
      end.


   /* Коэффициент текущей ликвидности */

   sum1 = w-lona[11] + w-lona[12] + w-lona[13] 
        + w-lona[14] + w-lona[15]
        + w-lona[16] + w-lona[17] + w-lona[18] 
        + w-lona[19] + w-lona[20] + w-lona[21] 
        + w-lona[22] + w-lona[23] + w-lona[24] 
        + w-lona[25] + w-lona[26] + w-lona[27].

   sum2 = w-lonp[11] + w-lonp[12] + w-lonp[13] + w-lonp[14]
        + w-lonp[15] + w-lonp[16] + w-lonp[17]
        + w-lonp[18] + w-lonp[19] + w-lonp[20]
        + w-lonp[21].

   find first bal_spr where bal_spr.nom = 'K1'.
   if not avail bal_spr then do:
      message 'Нет коэффициента К1'.
      pause 5.
      return.
   end.

   if (sum1 / sum2) / dec(bal_spr.rem[1]) > 1 then vk1 = 1 * dec(bal_spr.rem[2]).
      else if (sum1 / sum2) / dec(bal_spr.rem[1]) < 0 then vk1 = 0.
         else vk1 = (sum1 / sum2) / dec(bal_spr.rem[1]) * dec(bal_spr.rem[2]).

   if sum2 = 0 then vk1 = 1 * dec(bal_spr.rem[2]).
/* Коэффициент быстрой ликвидности */

   sum1 = w-lona[16] + w-lona[17] + w-lona[18] 
        + w-lona[19] + w-lona[20] + w-lona[21] 
        + w-lona[22] + w-lona[23] + w-lona[24] 
        + w-lona[25] + w-lona[26].

   find first bal_spr where bal_spr.nom = 'K2'.
   if not avail bal_spr then do:
      message 'Нет коэффициента К2'.
      pause 5.
      return.
   end.

   if (sum1 / sum2) / dec(bal_spr.rem[1]) > 1 then vk2 = 1 * dec(bal_spr.rem[2]).
      else if  (sum1 / sum2) / dec(bal_spr.rem[1]) < 0 then vk2 = 0.
         else vk2 = (sum1 / sum2) / dec(bal_spr.rem[1]) * dec(bal_spr.rem[2]).

   if sum2 = 0 then vk2 = 1 * dec(bal_spr.rem[2]).
/* Коэффициент кредитоспособности  */

   sum1 = w-lonp[8] + w-lonp[9] + w-lonp[10]
        + w-lonp[11] + w-lonp[12] + w-lonp[13] + w-lonp[14]
        + w-lonp[15] + w-lonp[16] + w-lonp[17]
        + w-lonp[18] + w-lonp[19] + w-lonp[20]
        + w-lonp[21].

   sum2 = w-lonp[1] + w-lonp[2] + w-lonp[3] 
        + w-lonp[4] + w-lonp[5].

   find first bal_spr where bal_spr.nom = 'K3'.
   if not avail bal_spr then do:
      message 'Нет коэффициента К3'.
      pause 5.
      return.
   end.


   if (sum2 / sum1) / dec(bal_spr.rem[1]) > 1 then vk3 = 1 * dec(bal_spr.rem[2]).
     else if  (sum2 / sum1) / dec(bal_spr.rem[1]) < 0 then vk3 = 0.
          else vk3 = (sum2 / sum1) / dec(bal_spr.rem[1]) * dec(bal_spr.rem[2]).

   if sum2 = 0 then vk3 = 1 * dec(bal_spr.rem[2]).

   find last bal_cif where bal_cif.cif = v-cif and bal_cif.rdt < v-dat 
          and bal_cif.nom begins 'a' use-index cif-rdt no-lock no-error.
    if avail bal_cif then do:
      v-datold = bal_cif.rdt.
      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-datold 
          and bal_cif.nom begins 'a' use-index nom:
          w-lonaold[i] = bal_cif.amount.
          i = i + 1.
      end.
    end.
    else do:
      do i = 1 to extent(w-lonaold):
         w-lonaold[i] = 0.
      end.
    end.

   find last bal_cif where bal_cif.cif = v-cif and bal_cif.rdt < v-dat 
          and bal_cif.nom begins 'p' use-index cif-rdt no-lock no-error.
    if avail bal_cif then do:
      v-datold = bal_cif.rdt.
      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-datold 
          and bal_cif.nom begins 'p' use-index nom:
          w-lonpold[i] = bal_cif.amount.
          i = i + 1.
      end.
    end.
    else do:
      do i = 1 to extent(w-lonpold):
         w-lonpold[i] = 0.
      end.
    end.

/* Коэффициет оборачиваемости т.м.з.   */

sum1 = w-lona[11] + w-lona[12] + w-lona[13] + w-lona[14] + w-lona[15]
     + w-lonaold[11] + w-lonaold[12] + w-lonaold[13] + w-lonaold[14] + w-lonaold[15].
 

find first bal_spr where bal_spr.nom = 'K4'.
if not avail bal_spr then do:
  message 'Нет коэффициента К4'.
  pause 5.
  return.
end.

k4 = (dec(bal_spr.rem[1]) / 12) * round((v-dat - v-datold) / 30,0).

   if (w-lond[2] / (sum1 / 2)) / k4 > 1 then vk4 = 1 * dec(bal_spr.rem[2]).
      else if (w-lond[2] / (sum1 / 2)) / k4 < 0 then vk4 = 0.
           else vk4 = (w-lond[2] / (sum1 / 2)) / k4 * dec(bal_spr.rem[2]).

   if sum1 = 0 then vk4 = 1 * dec(bal_spr.rem[2]).

/* Коэффициент оборач-ти дебит. задолж-ти   */

sum1 = w-lona[16] + w-lona[17] + w-lona[18] 
     + w-lona[19] + w-lona[20] + w-lona[21]
     + w-lona[22]    + w-lonaold[16] + w-lonaold[17] 
     + w-lonaold[18] + w-lonaold[19] + w-lonaold[20] 
     + w-lonaold[21] + w-lonaold[22]. 


find first bal_spr where bal_spr.nom = 'K5'.
if not avail bal_spr then do:
  message 'Нет коэффициента К5'.
  pause 5.
  return.
end.

k5 = (dec(bal_spr.rem[1]) / 12) * round((v-dat - v-datold) / 30,0).

   if (w-lond[1] / (sum1 / 2)) / k5 > 1 then vk5 = 1 * dec(bal_spr.rem[2]).
      else if (w-lond[1] / (sum1 / 2)) / k5 < 0 then vk5 = 0.
           else vk5 = (w-lond[1] / (sum1 / 2)) / k5 * dec(bal_spr.rem[2]).

   if sum1 = 0 then vk5 = 1 * dec(bal_spr.rem[2]).

sum1 = 0.
  for each bal_cif where bal_cif.cif = v-cif and bal_cif.nom begins 's'. 
    sum1 = sum1 + bal_cif.amount.
  end.

sum1sum2 = vk1 + vk2 + vk3 + vk4 + vk5 + sum1.
if sum1sum2 > 100 then sum1sum2 = 100.

 koef_ust  = sum1sum2.
put stream s1 'Коэффициент надеждности ' sum1sum2 format '->>,>>9.99' skip.
end.

output stream s1 close.
/*run menu-prt('rpt.img').*/

