/* .p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25.09.2013 evseev - tz-1798
 * BASES
        BANK
 * CHANGES
*/

{global.i}



def var v-cif as char.
def var v-sdt as date.
def var v-edt as date.
form skip 'Код клиента: ' v-cif skip 'c: ' v-sdt ' по: ' v-edt with frame form1 no-label row 3  centered .

update v-cif v-sdt v-edt with frame form1 .


find first cif where cif.cif = v-cif no-lock no-error.
if not avail cif then do:
   message "Клиент не найден!" view-as alert-box.
   return.
end.

def var v-tmpstr as char.
def var v-tmpstr2 as char.
def var v-tmpdec as deci.
def var v-tarif as char.
def var i as int.

def stream rep.
def var v-file  as char init "repfnl.html"  no-undo.

output to value(v-file).
{html-title.i &size-add = "x-"}

 put unformatted
   "<TABLE bordercolor=silver width=""600"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip.

put unformatted "<TR><TD colspan=5 height = 20 bgcolor=gray> " trim(cif.prefix) " " trim(cif.name) " </TD></TR>" skip.

put unformatted "<TR><TD colspan=5 height = 15> </TD></TR>" skip.


put unformatted
   "<TR>" skip
     "<TD>Операция</TD>" skip
     "<TD>Валюта</TD>" skip
     "<TD>Сумма операции</TD>" skip
     "<TD>Код тарифа</TD>" skip
     "<TD>Сумма комиссии</TD>" skip
   "</TR>" skip.

