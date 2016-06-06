/* unikl.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Анализ переводов по клиентам за период изменения от 24.04.00
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
        03.12.2004 saltanat - Внесла выборку банков из справочников.
        10.12.2004 saltanat - Формирование отчета реализовала через временную таблицу.
                              Внесена выборка по валюте.
        06.01.2005 saltanat - Выборка по головному банку.
        18.12.2005 tsoy     - добавил время создания платежа.
        05/09/2006 u00600   - оптимизация
*/

{global.i }
def var vdt   as   date .
def var dat1   as   date format "99/99/9999" .
def var dat2   as   date format "99/99/9999" .
def var t-sb   as   cha  format "x(15)" .
def var t-rb   as   cha  format "x(15)" .
def var a-s    as   dec  format "-zzz,zzz,zzz,zzz,zz9.99" .
def var a-c    as   int  format ">>>9" .
def var aa-c   as   int  format ">>>9" init 0 .
def var aa-cc  as   int  format ">>>9" init 0 .
def var t-s1   like a-s  .
def var t-s2   like a-s  .
def var t-c1   like a-c  .
def var t-c2   like a-c  .
def var t-sort as   log  format "отправитель/получатель" init false .
def var ff     as   cha  format "x(50)" init "joe".
def var t-ba   as   cha  .
def var t-bb   as   cha  .
def var t-acc  as   cha  format "x(15)" init "*" .
def var v-crc  as   int  format ">9"  init 0 .

/* Создаем временную таблицу с новыми индексами */
def temp-table tremtrz like remtrz
               use-index rdt       use-index rem       use-index sbnksqn  
               use-index valdt1    use-index valdt2    use-index cracc 
               use-index dracc     use-index amt       use-index src
               index ptype ptype   index fcrc fcrc     index tcrc tcrc
               index rbank rbank   index drgl drgl     index crgl crgl
               index scbank scbank index rcbank rcbank index sacc sacc 
               index racc racc.
               
find first sysc where sysc.sysc = "BEGDAY" no-lock no-error .
if avail sysc then
 dat1 = sysc.daval .
else
 dat1 = g-today - 30 . 

dat2 = g-today .

t-sb = "*" . t-rb = "*" .
t-s1 = 0 . t-s2 = 999999999999999.99 .
t-c1 = 0 . t-c2 = 9999 .

define frame qx skip(1)
    "Дата платежа: с" dat1 " до" dat2 skip
    "Банк плательщика :" t-sb "  Банк получателя :" t-rb skip
    "Сумма : с" t-s1 " до" t-s2 skip
    "Кол-во : с" t-c1 " до" t-c2 skip
    "Сортировка :" t-sort 
    "  Счет :" t-acc skip
    "Валюта :" v-crc skip
    with no-label title " Введите данные " centered row 4.

on help of t-sb in frame qx do:
t-sb = ''.
{itemlist.i 
&file = "bankl"
&frame = "row 6 centered scroll 1 12 down overlay "
&where = " bankl.bank = bankl.cbank "
&flddisp = " bankl.bank label 'МФО' format 'x(20)'
                 bankl.name label 'Наименование' format 'x(50)'
               "
&chkey = "bank"
&chtype = "string"
&index  = "bank"
&end = "if keyfunction(lastkey) eq 'end-error' then return."
}
   /*if t-sb <> "*" and bankl.bank <> '' then t-sb = t-sb + ',' + bankl.bank.
   else*/ t-sb = bankl.bank.
   displ t-sb with frame qx.
end.

on help of t-rb in frame qx do:
t-rb = ''.
{itemlist.i 
&file = "bankl"
&frame = "row 6 centered scroll 1 12 down overlay "
&where = " bankl.bank = bankl.cbank "
&flddisp = " bankl.bank label 'МФО' format 'x(20)'
                 bankl.name label 'Наименование' format 'x(50)'
               "
&chkey = "bank"
&chtype = "string"
&index  = "bank"
&end = "if keyfunction(lastkey) eq 'end-error' then return."
}
   /*if t-rb <> "*" and bankl.bank <> '' then t-rb = t-rb + ',' + bankl.bank.
   else*/ t-rb = bankl.bank.
   displ t-rb with frame qx.
end.

update 
    dat1 dat2 
    t-sb t-rb 
    t-s1 t-s2 
    t-c1 t-c2 
    t-sort t-acc 
    v-crc
with frame qx .

for each bankl where bankl.cbank = t-sb and bankl.bank <> bankl.cbank no-lock.
    if t-sb = '' then t-sb = bankl.bank.
    else t-sb = t-sb + ',' + bankl.bank.
end.

