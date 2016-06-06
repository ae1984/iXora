/* r-gcvp4p.p
 * MODULE
        отчеты по ГЦВП - выплата пенсий и пособий
 * DESCRIPTION
        Акты сверок Период указывается с ... по ... включительно!!!  Все филиалы одним файлом
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM TXB
 * AUTHOR
        25.09.10  marinav
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        28/04/2012 evseev - повтор
*/

{nbankBik-txb.i}

def input parameter v-bank as char.
def input parameter v-sel as char.

def shared var v-dtb as date.
def shared var v-dte as date.

define shared stream m-out.

def temp-table wrk
             field bank as char
             field type as inte
             field sum1 as deci
             field sum2 as deci
             field sum3 as deci
             field sum4 as deci
             field sum5 as deci.


def var v-s1 as deci .
def var v-s2 as deci .
def var v-s3 as deci .
def var v-s4 as deci .
def var v-s5 as deci .

def var v-isk   as char init '011'.
def var v-gf    as char init '027,046,048,091,096'.       /* выплаты из ГФСС акт 1*/
def var v-vozrb as char init ''.                          /* возвраты акт 1 на РБ - не отражать в акте */
def var v-vozgf as char init '028,047,049,092,097'.       /* возвраты акт 1 в ГФСС */
def var v-sem   as char init '090'.                       /* семипалатинск акт 2*/
def var v-ud    as char init '020'.                       /* удержания акт 3*/
def var v-kod   as char .



create wrk. wrk.type = 1.
create wrk. wrk.type = 2.


/*перечислено sum2 */
/*
if v-bank = 'TXB00' then do:
   for each txb.jl where txb.jl.jdt >= v-dtb and txb.jl.jdt <= v-dte and txb.jl.acc = '004904440' and txb.jl.dc = 'C' no-lock.
       find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
       find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
       if avail txb.sub-cod and lookup(entry(3,txb.sub-cod.rcode), v-gf) = 0 then do:
             find first wrk where wrk.type = 1.
             wrk.sum2 = wrk.sum2 + txb.jl.cam.
       end.
       if avail txb.sub-cod and lookup(entry(3,txb.sub-cod.rcode), v-gf) > 0 then do:
             find first wrk where wrk.type = 2.
             wrk.sum2 = wrk.sum2 + txb.jl.cam.
       end.
   end.
end.
*/


