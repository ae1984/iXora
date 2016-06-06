/* cfsprav-type.p
 * MODULE
        Выбор языка для формиров-я справки
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
        26/09/2006 u00777
 * CHANGES
*/

{global.i}


def output parameter v-type1 as integer no-undo.
def output parameter v-typen as char no-undo.
def shared temp-table t-type no-undo
    field id_type as integer
    field nm_type as char
index id_type id_type.

def var vans as logical.

{jabr.i 

  &start     =  " "
  &head      =  "t-type"
  &headkey   =  "id_type"
  &index     =  "id_type"
  &formname  =  "cfsprav-type"
  &framename =  "f-type"
  &where     =  " true "
  &addcon    =  "false"
  &deletecon =  "false"
  &prechoose =  " "
  &predisplay = " "
  &display   =  " t-type.id_type t-type.nm_type "
  &highlight =  " t-type.id_type t-type.nm_type "
  &postkey   =  " else if keyfunction(lastkey) = 'return' then do:                                     
                    assign v-type1 = t-type.id_type          
                           v-typen = t-type.nm_type.               
                  leave upper.
                  end. " 
  &end =        " hide frame f-type. "
}
 

