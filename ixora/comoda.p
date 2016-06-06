/* comoda.p
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

{global.i new}
def var dat1 as date format "99/99/9999".
def var dat2 as date format "99/99/9999".
def var pdat as date format "99/99/9999".
def var ldat as date format "99/99/9999".
def var acc  as char format "x(9)".
def var proc as deci format "z9.9999".
def var post like aab.bal.
def var rez  as deci format "-z999999999.99" init 0 .
def var kom  as deci format "-z999999.99" init 0.
def var i    as integer init 0.
   update acc label 'Укажите номер лицевого счета' format 'x(9)' 
          proc label 'Укажите % -ю ставку' format 'z9.9999'skip 
          with side-label row 3 centered frame nummm.
hide frame nummm.          
find last cls no-lock no-error.
g-today = if available cls then cls.cls + 1 else today.
dat1 = today.
dat2 = today.
    update dat1 label ' Укажите дату начала периода' format '99/99/9999'
           dat2 label ' Укажите дату конца периода' format '99/99/9999' skip
           with side-label row 5 centered frame dat.
hide frame dat.
output to ostat.
find aaa where aaa.aaa = acc and aaa.craccnt <> " " and aaa.gl = 220310 no-lock.
 find last aab where aab.aaa = aaa.craccnt and aab.fdt <= dat1 and aab.bal = 0
      no-lock .
 pdat = dat1.
 post = aab.bal.
 i = dat1 - aab.fdt.
 kom = post * i * proc / 100.
 rez = rez + kom. 
for each aab where aab.aaa = aaa.craccnt and aab.fdt >= dat1 and aab.fdt <=dat2:
   i = aab.fdt - pdat.
   kom = post * i * proc / 100.
   rez = rez + kom .
/*   if weekday(aab.fdt) = 6 then 
   do:
        rez = rez + aab.bal * proc / 100.
        rez = rez + aab.bal * proc / 100.
   end.

      i = aab.fdt - pdat.
   if i > 1 then do:
        rez = rez + post * (i - 1) * proc / 100.
        kom = kom + post * i * proc / 100.
   end.
*/

   displ skip aab.bal label "Остаток " format "-z999999999.99"
              pdat    label "   С    "
              aab.fdt label "   ПО   "
              kom     label "Комиссия"
              i       label "К-во дней"
              rez     label "  Итого  " format "-z999999999.99"
              with title "Остатки по счету " + acc .
   pdat = aab.fdt.
   post = aab.bal.
end.
   i = dat2 - pdat.
   if i > 0 then do:
      kom = post * i * proc / 100.
      rez = rez + kom .
put
post format "-z999999999.99" " " 
 pdat " " dat2 format "99/99/99" " " kom " " i " "  
 rez format "-z999999999.99"  .
   end. 
displ skip rez label "Сумма для снятия комиссии ". 
output close.
run menu-prt('ostat').