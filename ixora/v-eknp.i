/* v-eknp.i
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

function v-eknp returns char (input v-cif as char, 
			      input v-remtrz as char,
                              input v-rezp as char, 
                              input v-secp as char,
                              input v-knp as int). 

/* заполнение кодов ЕКНП */

def var l-eknp as char.
def var v-rezo as char.           /* признак резиденства для отправителя */
def var v-seco as char.           /* код сектора экономики */
/* для получателя */

find sub-cod where sub-cod.acc = v-remtrz
               and sub-cod.sub = 'rmz'
               and sub-cod.d-cod = 'eknp'
               and sub-cod.ccode = 'eknp' no-error.
if not avail sub-cod then do:   

   /* определение кодов отправителя */

   /* признак резиденства */
   find cif where cif.cif = v-cif no-lock no-error.
   if avail cif  then do:
      if substr(cif.geo,3,1) eq '1' then v-rezo = '1'.
      else v-rezo = '2'.
   end.
   /* сектор экономики */
   find sub-cod where sub-cod.acc = v-cif
                  and sub-cod.sub = 'cln'
                  and sub-cod.d-cod = 'secek' no-lock no-error.
   if avail sub-cod and sub-cod.ccode ne 'msc'
      then v-seco = sub-cod.ccode.
   if v-rezo ne '' and v-seco ne '' then do:
    create sub-cod.
    sub-cod.acc   = v-remtrz.
    sub-cod.sub   = 'rmz'.
    sub-cod.d-cod = 'eknp'.
    sub-cod.ccode = 'eknp' .
    sub-cod.rcode = v-rezo + v-seco + ',' + v-rezp + v-secp + ',' +      string(v-knp,"999").
    l-eknp = sub-cod.rcode.
    end.
 end.
 else do:
   entry(2,sub-cod.rcode,',') = v-rezp + v-secp.
   entry(3,sub-cod.rcode,',') = string(v-knp).
   l-eknp = sub-cod.rcode.
 end.
 return l-eknp. 
 
end function.  
