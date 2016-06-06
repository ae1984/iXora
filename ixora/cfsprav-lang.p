/* cfsprav-lang.p
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

def output parameter v-lang1 as integer.
def output parameter v-langn as char.
def shared temp-table t-lang no-undo
    field id_lang as integer
    field nm_lang as char
index id_lang id_lang.

def var vans as logical.

{jabr.i 

  &start     =  " "
  &head      =  "t-lang"
  &headkey   =  "id_lang"
  &index     =  "id_lang"
  &formname  =  "cfsprav-lang"
  &framename =  "f-lang"
  &where     =  " true "
  &addcon    =  "false"
  &deletecon =  "false"
  &prechoose =  " "
  &predisplay = " "
  &display   =  " t-lang.id_lang t-lang.nm_lang "
  &highlight =  " t-lang.id_lang t-lang.nm_lang "
  &postkey   =  " else if keyfunction(lastkey) = 'return' then do:                                     
                    assign v-lang1 = t-lang.id_lang         
                           v-langn = t-lang.nm_lang.          
                    leave upper.
                  end. " 
  &end =        " hide frame f-lang. "
}
 

