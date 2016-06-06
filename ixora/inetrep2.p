/* scanrep2.p
 * MODULE
        Отчет по неработающим клиентам в инет офисе
 * DESCRIPTION
        Отчет по неработающим клиентам в инет офисе с разбивкой по ГО и РКО
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        inetrep.p
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
        10.06.05 nataly изменен статус таблицы trep: new shared -> shared
        24.06.05 nataly среди неработающих клиентов были исключены заблокированные perm[6] <> 1 
        03.07.05 nataly был изменен алгортм выбора клиентов интернет-офиса
*/

{global.i}
define shared temp-table trep 
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


define shared temp-table trep2 
        field name   like cif.name
        field id     as integer
        field acc    like aaa.aaa
        field crc    like crc.code
        field amt  as   decimal initial 0
        field coun as   integer initial 0
        field dep  as   char format 'x(30)'
        field priz as char format 'x(2)' .

def shared  stream vcrpt.
def shared variable i     as integer initial 0 .
def shared var vpoint like point.point label "      ПУНКТ  ".
def shared  var vdep like ppoint.dep label    "ДЕПАРТАМЕНТ  ".
def shared var pname as char.
def shared var dname as char.
def shared vari bdate as date .
def shared var edate as date  .

def var totcoun as integer.

/*формируем таблицу по неработающим в Интернет офисе клиентам*/

for each ib.usr no-lock. 
   find first trep where trep.cif = ib.usr.cif no-lock no-error.
  if avail trep then next.

find first  ib.hist where  ib.hist.idusraff = ib.usr.id 
                       and ib.hist.type1     = 2 
                       and ib.hist.type2     = 1 
                       and ib.hist.procname  = "IBPL_CrUsr" no-lock no-error.
/* if not avail ib.hist then message ib.usr.id.*/
 if avail ib.hist and  ib.hist.wdate     > edate  then next.
    if ib.usr.perm[6] <> 1 then do:
   /*исключаем всех кривых клиентов и филиальных*/
    if ib.usr.cif = 'no-cif' or substr(ib.usr.cif,1,1)  <> 'T' then next.

    find cif where cif.cif = ib.usr.cif no-lock no-error.
/*    if not avail trep then do:*/

       create trep2. 
       assign trep2.id = ib.usr.id
              trep2.coun = 1 
              trep2.name = cif.name  .
/*департамент*/
 if cif.jame <> '' then do :
  vpoint = integer(cif.jame) / 1000 - 0.5.
  vdep = integer(cif.jame) - vpoint * 1000. 
 end.
 else do:
   find last ofchis where ofchis.ofc = cif.who no-lock.
   vpoint = ofchis.point. vdep = ofchis.dep. 
 end. 
/*  message 'yes 'ib.usr.id.*/
 find point where point.point = vpoint no-lock no-error.
 if available point then pname = point.addr[1]. else pname = ''.
 find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock  no-error.
 if available ppoint then dname = ppoint.name. else dname = ''.
     trep2.dep = dname.

/*    end. /* not avail trep*/ */
  end.  /*avail usr.perm[6]*/
end.  /*ib.usr*/
/*НЕРАБОТАЮЩИЕ КЛИЕНТЫ*/ 
put  stream vcrpt unformatted "<p align=center><b> Отчет по неработающим в Internet-Office клиентам за период С " bdate " ПО " edate "<br>" skip 
                "Время " STRING(TIME,'HH:MM:SS') "<br>" skip 
                "Исполнитель " g-ofc "<br>" skip "</b></p>"  skip
    "<TABLE border=""1"" cellspacing=""0"" cellpadding=""5"">" skip.

  put stream vcrpt unformatted
     "<TR align=""center"" style=""font:bold"">" skip 
       "<TD>Департамент</TD>" skip
       "<TD>Наименование Клиента</TD>" skip
       "<TD>Рег номер клиента</TD>" skip
       "</TR>" skip.

i = 0.
for each trep2 break by trep2.dep by  trep2.name  .
  ACCUMULATE trep2.coun    (total by trep2.dep ).
   if first-of(trep2.dep) then do: 
   if i <> 0 then 
    put stream vcrpt unformatted "<TR>"
                    "</TR>" skip.
      i= i + 1.
    put stream vcrpt unformatted "<TR>"
                    "<TD colspan= 3><b>"       trep2.dep                 "</b></TD>"
                    "</TR>" skip.
  end.

 put stream vcrpt unformatted "<TR>"
                    "<TD>        &nbsp;                 </TD>"
                    "<TD>"       trep2.name   "</TD>" 
                    "<TD>"       trep2.id               "</TD>"
                    "</TR>" skip.
     

  if last-of(trep2.dep) then do:
    totcoun = ACCUMulate total  by (trep2.dep) trep2.coun .


    put stream vcrpt unformatted "<TR>"
                    "<TD>        &nbsp;                 </TD>"
                    "<TD><b>         ИТОГО                </b> </TD>" 
                    "<TD><b>"       totcoun                "</b></TD>"
                    "</TR>" skip.
  end.

end.

put stream vcrpt unformatted
  "</TABLE>" skip.
