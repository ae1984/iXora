/* scanrep.p
 * MODULE
        Отчет по интернет платежам
 * DESCRIPTION
        Отчет по интернет платежам с разбивкой по ГО и СПФ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.8.12
 * AUTHOR
        18.01.2005 nataly
 * CHANGES
        11/02/2005 nataly добавлен отчет по НЕРАБОТАЮЩИМ клиентам 
        29/03/2005 tsoy добавил адрес телефон и фио руководителя
        10.06.05   nataly  изменен вызов проги inetrep2
        24.06.05   nataly  оптимизирован отчет
        04.05.06   tsoy    добавил avail 
        29.06.11   id00004  поправил отчет согласно тз-1055
*/

{global.i}

define variable v-day as date.
define variable totamt as decimal.
define variable totcoun as integer.

def var v-name as char init "".
def var totamtcl as decimal.
def var totamtgr as decimal.


def new shared variable i     as integer initial 0 .
def new shared var vpoint like point.point label "      ПУНКТ  ".
def new shared var vdep like ppoint.dep label    "ДЕПАРТАМЕНТ  ".
def new shared var pname as char.
def new shared var dname as char.
def new shared variable bdate as date .
def new shared variable edate as date  .

define new shared temp-table trep 
        field name   like cif.name
        field cif    like cif.cif
        field acc    like aaa.aaa
        field crc    like crc.code
        field amt  as   decimal initial 0
        field coun as   integer initial 0
        field dep    as   char format 'x(30)'
        field priz   as char format 'x(2)' 
        field adr    as char
        field tel    as char
        field clnchf as char.

define new shared temp-table trep2 
        field name   like cif.name
        field id     as integer
        field acc    like aaa.aaa
        field crc    like crc.code
        field amt  as   decimal initial 0
        field coun as   integer initial 0
        field dep  as   char format 'x(30)'
        field priz as char format 'x(2)' .

def  buffer b-trep for trep.
update "Введите период" bdate label "С " edate label "ПО " .



do v-day = bdate to edate .

      for each remtrz no-lock where remtrz.rdt = v-day and remtrz.source = 'ibh' use-index rdt.
              find aaa where aaa.aaa = remtrz.sacc no-lock no-error.

                      find cif where cif.cif = aaa.cif no-lock .
                      create trep. assign
                                    trep.name = cif.name 
                                    trep.cif  = cif.cif  
                                    trep.amt  = remtrz.amt
                                    trep.coun = 1 .

        if avail aaa then trep.acc  = aaa.aaa. 
                                   /* trep.dep  =   .*/
      /*признак - клиринг или гросс*/

        if remtrz.fcrc  = 1 then do:       
          if remtrz.cover = 2 then assign trep.priz = 'gr' .
                                 else assign trep.priz = 'cl' .
        end.

      /*валюта*/
                        find crc where crc.crc =  remtrz.fcrc no-lock no-error.       
                        trep.crc  = crc.code.

      /*департамент*/
      
       if cif.jame <> '' then do :
        vpoint = integer(cif.jame) / 1000 - 0.5.
        vdep = integer(cif.jame) - vpoint * 1000. 
       end.
       else do:
         find last ofchis where ofchis.ofc = cif.who no-lock.
         vpoint = ofchis.point. vdep = ofchis.dep. 
       end. 
       find point where point.point = vpoint no-lock no-error.
       if available point then pname = point.addr[1]. else pname = ''.
       find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock  no-error.
      if available ppoint then dname = ppoint.name. else dname = ''.
           trep.dep = dname.
  end.

end.

def new shared  stream vcrpt.
def var p-filename as char init "inetrep.html".
output stream vcrpt  to value(p-filename).


{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "x-"}


put  stream vcrpt unformatted "<p align=center><b> Отчет по Интернет платежам за период С " bdate " ПО " edate "<br>" skip 
                "Время " STRING(TIME,'HH:MM:SS') "<br>" skip 
                "Исполнитель " g-ofc "<br>" skip "</b></p>"  skip
    "<TABLE border=""1"" cellspacing=""0"" cellpadding=""5"">" skip.

  put stream vcrpt unformatted
     "<TR align=""center"" style=""font:bold"">" skip 
       "<TD>Департамент</TD>" skip
       "<TD>Наименование Клиента</TD>" skip
/*       "<TD>CIF</TD>" skip*/
       "<TD>Валюта</TD>" skip
       "<TD>Счет</TD>" skip
       "<TD>Кол-во</TD>" skip
       "<TD>Сумма </TD>" skip
       "<TD>Сумма клиринг </TD>" skip
       "<TD>Сумма гросс</TD>" skip
       "<TD>Телефон</TD>" skip
       "<TD>Адрес</TD>" skip
       "<TD>ФИО Руководителя</TD>" skip
       "</TR>" skip.

for each trep break by trep.dep by  trep.name by trep.crc by trep.acc by priz .
  ACCUMULATE trep.amt    (total by trep.acc   by trep.crc by trep.dep by priz).
  ACCUMULATE trep.coun    (total by trep.acc   by trep.crc by trep.dep ).

   if first-of(trep.dep) then do: 
   if i <> 0 then 
    put stream vcrpt unformatted "<TR>"
                    "</TR>" skip.
      i= i + 1.
    put stream vcrpt unformatted "<TR>"
                    "<TD colspan= 8><b>"       trep.dep                 "</b></TD>"
                    "</TR>" skip.
  end.

  if last-of(trep.acc) then do:
    totamt = ACCUMulate total  by (trep.acc) trep.amt.   
    totcoun = ACCUMulate total  by (trep.acc) trep.coun .

    totamtcl = 0.
    totamtgr = 0.
   for each b-trep where b-trep.name = trep.name and b-trep.acc  = trep.acc.
      if b-trep.priz = 'gr' then totamtgr = totamtgr + b-trep.amt.
      if b-trep.priz = 'cl' then  totamtcl = totamtcl + b-trep.amt.
   end.

      find ib.usr where ib.usr.cif = trep.cif no-lock no-error.
      if avail ib.usr then do:

         trep.adr    = ib.usr.contact[3].
         trep.tel    = ib.usr.contact[4].    

      end.

      find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = trep.cif  and sub-cod.d-cod = 'clnchf' 
       use-index dcod no-lock no-error.
      if avail sub-cod then trep.clnchf = sub-cod.rcode.



    put stream vcrpt unformatted "<TR>"
                    "<TD>        &nbsp;                 </TD>"
                    "<TD>" if v-name eq trep.name then  "&nbsp;" else  trep.name  "</TD>" 
                    "<TD>"       trep.crc               "</TD>"
                    "<TD>"       trep.acc               "</TD>"
                    "<TD align=right>"       totcoun                "</TD>"
                    "<TD align=right>"       totamt                 "</TD>"
                    "<TD align=right>"       totamtcl               "</TD>"
                    "<TD align=right>"       totamtgr               "</TD>"
                    "<TD>"       trep.adr               "</TD>"
                    "<TD>"       trep.tel               "</TD>"
                    "<TD>"       trep.clnchf            "</TD>"
                    "</TR>" skip.
      v-name = trep.name  .
  end.

end.
put stream vcrpt unformatted
  "</TABLE>" skip.

run inetrep2.

{html-end.i " stream vcrpt "}

output stream vcrpt close.

unix silent cptwin value(p-filename) excel.
pause 0.


                