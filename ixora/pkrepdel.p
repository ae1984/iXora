/* pkrepdel.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Отчет об удаленных анкетах за период
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-14-9
 * AUTHOR
        12.02.2004 nadejda
 * CHANGES
*/

{mainhead.i}
{pk.i new}


def var v-dtb as date.
def var v-dte as date.
def var v-ofc as char.
def var v-select as integer.
def var v-filials as char.
def var i as integer.
def var v-cred as char.
def var v-bank as char.
def new shared var v-bankname as char.

form 
  skip(1)
  v-dtb label " Начало периода " format "99/99/9999" 
        help " Дата начала отчетного периода"
        validate (v-dtb <= g-today, " Дата начала периода должна быть не больше текущей!")
  skip
  v-dte label "  Конец периода " format "99/99/9999" 
        help " Дата конца отчетного периода"
        validate (v-dtb <= v-dte, " Дата конца периода должна быть не меньше даты начала!")
  skip(1)
  v-ofc label "  По менеджерам " format "x(50)" 
        help " Логины менеджеров через запятую, пустое поле - ВСЕ"
  skip(1)
  with centered row 5 side-label title " ПАРАМЕТРЫ ОТЧЕТА " frame f-param.

v-dtb = g-today.
v-dte = g-today.
displ v-dtb v-dte with frame f-param.

update v-dtb with frame f-param.
update v-dte v-ofc with frame f-param.


for each txb where txb.consolid no-lock:
  if v-filials <> "" then v-filials = v-filials + " | ".
  v-filials = v-filials + string(txb.txb) + ". " + txb.name.
end.
v-filials = " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | " + v-filials.

v-select = 0.

run sel2 (" ВЫБЕРИТЕ ОФИС/ФИЛИАЛ БАНКА ", v-filials, output v-select).

if v-select = 0 then return.

message " Формируется отчет...".


def var v-file as char init "pkrepdel.html".
if v-select = 1 then do:
  v-bank = "".
  find first cmp no-lock no-error.
  v-bankname = cmp.name + "<BR>" + "Консолидированный отчет".
end.
else do:
  find txb where txb.txb = v-select - 2 no-lock no-error.
  v-bank = txb.bank.
  v-bankname = txb.name.
end.


output to value(v-file).

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted   
  "<P align=""center"" style=""font:bold"">Ведомость удаленных анкет</P>" skip
  "<P align=""center"">за период с " string(v-dtb, "99/99/9999") " по " string(v-dte, "99/99/9999") "</P>" skip
  "<P>По менеджерам: " if v-ofc = "" then "ВСЕ МЕНЕДЖЕРЫ" else v-ofc "</P>" skip
  "<P>" v-bankname "</P>" skip
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
    "<TR align=""center"" style=""font:bold;font-size:xx-small"">" skip
      "<TD>N</TD>" skip
      "<TD>Дата удаления</TD>" skip
      "<TD>Удалил</TD>" skip
      "<TD>Банк</TD>" skip
      "<TD>Вид кредита</TD>" skip
      "<TD>Анкета</TD>" skip
      "<TD>Код клиента</TD>" skip
      "<TD>Дата анкеты</TD>" skip
      "<TD>Внес анкету</TD>" skip
      "<TD>Статус</TD>" skip
      "<TD>Причина удаления</TD>" skip
  "</TR>" skip.

i = 0.
for each pkankdel where pkankdel.deldt >= v-dtb and pkankdel.deldt <= v-dte no-lock:
  if v-bank <> "" and pkankdel.bank <> txb.bank then next.
  if v-ofc <> "" and lookup (pkankdel.delwho, v-ofc) = 0 then next.

  i = i + 1.

  find bookcod where bookcod.bookcod = "credtype" and bookcod.code = pkankdel.credtype no-lock no-error.
  if avail bookcod then v-cred = bookcod.name.
                   else v-cred = "".
  
  put unformatted 
    "<TR><TD>" i "</TD>" skip
      "<TD align=""center"">" pkankdel.deldt "</TD>" skip
      "<TD align=""center"">" pkankdel.delwho "</TD>" skip
      "<TD align=""center"">" pkankdel.bank "</TD>" skip
      "<TD>" v-cred "</TD>" skip
      "<TD>" pkankdel.ln "</TD>" skip
      "<TD align=""center"">" pkankdel.cif "</TD>" skip
      "<TD align=""center"">" pkankdel.rdt "</TD>" skip
      "<TD align=""center"">" pkankdel.rwho "</TD>" skip
      "<TD align=""center"">&nbsp;" pkankdel.sts "</TD>" skip
      "<TD>" pkankdel.delreason "</TD>" skip
    "</TR>" skip.
end.

put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.

hide message no-pause.

unix silent cptwin value(v-file) excel.
pause 0.