if v-sel = '1' then do:

     if v-bank = 'TXB00' then do:
         find last txb.histrxbal where txb.histrxbal.sub = 'arp' and txb.histrxbal.acc = '004904440' and txb.histrxbal.lev = 1 and txb.histrxbal.dt <= v-dtb no-lock no-error.
         if avail txb.histrxbal then do:
                find first wrk where wrk.type = 1.
                wrk.sum1 = wrk.sum1 + txb.histrxbal.cam - txb.histrxbal.dam.
         end.
         find last txb.histrxbal where txb.histrxbal.sub = 'arp' and txb.histrxbal.acc = '004904440' and txb.histrxbal.lev = 1 and txb.histrxbal.dt <= v-dte no-lock no-error.
         if avail txb.histrxbal then do:
                find first wrk where wrk.type = 1.
                wrk.sum5 = wrk.sum5 + txb.histrxbal.cam - txb.histrxbal.dam.
         end.
     end.

     for each txb.aaa where txb.aaa.lgr = '246' no-lock.

         for each txb.jl where txb.jl.jdt >= v-dtb and txb.jl.jdt <= v-dte and txb.jl.acc = txb.aaa.aaa no-lock .

             v-kod = "".
             if txb.jl.dc = 'C' then do:  /*выплачено sum4*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:
                    v-kod = entry(3,txb.sub-cod.rcode).
                    if lookup(v-kod, v-gf) = 0 and v-kod ne v-sem and v-kod ne v-ud and v-kod ne v-isk then do:
                      find first wrk where wrk.type = 1.
                      wrk.sum2 = wrk.sum2 + txb.jl.cam.
                      wrk.sum4 = wrk.sum4 + txb.jl.cam.
                    end.
                    if lookup(v-kod, v-gf) > 0 then do:
                      if v-kod = '091' and txb.jl.rem[1] matches '*из PБ*' then find first wrk where wrk.type = 1.
                                                                           else find first wrk where wrk.type = 2.
                         wrk.sum2 = wrk.sum2 + txb.jl.cam.
                         wrk.sum4 = wrk.sum4 + txb.jl.cam.
                    end.
                end.
                if not avail txb.sub-cod then do:
                   find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.codfr = "spnpl" no-lock no-error.
                   if avail txb.trxcods then do:
                      v-kod = txb.trxcods.code.
                      if lookup(v-kod, v-gf) = 0 and v-kod ne v-sem and v-kod ne v-ud and v-kod ne v-isk then do:
                         find first wrk where wrk.type = 1.
                         wrk.sum2 = wrk.sum2 + txb.jl.cam.
                         wrk.sum4 = wrk.sum4 + txb.jl.cam.
                      end.
                      if lookup(v-kod, v-gf) > 0  then do:
                      if v-kod = '091' and txb.jl.rem[1] matches '*из PБ*' then find first wrk where wrk.type = 1.
                                                                           else find first wrk where wrk.type = 2.
                         wrk.sum2 = wrk.sum2 + txb.jl.cam.
                         wrk.sum4 = wrk.sum4 + txb.jl.cam.
                      end.
                   end.
                end.
             end.
             else do:                     /*возвращено sum3*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:
                      v-kod = entry(3,txb.sub-cod.rcode).
                      if  lookup(v-kod, v-vozgf) = 0 and v-kod ne v-sem and v-kod ne v-ud and v-kod ne v-isk then do:
                          find first wrk where wrk.type = 1.
                          wrk.sum3 = wrk.sum3 + txb.jl.cam.
                      end.
                      if lookup(v-kod, v-vozgf) > 0 then do:
                          find first wrk where wrk.type = 2.
                          wrk.sum3 = wrk.sum3 + txb.jl.cam.
                      end.
                end.
             end.
         end.
     end.
end.



if v-sel = '2' then do:
     for each txb.aaa where txb.aaa.lgr = '246' no-lock.

         for each txb.jl where txb.jl.jdt >= v-dtb and txb.jl.jdt <= v-dte and txb.jl.acc = txb.aaa.aaa no-lock .

             v-kod = "".
             if txb.jl.dc = 'C' then do:  /*выплачено sum4*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:
                    v-kod = entry(3,txb.sub-cod.rcode).
                    if lookup(v-kod, v-sem) > 0 then do:
                       if txb.jl.rem[1] matches "*пенсионер*"  then do:
                          find first wrk where wrk.type = 1.
                          wrk.sum2 = wrk.sum2 + txb.jl.cam.
                          wrk.sum4 = wrk.sum4 + txb.jl.cam.
                       end.
                       else do:
                          find first wrk where wrk.type = 2.
                          wrk.sum2 = wrk.sum2 + txb.jl.cam.
                          wrk.sum4 = wrk.sum4 + txb.jl.cam.
                       end.
                    end.
                end.
                if not avail txb.sub-cod then do:
                   find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.codfr = "spnpl" no-lock no-error.
                   if avail txb.trxcods then do:
                      v-kod = txb.trxcods.code.
                      if lookup(v-kod, v-sem) > 0 then do:
                         if txb.jl.rem[1] matches "*пенсионер*"  then do:
                            find first wrk where wrk.type = 1.
                            wrk.sum2 = wrk.sum2 + txb.jl.cam.
                            wrk.sum4 = wrk.sum4 + txb.jl.cam.
                         end.
                         else do:
                            find first wrk where wrk.type = 2.
                            wrk.sum2 = wrk.sum2 + txb.jl.cam.
                            wrk.sum4 = wrk.sum4 + txb.jl.cam.
                         end.
                      end.
                   end.
                end.
             end.
             else do:                     /*возвращено sum3*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:
                      v-kod = entry(3,txb.sub-cod.rcode).
                      if  lookup(v-kod, v-sem) > 0 then do:
                          if txb.jl.rem[1] matches "*пенсионер*"  then do:
                             find first wrk where wrk.type = 1.
                             wrk.sum3 = wrk.sum3 + txb.jl.cam.
                          end.
                          else do:
                             find first wrk where wrk.type = 2.
                             wrk.sum3 = wrk.sum3 + txb.jl.cam.
                          end.
                      end.
                end.
             end.
         end.
     end.

end.



if v-sel = '3' then do:
     for each txb.aaa where txb.aaa.lgr = '246' no-lock.

         for each txb.jl where txb.jl.jdt >= v-dtb and txb.jl.jdt <= v-dte and txb.jl.acc = txb.aaa.aaa no-lock .

             v-kod = "".
             if txb.jl.dc = 'C' then do:  /*выплачено sum4*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:
                    v-kod = entry(3,txb.sub-cod.rcode).
                    if lookup(v-kod, v-ud) > 0 then do:
                       if txb.jl.rem[1] matches "*368609709*"  then do:
                          find first wrk where wrk.type = 1.
                          wrk.sum2 = wrk.sum2 + txb.jl.cam.
                          wrk.sum4 = wrk.sum4 + txb.jl.cam.
                       end.
                       else do:
                          find first wrk where wrk.type = 2.
                          wrk.sum2 = wrk.sum2 + txb.jl.cam.
                          wrk.sum4 = wrk.sum4 + txb.jl.cam.
                       end.
                    end.
                end.
                if not avail txb.sub-cod then do:
                   find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.codfr = "spnpl" no-lock no-error.
                   if avail txb.trxcods then do:
                      v-kod = txb.trxcods.code.
                      if lookup(v-kod, v-ud) > 0 then do:
                         if txb.jl.rem[1] matches "*368609709*"  then do:
                            find first wrk where wrk.type = 1.
                            wrk.sum2 = wrk.sum2 + txb.jl.cam.
                            wrk.sum4 = wrk.sum4 + txb.jl.cam.
                         end.
                         else do:
                            find first wrk where wrk.type = 2.
                            wrk.sum2 = wrk.sum2 + txb.jl.cam.
                            wrk.sum4 = wrk.sum4 + txb.jl.cam.
                         end.
                      end.
                   end.
                end.
             end.
             else do:                     /*возвращено sum3*/
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                find first txb.sub-cod where txb.sub-cod.sub = 'rmz' and txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail txb.sub-cod then do:
                      v-kod = entry(3,txb.sub-cod.rcode).
                      if  lookup(v-kod, v-ud) > 0 then do:
                          if txb.jl.rem[1] matches "*368609709*"  then do:
                             find first wrk where wrk.type = 1.
                             wrk.sum3 = wrk.sum3 + txb.jl.cam.
                          end.
                          else do:
                             find first wrk where wrk.type = 2.
                             wrk.sum3 = wrk.sum3 + txb.jl.cam.
                          end.
                      end.
                end.
             end.
         end.
     end.

