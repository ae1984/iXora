/* s-lnrskp.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Внесение и редактирование баланса по пассиву 
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
        01.12.03 marinav - возможность заводить баланс из кредитного досье
        14/05/2004 madiar - Поставил no-lock в for each bal_cif
                            По окончании удаления/создания записей в bal_cif - find current bal_cif no-lock.
      30.09.2005 marinav - изменения для бизнес-кредитов
*/



{global.i}
{kd.i}
def input parameter k as integer.
def input parameter v-sel as char.
define  new shared variable v-cif    like bal_cif.cif.
def new shared var v-dat like bal_cif.rdt.
def var stitle as char format "x(25)".
def var iLine as char format "x(3)".
def var iLen as integer.
def var sum1 like bal_cif.amount.
def var sum2 like bal_cif.amount.
def var sum3 like bal_cif.amount.
def var sum1sum2 like bal_cif.amount.
define var vans as log format "Yes/No".

v-dat = g-today.


define new shared var w-lonrsk like bal_cif.amount extent 22.
def new shared var i as integer.


{s-lnrskp.f}

if k = 1 then stitle = 'Введение новых данных'.
         else stitle = 'Редактирование баланса'.

/*if keyfunction(lastkey) eq "end-error" then hide all.*/

  if s-kdcif = '' then do:
    display stitle with frame f-cif.
    update v-cif with frame f-cif.
    find cif where cif.cif = v-cif no-lock no-error.
    display trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname with frame f-cif.
    update v-dat with frame f-cif.
  end. 
  else do:
    display stitle with frame f-cif1.
    find kdcif where kdcif.bank = s-ourbank and kdcif.kdcif = s-kdcif no-lock no-error.
    v-cif = s-kdcif.
    update v-dat with frame f-cif1.
  end.
  if keyfunction(lastkey) eq "end-error" then  return.

   if k = 1 then do:
     find first bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat and bal_cif.nom begins 'p' and bal_cif.rem[1] = v-sel no-lock no-error.
     if avail bal_cif then do: message 'В базе данные по этому клиенту уже есть'. pause 5. hide frame f-cif. return. end.
   end.
   else do:
     find first bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat and bal_cif.nom begins 'p' and bal_cif.rem[1] = v-sel no-lock no-error.
     if not avail bal_cif then do: message 'В базе нет данных по этому клиенту за дату ' v-dat. pause 5. hide frame f-cif. return. end.
   end. 

   if k = 2 then do:
      i = 1.
      for each bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat and bal_cif.nom begins 'p' and bal_cif.rem[1] = v-sel use-index nom no-lock:
          w-lonrsk[i] = bal_cif.amount.
          i = i + 1.
      end.
   end.


   if v-sel = '01' then run bal01.
   if v-sel = '02' then run bal02.

   if k = 2 then do:
      delete from bal_cif where bal_cif.cif = v-cif and bal_cif.rdt = v-dat and bal_cif.nom begins 'p' and bal_cif.rem[1] = v-sel.
   end.
   
   do i = 1 to extent(w-lonrsk):
      iLen  = LENGTH(string(i)).
      IF iLen >= 2 THEN iLine = SUBSTRING( string(i), 1, iLen ).
      IF iLen < 2 THEN iLine = FILL( '0', 2 - iLen ) + string(i).
      create bal_cif.
      bal_cif.nom = 'p' + iLine.
      bal_cif.cif = v-cif.
      bal_cif.rdt = v-dat.
      bal_cif.amount = w-lonrsk[i].
      bal_cif.whn = g-today.
      bal_cif.who = g-ofc.  
      bal_cif.rem[1] = v-sel.
   end.
   find current bal_cif no-lock no-error.



procedure bal01.

   do i = 1 to extent(w-lonrsk):
      display w-lonrsk[i] with frame lonrsk.
   end.

   update  
        w-lonrsk[1]
        w-lonrsk[2]
        w-lonrsk[3]
        w-lonrsk[4]
        w-lonrsk[6]
        w-lonrsk[7]
        with frame lonrsk.
        w-lonrsk[5]  = w-lonrsk[6] + w-lonrsk[7].
        sum1 = w-lonrsk[1] + w-lonrsk[2] + w-lonrsk[3] 
              + w-lonrsk[4] + w-lonrsk[5].
   display w-lonrsk[5] sum1 with frame lonrsk.

   update
        w-lonrsk[8]
        w-lonrsk[9]
        w-lonrsk[10]
        with frame lonrsk.
       sum2 = w-lonrsk[8] + w-lonrsk[9] + w-lonrsk[10].
   display sum2 with frame lonrsk.
   update
        w-lonrsk[11]
        w-lonrsk[12] 
        w-lonrsk[13]
        w-lonrsk[14]
        w-lonrsk[15]
        w-lonrsk[16] 
        w-lonrsk[17]
        w-lonrsk[22]
        w-lonrsk[18]
        w-lonrsk[19]
        w-lonrsk[20] 
        w-lonrsk[21]
   with frame lonrsk.
   sum3 = w-lonrsk[11] + w-lonrsk[12] + w-lonrsk[13] 
        + w-lonrsk[14] + w-lonrsk[15] + w-lonrsk[16]
        + w-lonrsk[17] + w-lonrsk[18] + w-lonrsk[19]
        + w-lonrsk[20] + w-lonrsk[21]+ w-lonrsk[22].
   sum1sum2 = sum1 + sum2 + sum3.
   display sum3 sum1sum2 with frame lonrsk.
   vans = yes.
   update vans with frame lonrsk.
   if vans eq false then return.
   
hide frame lonrsk.
hide frame f-cif.

end.


procedure bal02.

   do i = 1 to 5:
      display w-lonrsk[i] with frame lonrsk_b.
   end.

   update  
        w-lonrsk[1]
        w-lonrsk[2]
        w-lonrsk[3]
        w-lonrsk[4]
        w-lonrsk[5]
        with frame lonrsk_b.
   sum1sum2 = w-lonrsk[1] +
              w-lonrsk[2] + 
              w-lonrsk[3] +
              w-lonrsk[4] +
              w-lonrsk[5] .
   display  sum1sum2 with frame lonrsk_b.

   vans = yes.
   update vans with frame lonrsk_b.
   if vans eq false then return.

hide frame lonrsk_b.
hide frame f-cif.

end.

