/* dealrpt.p
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
    13/10/03 nataly была добавлена сортировка по серединке счета, затем по валюте-  по заявке Мурыгина М.
                    Для тех счетов, где deal.fun = "" валюта берется из fun.crc
    24.12.03 nataly была добавлена обработка сделок РЕПО
    07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
    30/10/2008 madiyar - перекомпиляция
*/

/* dealrpt.p
   list deals with value date le g-today.
   отчет по сделкам, зарегистрированным в указанный период времени
   изменения от 11.03.2001
   - валюта
   - деление на привлеченные и размещенные депозиты и кредиты
   - итоги 
*/

def  var  fdate   like  deal.valdt.
def  var  tdate   like  deal.valdt.
def  temp-table temp
     field  pr        as    logical init 'yes'
     field  deal      like  deal.deal
     field  bank      like  bankl.bank
     field  name      like  bankl.name
     field  prn       as deci format 'zz,zzz,zzz,zz9.99' 
     field  code      like  crc.code
     field  valdt     like  deal.valdt
     field  maturedt  like  deal.maturedt
     field  trm       like  deal.trm
     field  intrate   like  deal.intrate
     field  intamt    like  deal.intamt
     field  rem       as char
     field  partner    like  deal.broke
     field  kol       as decimal
     field  nom       as decimal
     field  who       like  deal.who.
def  stream   m-out.

{mainhead.i}
{functions-def.i}
fdate = g-today.
tdate = g-today.
  
display
   fdate label " С "
   tdate label " по "
   with row 8 centered  side-labels frame opt title " Введите период: " .

update fdate
  validate(fdate <= g-today,"Должно быть: начало <= сегодня")
  with frame opt.
update tdate validate(tdate >= fdate and tdate <= g-today,
  "Должно быть: начало <= конец <= сегодня")
  with frame opt.

hide frame opt.

display '   Ждите...   '  with row 5 frame ww centered .

output stream m-out to rpt.img.
put stream m-out
FirstLine( 1, 1 ) format 'x(115)' skip(1)
'                             '
'ОТЧЕТ ПО СДЕЛКАМ,  '  skip
'                  '
'ЗАРЕГИСТРИРОВАННЫМ С  ' string(fdate)  ' ПО ' string(tdate) skip(1)
FirstLine( 2, 1 ) format 'x(115)' skip(1).
put stream m-out  fill( '-', 181 ) format 'x(181)'  skip. 
put stream m-out
' Сделка '
'   Банк '
'    Контрагент'
'                 Сумма    '
' Вал.'
'  Дата    '
' Дата   '
'Срок  '
'  %%  '
'       Сумма   '
'     Код ЦБ    '
'  Количество   '
'    Номинал    '
'   Партнер     '
'       Менеджер   ' skip.
put stream m-out
' (счет)  '
space(22)
'               сделки   '
'    '
'  валютир.'
' закрытия'
' (дни) '
'ставка '
'    процентов '
'              '
'       ЦБ     '
'        ЦБ    '
'              '
skip.
put stream m-out  fill( '-', 181 ) format 'x(181)'  skip.

def buffer bfun for fun.
def var v-grp as char.
for each deal where deal.regdt ge fdate 
                and deal.regdt le tdate 
                no-lock:
  create temp.
  if substr(string(deal.gl),1,1) = '1' then temp.pr = yes. 
     else temp.pr = no.

  temp.deal      =  deal.deal.
  temp.prn       =  deal.prn.
  temp.valdt     =  deal.valdt.  
  temp.maturedt  =  deal.maturedt. 
  temp.trm       =  deal.trm. 
  temp.intrate   =  deal.intrate. 
  temp.intamt    =  deal.intamt.
  temp.who       =  deal.who. 
  temp.partner   =  deal.broke.
  temp.rem       =  deal.rem[3].
  temp.kol       =  deal.ncrc[1].
  temp.nom       =  deal.ncrc[2].

  find sysc where sysc.sysc = 'repogr' no-lock no-error.
  if avail sysc then v-grp = sysc.chval.
  else message 'Не заданы группы сделок по РЕПО ! ' view-as alert-box.
  find fun where fun.fun = deal.deal no-lock no-error.

  if  lookup(string(deal.grp), v-grp) > 0 then do:
   find first hisfun where hisfun.fun = deal.deal no-lock no-error.
   if avail hisfun then temp.prn = hisfun.dam[1] - hisfun.cam[1].
                   else if avail fun then  temp.prn = fun.dam[1] - fun.cam[1].
  if temp.prn < 0 then temp.prn = - temp.prn.
  temp.intamt = deal.yield.
  end.
  
  find bankl where bankl.bank eq deal.bank no-lock no-error.
  if avail bankl then do :
   temp.bank  =  bankl.bank.
   temp.name  =  bankl.name.
  end.
  find fun where fun.fun = deal.fun no-lock no-error.
  if avail fun then do.
   find crc where crc.crc = fun.crc no-lock no-error.
   if avail crc then temp.code = crc.code.
   else temp.code = 'N/A' .
  end.
  else do:
  find bfun where bfun.fun = deal.deal no-lock no-error.
  if avail bfun then do.
   find crc where crc.crc = bfun.crc no-lock no-error.
   if avail crc then temp.code = crc.code.
   end.
  end. /*else */
end.
for each temp break by temp.pr  by temp.code  by substr(temp.deal,4,3) by temp.valdt.
  
  accum temp.prn (total by temp.pr by temp.code  by substr(temp.deal,4,3)).
  accum temp.intamt (total by temp.pr by temp.code by substr(temp.deal,4,3)).
  if first-of(temp.pr) then 
     put stream m-out 
         skip(1) 
         space(10)
         if temp.pr = no then 'Привлеченные депозиты и кредиты'
         else 'Размещенные депозиты и кредиты' format 'x(31)'
         skip
         space(10)
         fill('-', 31) format 'x(31)' skip.
  put stream m-out
     temp.deal
     temp.bank
     temp.name format 'x(20)' '  '
     temp.prn
     temp.code ' '
     temp.valdt ' '
     temp.maturedt ' '
     temp.trm ' '
     temp.intrate format 'zz9.99' ' '
     temp.intamt '   '
     temp.rem format 'x(9)'  '   ' 
     temp.kol  format 'zzz,zzz,zzz'   ' '
     temp.nom  format 'zzz,zzz,zzz'     '   ' 
     temp.partner format 'x(25)'  ' ' 
     temp.who at 178 skip.
  put stream m-out
     space(10)
     substr(temp.name,21) format 'x(30)' skip.
  if last-of(substr(temp.deal,4,3)) then 
     put stream m-out
     fill('-', 181) format 'x(181)' skip
     space(10)
     'ИТОГО'
     space(24)
     accum total by substr(temp.deal,4,3) temp.prn format 'z,zzz,zzz,zzz,zz9.99' 
     ' '  
     space(26)
     accum total by substr(temp.deal,4,3) temp.intamt format 'z,zzz,zzz,zzz,zz9.99'
     skip(1).
  if last-of(temp.code) then 
     put stream m-out
     fill('-', 181) format 'x(181)' skip
     space(10)
     'ИТОГО'
     space(24)
     accum total by temp.code temp.prn format 'z,zzz,zzz,zzz,zz9.99' 
     ' ' temp.code 
     space(26)
     accum total by temp.code temp.intamt format 'z,zzz,zzz,zzz,zz9.99'
     skip(1).
end.
output stream m-out close.
if  not g-batch then do:
    pause 0 before-hide .
    run menu-prt( 'rpt.img' ).
    pause before-hide.
end.
{functions-end.i}
return.
