/* clnlgotr.p
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

/* clnlgotr.p
   Отчет о клиентах с льготным обслуживанием 

   25.04.2003 nadejda
*/


{mainhead.i}
{name2sort.i}

def var v-file as char init "clnlgot.htm".
def var v-num as integer.

def temp-table t-cif 
  field cif as char
  field name as char
  field pres as char
  field legal as char
  field sort as char
  index main is primary pres sort cif.

for each cif where cif.pres <> "" no-lock:
  create t-cif.
  assign t-cif.cif = cif.cif
         t-cif.name = trim(trim(cif.prefix) + " " + trim(cif.name))
         t-cif.pres = cif.pres
         t-cif.legal = cif.legal.
  t-cif.sort = name2sort(t-cif.name).
end.

displ skip(1) " Ждите..." skip(1) with centered row 7 no-label title "" frame f-wait.

output to value(v-file).

{html-title.i &stream = " " &title = " " &size-add = "x-"}

find first cmp no-lock no-error.
put unformatted
  "<P style=""font-size:x-small"">" cmp.name "</P>" skip
  "<P align=""center"" style=""font:bold;font-size:small"">СПИСОК КЛИЕНТОВ ПО ГРУППАМ ЛЬГОТНОГО ОБСЛУЖИВАНИЯ</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.


for each t-cif break by t-cif.pres by t-cif.sort by t-cif.cif:
  if first-of(t-cif.pres) then do:
    find codfr where codfr.codfr = "clnlgot" and codfr.code = t-cif.pres no-lock no-error.
    put unformatted
      "<TR style=""font:bold;font-size:small""><TD>" t-cif.pres "</TD>" skip
      "<TD colspan=""7"">" codfr.name[1] "</TD></TR>" skip
      "<TR align=""center"" style=""font:bold;font-size:xx-small"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>N п/п</TD>" skip
        "<TD>КОД КЛИЕНТА</TD>" skip
        "<TD>НАИМЕНОВАНИЕ КЛИЕНТА</TD>" skip
        "<TD>ПАРАМЕТРЫ ЛЬГОТ</TD>" skip
        "<TD>СЧЕТ</TD>" skip
        "<TD>ГРУППА СЧЕТА</TD>" skip
        "<TD>ДАТА ОТКРЫТИЯ</TD>" skip
        "</TR>" skip.
    v-num = 0.    
  end.

  if first-of(t-cif.cif) then do:
    v-num = v-num + 1.
    put unformatted
      "<TR><TD>&nbsp;</TD>" skip
        "<TD>" v-num "</TD>" skip
        "<TD>" t-cif.cif "</TD>" skip
        "<TD>" t-cif.name "</TD>" skip
        "<TD colspan=""4"">" t-cif.legal "</TD>" skip
       "</TR>" skip.
  end.

  for each aaa where aaa.cif = t-cif.cif and aaa.sta <> "c" no-lock, 
      first lgr where lgr.lgr = aaa.lgr and lgr.led <> "ODA" no-lock 
      break by aaa.lgr by substr(aaa.aaa, 4, 3) by aaa.aaa:
    put unformatted
      "<TR><TD colspan=""5"">&nbsp;</TD>" skip
        "<TD>" aaa.aaa "</TD>" skip
        "<TD>" lgr.des "</TD>" skip
        "<TD>" string(aaa.regdt, "99/99/9999") "</TD>" skip
      "</TR>" skip.
  end.
end.

{html-end.i " "}

output close.

hide frame f-wait no-pause.

unix silent cptwin value(v-file) iexplore.

pause 0.