for each aaa where aaa.cif = v-cif no-lock:
    if lookup (aaa.lgr, "151,153,171,157,176,152,154,172,158,177,173,175,174")  = 0 then next.

    for each remtrz where (remtrz.sacc = aaa.aaa /*or remtrz.racc = aaa.aaa*/) and remtrz.valdt1 >= v-sdt and remtrz.valdt1 <= v-edt no-lock:
        if remtrz.jh1 = ? or remtrz.jh1 <= 0 then next.
        find first crc where crc.crc = remtrz.fcrc no-lock no-error.
        /*v-tmpstr = crc.code.
        find first crc where crc.crc = remtrz.svcrc no-lock no-error.
        v-tmpstr2 = crc.code.*/

        if num-entries(remtrz.tarif) >= 1 then do:
             do i = 1 to num-entries(remtrz.tarif):
                v-tarif =  entry(i,remtrz.tarif).
                find first tarif2 where /*tarif2.num + tarif2.kod*/ tarif2.str5 = v-tarif no-lock no-error.
                v-tmpdec = 0.
                if avail tarif2 and tarif2.proc > 0 then do:
                    v-tmpdec = remtrz.amt * tarif2.proc / 100.
                    find last crchis where crchis.crc = remtrz.fcrc and crchis.rdt <= remtrz.valdt1 no-lock no-error.
                    v-tmpdec = v-tmpdec * crchis.rate[1].
                    if tarif2.max1 > 0 and tarif2.max1 < v-tmpdec then v-tmpdec = tarif2.max1.
                    if tarif2.min1 > 0 and tarif2.min1 > v-tmpdec then v-tmpdec = tarif2.min1.
                    /*v-tmpdec = v-tmpdec / crc.rate[1].*/
                    v-tmpdec = round(v-tmpdec,2).
                end.
                if avail tarif2 and tarif2.ost > 0 and tarif2.proc = 0 then do:
                    v-tmpdec = round(tarif2.ost,2).
                end.

                put unformatted
                   "<TR>" skip
                     "<TD>" remtrz.remtrz "</TD>" skip
                     "<TD>" crc.code "</TD>" skip
                     "<TD align=right>" replace(string(remtrz.amt,"->>>>>>>>>>>9.99"),'.',',') /*" " v-tmpstr*/ "</TD>" skip
                     "<TD>" v-tarif "</TD>" skip
                     "<TD align=right>" replace(string(v-tmpdec,"->>>>>>>>>>>9.99"),'.',',') /*" " v-tmpstr2*/ "</TD>" skip
                   "</TR>" skip.
             end.
        end. else /*if remtrz.svccgr > 0 then*/ do:
            v-tarif =  trim(string(remtrz.svccgr,'>999')).
            find first tarif2 where /*tarif2.num + tarif2.kod*/ tarif2.str5 = v-tarif no-lock no-error.
            v-tmpdec = 0.
            if avail tarif2 and tarif2.proc > 0 then do:
                v-tmpdec = remtrz.amt * tarif2.proc / 100.
                find last crchis where crchis.crc = remtrz.fcrc and crchis.rdt <= remtrz.valdt1 no-lock no-error.
                v-tmpdec = v-tmpdec * crchis.rate[1].
                if tarif2.max1 > 0 and tarif2.max1 < v-tmpdec then v-tmpdec = tarif2.max1.
                if tarif2.min1 > 0 and tarif2.min1 > v-tmpdec then v-tmpdec = tarif2.min1.
                /*v-tmpdec = v-tmpdec / crc.rate[1].*/
                v-tmpdec = round(v-tmpdec,2).
            end.
            if avail tarif2 and tarif2.ost > 0 and tarif2.proc = 0 then do:
                v-tmpdec = round(tarif2.ost,2).
            end.

            put unformatted
               "<TR>" skip
                 "<TD>" remtrz.remtrz "</TD>" skip
                 "<TD>" crc.code "</TD>" skip
                 "<TD align=right>" replace(string(remtrz.amt,"->>>>>>>>>>>9.99"),'.',',') /*" " v-tmpstr*/ "</TD>" skip
                 "<TD>" v-tarif "</TD>" skip
                 "<TD align=right>" replace(string(v-tmpdec,"->>>>>>>>>>>9.99"),'.',',') /*" " v-tmpstr2*/ "</TD>" skip
               "</TR>" skip.
        end.
    end.

    for each joudoc where joudoc.whn >= v-sdt and joudoc.whn <= v-edt and (joudoc.dracc = aaa.aaa or joudoc.cracc = aaa.aaa) no-lock:
        if joudoc.jh = ? or joudoc.jh <= 0 then next.
        find first crc where crc.crc = joudoc.drcur no-lock no-error.
        /*v-tmpstr = crc.code.
        find first crc where crc.crc = joudoc.comcur no-lock no-error.
        v-tmpstr2 = crc.code.*/

        find first tarif2 where /*tarif2.num + tarif2.kod*/ tarif2.str5 = trim(joudoc.comcode) no-lock no-error.
        v-tmpdec = 0.
        if avail tarif2 and tarif2.proc > 0 then do:
            v-tmpdec = joudoc.dramt * tarif2.proc / 100.
            find last crchis where crchis.crc = joudoc.drcur and crchis.rdt <= joudoc.whn no-lock no-error.
            v-tmpdec = v-tmpdec * crchis.rate[1].
            if tarif2.max1 > 0 and tarif2.max1 < v-tmpdec then v-tmpdec = tarif2.max1.
            if tarif2.min1 > 0 and tarif2.min1 > v-tmpdec then v-tmpdec = tarif2.min1.
            /*v-tmpdec = v-tmpdec / crc.rate[1].*/
            v-tmpdec = round(v-tmpdec,2).
        end.
        if avail tarif2 and tarif2.ost > 0 and tarif2.proc = 0 then do:
            v-tmpdec = round(tarif2.ost,2).
        end.
        put unformatted
           "<TR>" skip
             "<TD>" joudoc.docnum "</TD>" skip
             "<TD>" crc.code "</TD>" skip
             "<TD align=right>" replace(string(joudoc.dramt,"->>>>>>>>>>>9.99"),'.',',') /*" " v-tmpstr*/ "</TD>" skip
             "<TD>" joudoc.comcode "</TD>" skip
             "<TD align=right>" replace(string(v-tmpdec,"->>>>>>>>>>>9.99"),'.',',') /*" " v-tmpstr2*/ "</TD>" skip
           "</TR>" skip.
    end.

    for each dealing_doc where dealing_doc.whn_cr >= v-sdt and dealing_doc.whn_cr <= v-edt and (/*dealing_doc.tclientaccno = aaa.aaa or*/ dealing_doc.vclientaccno = aaa.aaa /*or dealing_doc.com_accno = aaa.aaa*/) no-lock:
        if dealing_doc.jh = ? or dealing_doc.jh <= 0 then next.
        find first crc where crc.crc = dealing_doc.crc no-lock no-error.

        v-tarif = "".
        if cif.type = "p" then do:
          /*физ лица*/
          if dealing_doc.DocType = 1 or dealing_doc.DocType = 3 then v-tarif = "809".
          if dealing_doc.DocType = 2 or dealing_doc.DocType = 4 then v-tarif = "810".
          if dealing_doc.DocType = 6 then v-tarif = "809".
        end.
        else do:
         /*юр лица*/
          if dealing_doc.DocType = 1 or dealing_doc.DocType = 3 then v-tarif = "804".
          if dealing_doc.DocType = 2 or dealing_doc.DocType = 4 then v-tarif = "802".
          if dealing_doc.DocType = 6 then  v-tarif = "804".
        end.


        find first tarif2 where /*tarif2.num + tarif2.kod*/ tarif2.str5 = v-tarif no-lock no-error.
        v-tmpdec = 0.
        if avail tarif2 and tarif2.proc > 0 then do:
            v-tmpdec = dealing_doc.v_amount * tarif2.proc / 100.
            find last crchis where crchis.crc = dealing_doc.crc and crchis.rdt <= dealing_doc.whn_cr no-lock no-error.
            v-tmpdec = v-tmpdec * crchis.rate[1].
            if tarif2.max1 > 0 and tarif2.max1 < v-tmpdec then v-tmpdec = tarif2.max1.
            if tarif2.min1 > 0 and tarif2.min1 > v-tmpdec then v-tmpdec = tarif2.min1.
            /*v-tmpdec = v-tmpdec / crc.rate[1].*/
            v-tmpdec = round(v-tmpdec,2).
        end.
        if avail tarif2 and tarif2.ost > 0 and tarif2.proc = 0 then do:
            v-tmpdec = round(tarif2.ost,2).
        end.

        put unformatted
           "<TR>" skip
             "<TD>" string(dealing_doc.DocNo) "</TD>" skip
             "<TD>" crc.code "</TD>" skip
             "<TD align=right>" replace(string(dealing_doc.v_amount,"->>>>>>>>>>>9.99"),'.',',') /*" " v-tmpstr*/ "</TD>" skip
             "<TD>" v-tarif "</TD>" skip
             "<TD align=right>" replace(string(v-tmpdec,"->>>>>>>>>>>9.99"),'.',',') /*" " v-tmpstr2*/ "</TD>" skip
           "</TR>" skip.
    end.

end.



put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.


unix silent cptwin value(v-file) excel.




