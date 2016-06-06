/* help-code.p
 * MODULE 
        Файл помощи для ввода   кодов доходов/расходов операций 
 * DESCRIPTION
        Файл помощи для ввода   кодов доходов/расходов операций 
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
        01/04/05 nataly
 * CHANGES
        16.06.05 nataly увеличена разрядность для описания кода
      23/01/06 nataly добавила признак архивности справочника 
*/

def input parameter v-gl like gl.gl.
def input parameter v-acc like jl.acc.

{skappbra.i 
      &head      = "cods"
      &index     = "codegl_id no-lock"
      &formname  = "hlpcods"
      &framename = "hcode  "
      &where     = " if v-acc = """" then  cods.gl = v-gl and cods.arc = no  else cods.gl = v-gl and cods.acc = v-acc and cods.arc = no "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "cods.code  cods.dep  cods.gl  cods.acc cods.des "
      &highlight = "cods.code "
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           hide frame hcode.
                           return string(cods.code).
                    end."
      &end = "hide frame hcode."
}

          



