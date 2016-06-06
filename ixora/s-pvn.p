/* s-pvn.p
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

/* s-pvn.p
   изменения от 
   
   29.01.2001 - НДС 20% при закрытии месяца 
   21.05.2001 - итого: доход с НДС и НДС  
   30.07.2001 - 16%
   01.08.2003 nadejda - добавила вывод в файл названия филиала
   25.08.2003 suchkov - сделал обработку исключений для продажи автомобилей
                        и добавил подхват процентов из sysc .
*/
   
define shared variable g-today as date.
define shared variable s-target as date.
define variable v-dt1 as date.
define variable v-dt2 as date.
define variable v-par as character.
define variable v-jh like jh.jh.
define variable mes as character extent 12 init
["январь","февраль","март","апрель","май","июнь","июль","август","сентябрь",
 "октябрь","ноябрь","декабрь"].
define variable rcode as integer.
define variable rdes as character.
define shared variable doxnds as decimal init 0.
define shared variable nds as decimal init 0.
/*s-target = g-today + 1.*/
define buffer bjl for jl .

define temp-table w-trx
       field    gl    like gl.gl
       field    pvn   as decimal
       field    amt   as decimal
       field    ob    as decimal
       field    jh like jl.jh . 
       
define temp-table w
       field    gl    like gl.gl
       field    amt   as decimal.
              
form w-trx.gl  label "Счет"
     w-trx.amt format "zzz,zzz,zzz,zz9.99" label "Остаток "
     w-trx.pvn format "zzz,zzz,zzz,zz9.99" label "НДС"
     w-trx.ob  format "zzz,zzz,zzz,zz9.99" label "Обл.оборот"
     w-trx.jh  format "9999999999" label "Проводка"
     with down frame w-trx title "Счета доходов, с которых удержан НДС".


/*form w.gl  label "Счет"
     w.amt format "zzz,zzz,zzz,zz9.99" label "Остаток "
     with down frame w title "Счета доходов, с которых не удержан НДС". */

define stream s1.
output stream s1 to nds.pro  .
define stream s2.
output stream s2 to nds1.pro  .

find sysc where sysc = "nds" no-lock .

find first codfr where codfr.codfr = "ndcgl" no-lock no-error.
if not available codfr
then do:
     put stream  s1 "Не определены счета начисления НДС" skip .
     return.
end.

find first cmp no-lock no-error.
put stream s1 cmp.name skip(1).
                                           
find first cmp no-lock no-error.
put stream s2 cmp.name skip(1).



for each sub-cod where sub-cod.d-cod = "ndcgl" and 
    sub-cod.sub = "gld" and sub-cod.ccode = "01" no-lock:
    create w-trx.
    w-trx.gl = integer(sub-cod.acc).
    w-trx.pvn = 0.
    put stream s2 w-trx.gl skip.
end.

v-dt2 = date(month(s-target),1,year(s-target)) - 1.
v-dt1 = date(month(v-dt2),1,year(v-dt2)).

/* update v-dt1 v-dt2 . !!!!!!!!!!!!!!*/

