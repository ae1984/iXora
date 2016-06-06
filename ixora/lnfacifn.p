/* lnfacifn.p
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

/*
* lnfacifn.p
* Программа добавления нового номера facif
*/
{global.i}
{s-liz.i}

def var    v-prefix  like sysc.chval.
def var    v-facif   like facif.facif.

find first sysc where sysc.sysc = "FACIFP" no-lock no-error.
if available sysc then
   v-prefix = trim(sysc.chval).
else
   v-prefix = "P".

cgFacifFacif = "".
repeat while cgFacifFacif = "":
   do transaction :
      find sysc where sysc.sysc eq "FACIFN" exclusive-lock.
      v-facif = v-prefix + string(sysc.inval, "99999").
      sysc.inval  = sysc.inval + 1.
      release sysc.
   end.
   
   cgFacifFacif  = v-facif.
   
   /*do transaction:
      create facif.
      facif.facif  = v-facif.
      facif.fanrur = v-facif.
      cgFacifFacif  = v-facif.
      release facif.
   end.*/
end.
