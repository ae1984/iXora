/* help-code2.p
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
*/


{skappbra.i 
      &head      = "cods"
      &index     = "codegl_id no-lock"
      &formname  = "hlpcods"
      &framename = "hcode  "
      &where     = " "
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

          