for each jl where string(jl.gl) begins "4"
              and jl.jdt >= v-dt1 
              and jl.jdt <= v-dt2 no-lock. 
 if jl.dc = "C" then do.
    find fakturis where fakturis.jh = jl.jh 
                    and fakturis.trx = jl.trx
                    and fakturis.ln = jl.ln 
                    and fakturis.rdt = jl.jdt
                    and substring(fakturis.sts,3,1) = "O"
                    no-lock no-error.
   if not available fakturis then do.
     put stream s2  unformatted "Нет cчет-фактуры "
           jl.gl " " jl.jh " " jl.ln " " jl.cam " " jl.crc " " jl.trx skip.

     if substr(jl.trx,1,3) <> "DCL" then do. 
       find first w-trx where w-trx.gl = jl.gl no-error.
       if available w-trx then do.
         if jl.crc = 1 then do.
            w-trx.amt = w-trx.amt  +  jl.cam.

              /* suchkov 21.08.03 обработка исключения  для учета продажи б/у автомашин */
            if w-trx.gl = 485230 and jl.cam > 0 then do:
                find last bjl where bjl.gl = 585210 no-lock no-error .
                if not available bjl then put stream s2  unformatted "Ошибка в счете 585210" skip .
                w-trx.pvn = w-trx.pvn  +  (jl.cam - bjl.dam) * sysc.deval / (1 + sysc.deval) .
                /*message "Сумма " w-trx.pvn "   счет " w-trx.gl . pause .*/
            end.
            else w-trx.pvn = w-trx.pvn  +  jl.cam * sysc.deval / (1 + sysc.deval) .
         end.
         else do.
            find last crchis where crchis.crc = jl.crc
                               and crchis.regdt <= jl.jdt no-lock no-error.
            if avail crchis then do.
                w-trx.amt = w-trx.amt + jl.cam * crchis.rate[1].

              /* suchkov 21.08.03 обработка исключения  для учета продажи б/у автомашин */
                if w-trx.gl = 485230 and jl.cam > 0 then do:
                    find last bjl where bjl.gl = 585210 no-lock no-error .
                    if not available bjl then put stream s2  unformatted "Ошибка в счете 585210" skip .
                    w-trx.pvn = w-trx.pvn  +  (jl.cam * crchis.rate[1] - bjl.dam) * sysc.deval / (1 + sysc.deval) .
                end.
                else w-trx.pvn = w-trx.pvn + jl.cam * crchis.rate[1] * sysc.deval / (1 + sysc.deval) .
            end.    
         end.
         w-trx.ob  = w-trx.amt  -  w-trx.pvn.
       end.
       else do:
         find first w where w.gl = jl.gl no-error.
         if not available w then do:
             create w.
             w.gl = jl.gl.
         end.

         if jl.crc = 1 then w.amt = w.amt + jl.cam .
         else do.
            find last crchis where crchis.crc = jl.crc
                               and crchis.regdt <= jl.jdt no-lock no-error.
            if avail crchis then 
               w.amt = w.amt + round(jl.cam * crchis.rate[1],2).
         end.               
       end.
     end.
   end.
   else do.
      find first w-trx where w-trx.gl = jl.gl no-error.
      if available w-trx then do.
            w-trx.amt = w-trx.amt  + fakturis.amt.
            w-trx.pvn = w-trx.pvn + fakturis.pvn.
            w-trx.ob  = w-trx.amt  -  w-trx.pvn.
      end.
      else do:
        find first w where w.gl = jl.gl no-error.
        if not available w then do:
                 create w.
                 w.gl = jl.gl.
        end.
        w.amt = w.amt + fakturis.amt. 
      end.
   end.
 end.
 else do:
   if substr(jl.trx,1,3) <> "DCL" then do.
     find first w-trx where w-trx.gl = jl.gl no-error.
     if available w-trx then do.
       if jl.crc = 1 then do.
                  w-trx.amt = w-trx.amt  - jl.dam.
                  w-trx.pvn = w-trx.pvn - round(jl.dam * sysc.deval / (1 + sysc.deval) , 2).
       end.
       else do.
                  find last crchis where crchis.crc = jl.crc
                                     and crchis.regdt <= jl.jdt 
                                     no-lock no-error.
         if avail crchis then do.
                     w-trx.amt = w-trx.amt - round(jl.dam * crchis.rate[1],2).
                     w-trx.pvn = w-trx.pvn - 
                                 round(jl.dam * crchis.rate[1] * sysc.deval / (1 + sysc.deval) ,2).
         end.
       end.
       w-trx.ob  = w-trx.amt  -  w-trx.pvn.
     end.
     else do:
       find first w where w.gl = jl.gl no-error.
       if not available w then do:
         create w.
         w.gl = jl.gl.
       end.

       if jl.crc = 1 then w.amt = w.amt - jl.dam .
       else do.
         find last crchis where crchis.crc = jl.crc
                            and crchis.regdt <= jl.jdt
                            no-lock no-error.
         if avail crchis then
            w.amt = w.amt - round(jl.dam * crchis.rate[1],2).
       end.
     end.
   end.
 end.
end.

for each w-trx where w-trx.pvn > 0:
  find first  sub-cod where sub-cod.acc = string(w-trx.gl) and 
      sub-cod.d-cod = "revnds" and sub-cod.sub = "gld"  no-lock no-error . 
  if avail sub-cod and sub-cod.ccode ne "msc" then do:
    v-par = string(w-trx.pvn)  + "^" +  string(trim(sub-cod.ccode)) + "^" + 
            "НДС на комиссионные за " + mes[month(v-dt1)] +
            " месяц " + string(year(v-dt1)) + " года".
    run trxgen("INB0007","^",v-par,"","",output rcode,output rdes,
               input-output v-jh).  
  end.
  else do:
      rcode = 1 . 
      put  stream s1  unformatted "Ошибка : не найден ""revnds"" для " + string(w-trx.gl) .
      output stream s1 close .
      return .
  end.
 
  if rcode <> 0 then do :
         put stream s1  unformatted  " Ошибка " rcode rdes  . 
         output stream s1 close . 
         return . 
  end.
  else w-trx.jh = v-jh .
end.

find jh where jh.jh = v-jh exclusive-lock.
jh.sts = 6.
for each jl where jl.jh = jh.jh exclusive-lock:
    jl.sts = 6.
end.


for each w-trx break by w-trx.gl:
    if w-trx.pvn > 0 then do. 
       doxnds = doxnds + w-trx.amt.
       nds    = nds    + w-trx.pvn.
       display stream s1 w-trx with frame w-trx.
    end.
    down with frame w-trx.
    delete w-trx.
end.

display stream s1 "Итого:"
                  doxnds format "zzz,zzz,zzz,zz9.99" no-label
                  nds    format "zzz,zzz,zzz,zz9.99" no-label 
                  doxnds - nds format "zzz,zzz,zzz,zz9.99" no-label skip.

output stream s1 close. 
output stream s2 close.