for each bankl where bankl.cbank = t-rb and bankl.bank <> bankl.cbank no-lock.
    if t-rb = '' then t-rb = bankl.bank.
    else t-rb = t-rb + ',' + bankl.bank.
end.

output to rpt.img .

put unformatted "Дата        : " string(today,"99/99/9999") skip
  "Время       : " string(time,"hh:mm:ss") skip
  "Исполнитель : " g-ofc skip .
put unformatted skip(2) "Анализ переводов по клиентам и банкам." at 34
  skip
  "за " + string(dat1,"99/99/9999") + " - " + string(dat2,"99/99/9999") at 41
  skip(1) .

do vdt = dat1 to dat2.
/* *********  Выборка данных во временную таблицу  ********* */
for each remtrz where
    remtrz.rdt = vdt and (remtrz.ptype = '6' or remtrz.ptype = '7') 
    /*and remtrz.jh1 <> ?*/ no-lock. 

  if remtrz.jh1 = ? then next.

  if remtrz.ba matches "*" + t-acc + "*"
  and remtrz.ord <> ""  and ( remtrz.bn[1] <> "" or remtrz.bn[2] <> ""
                            or remtrz.bn[3] <> "" )
  and if t-sb = "*" then true else lookup(remtrz.sbank, t-sb) > 0  
  and if t-rb = "*" then true else lookup(remtrz.rbank, t-rb) > 0 
  and if v-crc = 0 then true else remtrz.fcrc = v-crc then do:

    create tremtrz.
    tremtrz.rtim = time. 

    buffer-copy remtrz to tremtrz.

  end.

end. 
end.

if not t-sort then do :

put unformatted fill("-",131) skip .
put "БанкО      СчетО           Отправитель                 Кол-во" 
    "                   Сумма"
    " СчетП           Получат"
    skip .
put unformatted fill("-",131) skip(1) .

for each tremtrz
         use-index rdt  
         break               
         by tremtrz.fcrc
         by tremtrz.ptype
         by tremtrz.rbank 
         by substring(tremtrz.bb[1] + tremtrz.bb[2] + tremtrz.bb[3],1,50)
         by if tremtrz.ba begins "/"                        
            then substr(tremtrz.ba,2,15) else substr(tremtrz.ba,1,15)
         by substr(tremtrz.bn[1] + tremtrz.bn[2] + tremtrz.bn[3],1,12)
         by tremtrz.sbank by tremtrz.sacc by substr(tremtrz.ord,1,12) .

 a-s = a-s + tremtrz.amt .
 a-c = a-c + 1 .
 aa-c = aa-c + 1 .
 aa-cc = aa-cc + 1 .
 accum tremtrz.amt (total by tremtrz.fcrc by tremtrz.ptype by tremtrz.rbank).

 if first-of(tremtrz.rbank) then do:
 t-ba = string(tremtrz.rbank,"x(11)") + '   ' + tremtrz.bb[1] + tremtrz.bb[2]
     + tremtrz.bb[3] .
 t-bb = t-ba .
 put "Банк получателя :" + t-ba format "x(99)" at 30 skip(1).
 end.

 if (last-of(tremtrz.sacc) 
   or (tremtrz.sacc = "" and last-of(substr(tremtrz.ord,1,12))))
   and a-s >= t-s1 and a-s <= t-s2 and a-c >= t-c1 and a-c <= t-c2
   then  do :
  t-ba = if tremtrz.ba begins "/" then substr(tremtrz.ba,2) else tremtrz.ba .
  if index(t-ba,"/") > 0 then t-ba = substr(t-ba,1,index(t-ba,"/") - 1) .
  else
    if index(t-ba,",") > 0 then t-ba = substr(t-ba,1,index(t-ba,",") - 1) .
    else
     if index(t-ba," ") > 0 then t-ba = substr(t-ba,1,index(t-ba," ") - 1) .
  put 
    tremtrz.sbank format "x(10)" at 1
    tremtrz.sacc format "x(15)" at 12 
    tremtrz.ord format "x(29)" at 28
    a-c at 58
    a-s at 63
    t-ba format "x(15)" at 87
    (tremtrz.bn[1] + tremtrz.bn[2] + tremtrz.bn[3]) format "x(29)" at 103 
    skip .
  pause 0 .
  a-c = 0 .
  a-s = 0 .
 end .

   if last-of(tremtrz.rbank) then do:
         put unformatted fill("-",131) skip . 
         put 'Итого    :' at 37
              tremtrz.rbank at 47 
               aa-c at 58
               (ACCUM TOTAL BY tremtrz.rbank  tremtrz.amt )
               format "-zzz,zzz,zzz,zzz,zz9.99" at 63 skip(1).
               aa-c = 0.
   end.

   if last-of(tremtrz.ptype) then do:
      put unformatted fill("-",131) skip .
      put 'Итого ' at 33. 
      if tremtrz.ptype = '6' then
         put 'исходящие платежи:' at 39.
      else put 'входящие платежи:' at 39.    
      put aa-cc at 58 
      (ACCUM TOTAL BY tremtrz.ptype  tremtrz.amt )
      format "-zzz,zzz,zzz,zzz,zz9.99" at 63 skip.
      aa-cc = 0.
   put unformatted fill("-",131) skip(1) .
   end.

