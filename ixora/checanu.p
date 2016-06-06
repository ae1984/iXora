/* checanu.p
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
*/

/*checanu.p
31.07.95 - ўeku gr–matas anulёta
*/

{mainhead.i}
def var v1 as integer initial 000025.
def var v3 as integer initial 25.
def var v2 as integer initial 000024.
def var pirmno as int.
def var otrno as int.
def var c-non like checks.nono.
def var c-lid like checks.lidzno.
def var c-pri like checks.prizn.
def var c-cel like checks.celon.
def var s-cif like checks.cif.
def var ok as int.
def var kk as int.
def var bbb as int format "9999999".
def var v-ser as char init "".
repeat:

c-non = 0. c-lid = 0.
disp g-today label " ДАТА ".
disp bbb label "НОМЕР ЧЕКА".
update
   bbb.
update
   v-ser validate(v-ser <> "","Введите номер серии") label "Серия" format "x(2)".
   v-ser = lower(v-ser).
 if lookup(substr(v-ser, 1 ,1),"q,a,z,w,s,x,e,d,c,r,f,v,t,g,b,y,h,n,u,j,m,i,k,l,o,p") <> 0 then do:
    message "Необходимо ввести серию русскими буквами"  view-as alert-box title "".  undo,retry.
 end.


     find first checks where checks.nono le bbb  
                       and checks.lidzno ge bbb and checks.ser <> "" and checks.ser = v-ser
                       and checks.prizn ne "*" /*no-lock*/ no-error.

     if not available checks then
     find first checks where checks.nono le bbb  
                       and checks.lidzno ge bbb and  checks.ser = "" and checks.prizn ne "*" /*no-lock*/ no-error.



     if not available checks
         then do:
              bell.
              message "Чековая книжка не использована, либо уже аннулирована.".
              undo, retry.
          end.
          else do:
          s-cif = checks.cif.
          disp s-cif label " КОД КЛИЕНТА".
          find cif where cif.cif = s-cif no-lock no-error.
          disp trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)" label "  НАИМЕНОВАНИЕ КЛИЕНТА".
          c-cel = " ".
          update
                 c-cel label "   ПРИЧИНА". /*with frame anu. */
            c-non = checks.nono.
            checks.prizn = "*".
            checks.celon = c-cel.
            checks.undt = g-today.
            checks.whu = g-ofc.
          end.
          /*
          c-non = checks.nono. */
     find first gram where gram.nono = c-non and gram.ser <> "" and gram.ser = v-ser no-error.
     if not available gram then
     find first gram where gram.nono = c-non and gram.ser = "" no-error.

     bbb = 0.
     if not available gram
         then do:
              message "Чековой книжки с таким номером нет.".
          end.
          else do:
          gram.izmatz = " ".
          gram.anuatz = "*".
          end.
end.
