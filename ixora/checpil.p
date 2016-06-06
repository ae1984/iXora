/* checpil.p
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
        31/12/99 pragma
 * CHANGES
        07.10.05 dpuchkov добавил серию чека
        21.10.05 dpuchkov добавил проверку на латинские буквы в серии чека
        28/06/2012 dmitriy - добавил параметр bank при поиске записей в таблицах gram и checks
*/

/* checpil.p - Pilna inform–cija par ўeka gr–mati‡u
*/

define new shared var s-aaa like aaa.aaa.
def var chnu as int format "9999999".
def var c-cif like gram.cif.
def var c-dat like gram.atzdat.
def var c-whi like gram.ienwho.
def var c-non like gram.nono.
def var c-lid like gram.lidzno.
def var c-ien like gram.iendat.
def var c-izm like gram.izmatz.
def var c-anu like gram.anuatz.
def var c-wha like gram.atzwho.
def var c-cek like gram.cekcen.

def var v-ser as char.

{mainhead.i}
{checpil.f}
repeat:
   message "Введите номер чека".
   update chnu  label "НОМЕР ЧЕКА"
          v-ser validate(v-ser <> "","Введите номер серии") label "CЕРИЯ ЧЕКА" format "x(2)"
   with side-labels  frame vasa.
v-ser = lower(v-ser).
 if lookup(substr(v-ser, 1 ,1),"q,a,z,w,s,x,e,d,c,r,f,v,t,g,b,y,h,n,u,j,m,i,k,l,o,p") <> 0 then do:
    message "Необходимо ввести серию русскими буквами"  view-as alert-box title "".  undo,retry.
 end.


   find last gram where gram.nono le chnu and
                     gram.lidzno ge chnu and gram.ser <> "" and gram.ser = v-ser and gram.bank = "F" no-lock no-error.
  if not available gram then
    find last gram where gram.nono le chnu and
                     gram.lidzno ge chnu and gram.ser = "" and gram.bank = "F" no-lock no-error.

   if not available gram then do:
    message
    "Чековой книжки с таким номером нет в системе. Введите другой номер.".
     undo,retry.
   end.
   else do:

 c-cif = gram.cif.
 c-dat = gram.atzdat.
 c-whi = gram.ienwho.
 c-non = gram.nono.
 c-lid = gram.lidzno.
 c-ien = gram.iendat.
 c-izm = gram.izmatz.
 c-anu = gram.anuatz.
 c-wha = gram.atzwho.
 c-cek = gram.cekcen.

    if c-izm ne " " then
    do:
   find cif where cif.cif =c-cif no-lock no-error.
    /*  if c-izm ne " " then
        do:*/
        find last checks where checks.nono = c-non and checks.ser <> "" and checks.ser = v-ser and checks.bank = "F" no-error.
        if not avail checks then
        find last checks where checks.nono = c-non and checks.ser = ""  and checks.bank = "F" no-error.


        disp
        c-cif c-dat c-whi c-non c-lid c-ien c-anu c-izm c-wha c-cek
        trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname checks.jh
        with frame checpil.
       end.
      else do:
        disp
        c-cif c-dat c-whi c-non c-lid c-ien c-anu c-izm c-wha c-cek
        /*cif.sname checks.jh  */
        with frame checpol.
      end.
end.
clear frame checpil.
clear frame checpol.
end.
