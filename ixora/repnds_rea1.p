/* repnds_rea1.p
 * MODULE
        Налоговая отчетность
 * DESCRIPTION
        Реестр счетов-фактур
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
 * BASES
        BANK COMM TXB
 * AUTHOR
        07.11.2009 - marinav
 * CHANGES
        15.03.10 marinav - после 15 марта в номер добавлять код филиала
        12.10.2013 dmitriy - ТЗ 1526. Включение счетов-фактур по комиссиям за ЭЦП в реестр по реализации
*/


def var nom as int.
def shared var dt1 as date .
def shared var dt2 as date .
def shared stream m-out.

define variable v-jss like txb.cif.jss.
define variable v-bin like txb.cif.bin.
def var v-sum as deci.
define variable v-nds% as decimal.
def var v-gl as inte.
def var v-txb as char format "x(2)".

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
v-txb = substr(trim(txb.sysc.chval),4,2).

nom = 0.

find first txb.cmp.


       put stream m-out unformatted "<tr></tr><tr align=""center""><td><h4>"  txb.cmp.name "<BR>".
       put stream m-out unformatted "<br><br></h4></td></tr><tr></tr>" skip.

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >N </td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >РНН</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >ИИН (БИН) покупателя</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >N сч. фактуры</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Дата выписки <br> сч. фактуры</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Всего стоимость <br> без НДС</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма НДС</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма НДС, <br> отн. в зачет</td>"
                  "</tr>" skip.



       for each txb.fakturis where txb.fakturis.rdt >= dt1 and txb.fakturis.rdt <= dt2 use-index rdt no-lock :
       v-jss = "". v-bin = "".

       if trim(txb.fakturis.cif) <> "" and txb.fakturis.cif <> ?
       then do:
            if trim(txb.fakturis.cif) = '100100' then do:
                 find first txb.joudoc where  txb.joudoc.jh = txb.fakturis.jh no-lock no-error.
                 if avail txb.joudoc then v-jss = txb.joudoc.perkod.
            end.
            else do:
                 find txb.cif where txb.cif.cif = txb.fakturis.cif no-lock no-error.
                 if avail txb.cif then assign v-jss = txb.cif.jss v-bin = txb.cif.bin.
            end.
       end.
       if trim(txb.fakturis.cif) = "" or txb.fakturis.cif = ?
       then do:
          find first txb.arp where txb.arp.arp = txb.fakturis.acc no-lock no-error.
          if avail txb.arp then v-jss = txb.arp.des.
       end.

       v-nds% = 0.

       for each txb.jl where txb.jl.jh = txb.fakturis.jh.
           if string(txb.jl.gl) begins '4' or txb.jl.gl = 287082 then v-gl = txb.jl.gl.
       end.

       find first txb.sub-cod where txb.sub-cod.sub = "gld" and  txb.sub-cod.acc = trim(string(v-gl))
                                and txb.sub-cod.d-cod = "ndcgl" and txb.sub-cod.ccode = "01"  no-lock no-error .

      if avail txb.sub-cod then do:

               nom = nom + 1.

               if txb.fakturis.rdt < 01/01/2009 then v-nds% = 0.13.
               else do:
                    find txb.sysc where txb.sysc.sysc = "nds" no-lock no-error.
                    if avail txb.sysc then v-nds% = txb.sysc.deval. else v-nds% = 0.12.
               end.

               put stream m-out unformatted "<tr align=""right"">"
                      "<td > " nom "</td>"
                      "<td align=""left"" >" v-jss "</td>"
                      "<td align=""left"" >" v-bin "</td>"
                      "<td >" if txb.fakturis.rdt > 03/15/2010 then string(txb.fakturis.faktura,">>>>>>>>9") + v-txb else string(txb.fakturis.faktura,">>>>>>>>9") "</td>"
                      "<td > " txb.fakturis.rdt  "</td>"
                      "<td > " txb.fakturis.neto   format 'zzzzzz9' "</td>"
                      "<td > " txb.fakturis.pvn    format 'zzzzzz9' "</td>"
                      "<td > " txb.fakturis.pvn    format 'zzzzzz9' "</td>".

               put stream m-out "</tr>" skip .
               v-sum = v-sum + txb.fakturis.pvn  .

       end.
       end.
       put stream m-out  "<td ></td><td ></td><td ></td><td ></td><td ></td><td ><b> " v-sum  format 'zzzzzz9.99' "</td><td ><b> " v-sum  format 'zzzzzz9.99' "</td>".


       put stream m-out "</table>" skip.