end.




find first txb.cmp no-lock no-error.



  if v-sel = "1" then do:

      put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse""></tr><tr></tr><tr></tr>" skip.
      put stream m-out unformatted "<tr align=""left""><td><b>" txb.cmp.name format 'x(70)' "</td></tr>"  skip(1).
      put stream m-out unformatted "<tr align=""center""><td><b>  АКТ СВЕРКИ </td></tr><br><br>"  skip(1).
      put stream m-out unformatted "<tr align=""center""><td><b> по произведенным выплатам пенсий и пособий из Республиканского бюджета и  </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> по социальным выплатам из средств Государственного фонда социального страхования между </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> " + v-nbankru + " и Государственным центром по выплате пенсий </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> с " string(v-dtb) " по " string(v-dte) " года </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> по состоянию на " string(v-dte) " </td></tr>"  skip(1).
      put stream m-out unformatted "<tr align=""right""><td><b>(в тенге)  </td></tr>"  skip.

      put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                       "<tr style=""font:bold"">"
                       "<td bgcolor=""#C0C0C0"" align=""center""></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток задолженности <br> на " string(v-dtb) "</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Перечислено<br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Возвращено <br> в ГЦВП</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Выплачено <br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток <br> задолженности</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Ставка <br>комиссионного <br>вознаграждения </td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>комиссионного <br>вознаграждения</td>"
                       "</tr>" skip.

      find first wrk where wrk.type = 1.

              put stream m-out unformatted
                     "<tr align=""right"">"
                     "<td align=""left"" colspan=8><b><u> Выплата пенсий и пособий из средств Республиканского бюджета</td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td >0</td><td >0</td><td >0</td><td >0</td><td ></td><td ></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td >" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.   v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.

      find first wrk where wrk.type = 2.

              put stream m-out unformatted
                "<tr align=""right"">"
                "<td align=""left"" colspan=8><b><u> Социальная выплата из средств ГФСС</td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td >" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td>0</td><td>0</td><td>0</td><td>0</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.  v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.
  end.


  if v-sel = "2" then do:
      put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse""></tr><tr></tr><tr></tr>" skip.
      put stream m-out unformatted "<tr align=""left""><td><b>" txb.cmp.name format 'x(70)' "</td></tr>"  skip(1).
      put stream m-out unformatted "<tr align=""center""><td><b>  АКТ СВЕРКИ </td></tr><br><br>"  skip(1).
      put stream m-out unformatted "<tr align=""center""><td><b> по произведенной выплате единовременной государственной денежной компенсации гражданам, </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> пострадавшим вследствии яд. испытаний на Семипалатинском испытательном полигоне. </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> " + v-nbankru + " и РГКП Государственный центр по выплате пенсий </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> с " string(v-dtb) " по " string(v-dte) " года </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> по состоянию на " string(v-dte) " </td></tr>"  skip(1).
      put stream m-out unformatted "<tr align=""right""><td><b>(в тенге)  </td></tr>"  skip.

      put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                       "<tr style=""font:bold"">"
                       "<td bgcolor=""#C0C0C0"" align=""center""></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток задолженности <br> на " string(v-dtb) "</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Перечислено<br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Возвращено <br> в ГЦВП</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Выплачено <br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток <br> задолженности</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Ставка <br>комиссионного <br>вознаграждения </td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>комиссионного <br>вознаграждения</td>"
                       "</tr>" skip.

      find first wrk where wrk.type = 1.

              put stream m-out unformatted
                     "<tr align=""right"">"
                     "<td align=""left"" colspan=8><b><u> Выплата единовременной денежной компенсации ПЕНСИОНЕРАМ, ПОЛУЧАТЕЛЯМ ГСП </td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td >0</td><td >0</td><td >0</td><td >0</td><td ></td><td ></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td >" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.   v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.

      find first wrk where wrk.type = 2.

              put stream m-out unformatted
                "<tr align=""right"">"
                "<td align=""left"" colspan=8><b><u> Выплата единовременной денежной компенсации РАБОТАЮЩИМ (НЕРАБОТАЮЩИМ) ГРАЖДАНАМ</td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td >" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td>0</td><td>0</td><td>0</td><td>0</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.  v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.

  end.

  if v-sel = "3" then do:
      put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse""></tr><tr></tr><tr></tr>" skip.
      put stream m-out unformatted "<tr align=""left""><td><b>" txb.cmp.name format 'x(70)' "</td></tr>"  skip(1).
      put stream m-out unformatted "<tr align=""center""><td><b>  АКТ СВЕРКИ </td></tr><br><br>"  skip(1).
      put stream m-out unformatted "<tr align=""center""><td><b> по произведенным выплатам удержаний из пенсий и пособий из Республиканского бюджета и из средств ГФСС, </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> между " + v-nbankru + " и РГКП Государственный центр по выплате пенсий </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> с " string(v-dtb) " по " string(v-dte) " года </td></tr>"  skip.
      put stream m-out unformatted "<tr align=""center""><td><b> по состоянию на " string(v-dte) " </td></tr>"  skip(1).
      put stream m-out unformatted "<tr align=""right""><td><b>(в тенге)  </td></tr>"  skip.

      put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                       "<tr style=""font:bold"">"
                       "<td bgcolor=""#C0C0C0"" align=""center""></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток задолженности <br> на " string(v-dtb) "</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Перечислено<br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Возвращено <br> в ГЦВП</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Выплачено <br></td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Остаток <br> задолженности</td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Ставка <br>комиссионного <br>вознаграждения </td>"
                       "<td bgcolor=""#C0C0C0"" align=""center"">Сумма <br>комиссионного <br>вознаграждения</td>"
                       "</tr>" skip.

      find first wrk where wrk.type = 1.

              put stream m-out unformatted
                     "<tr align=""right"">"
                     "<td align=""left"" colspan=8><b><u> Перечисление удержаний из пенсий и пособий из средств Республиканского бюджета </td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td >0</td><td >0</td><td >0</td><td >0</td><td ></td><td ></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td >" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.   v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.

      find first wrk where wrk.type = 2.

              put stream m-out unformatted
                "<tr align=""right"">"
                "<td align=""left"" colspan=8><b><u> Перечисление удержаний из социальных выплат из средств ГФСС </td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Текущие счета</td>"
                "<td >" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Карточные счета</td>"
                "<td >0</td><td>0</td><td>0</td><td>0</td><td>0</td><td></td><td></td></tr>" skip.

              put stream m-out unformatted
                "<tr align=""right""><td align=""left"">Всего</td>"
                "<td>" wrk.sum1 "</td><td>" wrk.sum2 "</td><td>" wrk.sum3 "</td><td>" wrk.sum4 - wrk.sum3 "</td><td>" wrk.sum5 "</td><td></td><td></td></tr>" skip.

              v-s1 = v-s1 + wrk.sum1.  v-s2 = v-s2 + wrk.sum2.  v-s3 = v-s3 + wrk.sum3.  v-s4 = v-s4 + wrk.sum4.  v-s5 = v-s5 + wrk.sum5.
  end.

  put stream m-out unformatted
     "<tr align=""right""><b><td align=""left"">ИТОГО</td>"
     "<td>" v-s1 "</td><td>" v-s2 "</td><td>" v-s3 "</td><td>" v-s4 "</td><td>" v-s5 "</td><td></td><td></td></tr><tr>" skip.


  put stream m-out unformatted "</table></table>" skip.




