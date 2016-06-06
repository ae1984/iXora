/* dp_rep.p
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
 * BASES
        BANK COMM
 * AUTHOR
        22.07.2004 dpuchkov
 * CHANGES
        14.09.2004 dpuchkov убрал дату из заголовка отчета
*/
{mainhead.i}
def var file1 as char format "x(20)".
def var d_date as date.
def var v-num as integer.
def var v-crc1 as char.
def var d-dam as decimal.
def var dt-persent as date.


define var intrat  as dec format "zzz.9999" decimals 4.
  d_date = g-today.

/*  update d_date label "Дата" with centered side-label. */

  display "......Ж Д И Т Е ......."  with row 12 frame ww centered.
  pause 0.


  file1 = "file1.html". 
  output to value(file1).
  {html-title.i} 
    put unformatted
        "<P align=""center"" style=""font:bold;font-size:small"">Отчет по депозитам юридических лиц (Г/К 221510) " /* g-today */ /*d_date*/  "  </P>" skip
        "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;background:white "">" skip
        "<TD>N</TD>" skip     
        "<TD>Наименование клиента</TD>" skip
        "<TD>N ИИК</TD>" skip
        "<TD>Сумма депозита</TD>" skip
        "<TD>Валюта депозита</TD>" skip
        "<TD>% ставка</TD>" skip
        "<TD>Дата открытия</TD>" skip
        "<TD>Дата выплаты %</TD>" skip
        "<TD>Дата окончания депозита</TD>" skip
        "</TR>" skip.

   for each aaa where aaa.gl = 221510 and aaa.sta <> "C"   no-lock .
   find last lgr where lgr.lgr = aaa.lgr  and lgr.led = "CDA"  no-lock no-error. 
   if not avail lgr then next.


   find last cif where cif.cif = aaa.cif and cif.type = 'b' no-lock no-error.
   if avail cif then do:
       if aaa.crc = 1 then v-crc1 = "KZT".
       if aaa.crc = 2 then v-crc1 = "USD".
       if aaa.crc = 5 then v-crc1 = "RUR".
       if aaa.crc = 11 then v-crc1 = "EUR".

       find last lgr where lgr.lgr = aaa.lgr no-lock no-error.
       if lgr.lookaaa eq true
       then do:
         if aaa.pri ne "F" then do:
         find pri where pri.pri eq aaa.pri no-error.
         intrat = pri.rate + aaa.rate.
         end.
         else intrat = aaa.rate.
       end.
       else do:
         if aaa.pri ne "F" then do:
         find pri where pri.pri eq lgr.pri.
          intrat = pri.rate + lgr.rate.
         end.
         else intrat = lgr.rate.
       end.

       find last  jl where jl.acc = aaa.aaa and jl.lev = 1 and jl.dc = "D" no-lock no-error .
       if avail jl then  dt-persent = jl.jdt.

       put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
       put unformatted
           "<td>" v-num      "</td>" skip
           "<td>" cif.name format "x(50)" "</td>" skip
           "<td>" aaa.aaa    "</td>" skip
           "<td>" /*aaa.opnamt*/ aaa.cr[1] - aaa.dr[1] format "->>,>>>,>>>,>>>,>>9.99" "</td>" skip
           "<td>" v-crc1     "</td>" skip
           "<td>" aaa.rate   "</td>" skip
           "<td>" aaa.regdt  "</td>" skip
           "<td>" dt-persent "</td>" skip
           "<td>" aaa.expdt  "</td>" skip.
       v-num = v-num + 1.
    end.
  end.

  put unformatted  "</TABLE>" skip.
  {html-end.i " "}
  output close.
  hide frame ww.
  unix silent cptwin value(file1) iexplore.