end .  
end .
else do :

put unformatted fill("-",131) skip .
put "БанкП      СчетП           Получатель                  Кол-во" 
    "                   Сумма"
    " СчетО             Отправит."
    skip .
put unformatted fill("-",131) skip(1) .

for each tremtrz 
  use-index rdt  
  break
  by tremtrz.fcrc
  by tremtrz.ptype
  by tremtrz.sbank 
  by substr(tremtrz.ordins[1] + tremtrz.ordins[2] 
    + tremtrz.ordins[3] + tremtrz.ordins[4],1,50)
  by tremtrz.sacc by substr(tremtrz.ord,1,12)
  by tremtrz.rbank
  by if tremtrz.ba begins "/" 
    then substr(tremtrz.ba,2,15) else substr(tremtrz.ba,1,15)
  by substr(tremtrz.bn[1] + tremtrz.bn[2] + tremtrz.bn[3],1,12) .
 a-s = a-s + tremtrz.amt .
 a-c = a-c + 1 .
 aa-c = aa-c + 1 .
 aa-cc = aa-cc + 1 .
 accum tremtrz.amt (total by tremtrz.fcrc by tremtrz.ptype by tremtrz.sbank).

 if first-of(tremtrz.sbank) then do:
    t-ba = string(tremtrz.sbank,"x(11)") + '   ' + tremtrz.ordins[1] + " "
    + tremtrz.ordins[2] + " " + tremtrz.ordins[3] + " " + tremtrz.ordins[4] .
    t-bb = t-ba . 
    put "Банк отправителя :" + t-bb format "x(100)" at 32 skip(1).
 end .

 if (last-of(if tremtrz.ba begins "/" 
   then substr(tremtrz.ba,2,15) else substr(tremtrz.ba,1,15)) 
   or (length(tremtrz.ba) <=1 
   and last-of(substr(tremtrz.bn[1] + tremtrz.bn[2] + tremtrz.bn[3],1,12 ))))
   and a-s >= t-s1 and a-s <= t-s2 and a-c >= t-c1 and a-c <= t-c2
   then do :
     t-ba = if tremtrz.ba begins "/" then substr(tremtrz.ba,2) else tremtrz.ba .
     if index(t-ba,"/") > 0 then t-ba = substr(t-ba,1,index(t-ba,"/") - 1) .
     else 
       if index(t-ba,",") > 0 then t-ba = substr(t-ba,1,index(t-ba,",") - 1) .
       else 
        if index(t-ba," ") > 0 then t-ba = substr(t-ba,1,index(t-ba," ") - 1) .
     put 
     tremtrz.rbank format "x(10)" at 1
     t-ba format "x(15)" at 12
     (tremtrz.bn[1] + tremtrz.bn[2] + tremtrz.bn[3]) format "x(29)" at 28
     a-c at 58
     a-s at 63
     tremtrz.sacc format "x(15)" at 87
     tremtrz.ord format "x(29)" at 103 skip.
     pause 0 .
     a-c = 0 .
     a-s = 0 .
 end .

 if last-of(tremtrz.sbank) then do:
    put unformatted fill("-",131) skip .
    put 'Итого    :' at 40
        tremtrz.sbank at 50
        aa-c at 58
        (ACCUM TOTAL BY tremtrz.sbank  tremtrz.amt )
        format "-zzz,zzz,zzz,zzz,zz9.99" at 63 skip(1).
    aa-c = 0.
 end.

 if last-of(tremtrz.ptype) then do:
    put unformatted fill("-",131) skip .
    put 'Итого ' at 33.
    if tremtrz.ptype = '6' then
       put 'исходящие платежи:' at 39.
       else put 'входящие платежи:' at 39.
    put aa-cc at 58
        (ACCUM TOTAL BY tremtrz.ptype  tremtrz.amt )
        format "-zzz,zzz,zzz,zzz,zz9.99" at 63 skip.
    aa-cc = 0.
    put unformatted fill("-",131) skip(1) .
 end.

end .
end .

output close .

if  not g-batch then do:
    pause 0.
    run menu-prt( 'rpt.img' ).
end.
