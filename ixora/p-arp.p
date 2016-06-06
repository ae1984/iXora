/* p-arp.p
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
        08/02/06 marinav   - вывод не на печать, а   в WORD
        06/07/06 marinav   - не печатать 102 повторно.
         
*/

/* p-valcon.p
   печать тенговых входящих платежей ,
   по 076 счету   remtrz.rsub = 'arp'
   24.07.2001 */

def var v-dat as date no-undo.
def var v-lbin as cha  no-undo.
def var v-lbina as cha no-undo.
def var v-rmz as char.
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
                    and remtrz.rsub  =  'arp'
                    and substr(remtrz.ba,4,3) = '076'
                    no-lock no-error.
if not avail remtrz then do.
   message 'Нет входящих платежей для печати!'.
   return.
end.                    

for each remtrz where remtrz.rdt   =  v-dat
                  and remtrz.ptype =  '7'
                  and remtrz.source = "LBI"
                  and remtrz.rsub  =  'arp'
                  and substr(remtrz.ba,4,3) = '076'
                  no-lock break by remtrz.amt. 
  /**/
    if lookup  (entry (1,remtrz.ref,"/"), v-rmz) > 0 then next.
    v-rmz = v-rmz + entry (1,remtrz.ref,"/") + ','.
  /**/
    if search (v-lbin + entry (1,remtrz.ref,"/")) =
               v-lbin  + entry (1,remtrz.ref,"/")
       then /*unix value("prit " + v-lbin  + entry (1,remtrz.ref,"/")) .*/ unix value ("cat " + v-lbin  + entry (1,remtrz.ref,"/") + " >> rpt2.img" ).
    else do :
       if search (v-lbina + entry (3,remtrz.ref,"/") + ".Z") =
                 v-lbina + entry (3,remtrz.ref,"/") + ".Z"
          then do:
           unix silent value ("uttview3 " + v-lbina + entry (3,remtrz.ref,"/") + ".Z" +
                     " " + entry (1,remtrz.ref,"/") ) .
        /*   pause 0. 
           unix value ("cat " + entry (1,remtrz.ref,"/") + " >> rpt2.img" ).
           pause 0.   
           unix value ("rm " + entry (1,remtrz.ref,"/")).
           pause 0.   */
          end.
    end.

 end.
/*08/02/06 marinav*/
/*unix value ( 'prit rpt.img' ).*/
 run menu-prt( 'rpt2.img' ).
 pause 0.   
 unix value ("rm rpt2.img").
