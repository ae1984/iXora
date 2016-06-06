/* p-valcon.p
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
        04.08.2005 marinav - выводится дата последнего закрытого опердня
*/
/* p-valcon.p
   печать тенговых входящих платежей (МТ100),
   подлежащих валютному контролю, т.е. от нерезидентов,
   remtrz.rsub = 'valcon'
   27.03.2001
   7.12.2001 /sasco/ - при печати 100 группы выводятся их RMZ-номера
*/

def var v-dat as date.
def var v-lbin as cha .
def var v-lbina as cha.
def stream m-out.
{global.i new}

find last cls no-lock no-error.
g-today = if available cls then cls.whn else today.
v-dat = g-today.

update v-dat label ' Укажите дату регистрации платежей' format '99/99/9999'
       validate(v-dat ge 12/19/1999 and v-dat le g-today,
       "Дата должна быть в пределах от 19.12.1999 до текущего дня")
       skip with side-label row 5 centered frame dat .
                     
display '   Ждите...   '  with row 5 frame ww centered .

find sysc where sysc.sysc = "lbin" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   message "Отсутствует запись LBIN в таблице SYSC!".
   return .
end.
v-lbin = sysc.chval.
find sysc where sysc.sysc = "LBINA" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   message "Отсутствует запись  LBINA в таблице SYSC!".
   return .
end.
v-lbina = sysc.chval.
find first remtrz where remtrz.rdt   =  v-dat
                    and remtrz.ptype =  '7'
                    and remtrz.source = "LBI"
                    and remtrz.rsub  =  'valcon'
                    no-lock no-error.
if not avail remtrz then do.
   message 'Нет входящих платежей для печати!'.
   return.
end.                    

output stream m-out to rpt.img.

for each remtrz where remtrz.rdt   =  v-dat
                  and remtrz.ptype =  '7'
                  and remtrz.source = "LBI"
                  and remtrz.rsub  =  'valcon'
                  no-lock break by remtrz.amt. 

 if entry (2,remtrz.ref,"/") = '100' then do.

    if search (v-lbin + entry (1,remtrz.ref,"/")) =
               v-lbin  + entry (1,remtrz.ref,"/")
       then do:
            unix value("prit " + v-lbin  + entry (1,remtrz.ref,"/")).
            end.
    else do :
       if search (v-lbina + entry (3,remtrz.ref,"/") + ".Z") =
                 v-lbina + entry (3,remtrz.ref,"/") + ".Z"
          then do:
            output to rmz.img.
            put skip(2) "Doc.Nr.:" remtrz.remtrz skip.
            unix silent prit rmz.img.
            output close.

           unix value ("uttview2 " + v-lbina + entry (3,remtrz.ref,"/") + ".Z" +
                     " " + entry (1,remtrz.ref,"/") ) .
          end.
    end.
 pause 0 no-message.
 end.
 else do.
      put stream m-out entry (1,remtrz.ref,"/") format 'x(15)' ' '
                       remtrz.amt format 'zzz,zzz,zz9.99' skip.
 end.
end.
output stream m-out close.
unix value ( 'prit rpt.img' ).
pause before-hide.   
