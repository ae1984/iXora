/* help-dep.p
 * MODULE
        Файл помощи для ввода   департамента для модуля "Коды доходов/расходов" 
 * DESCRIPTION
        Файл помощи для ввода   департамента для модуля "Коды доходов/расходов" 
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
        01.04.05 nataly
 * CHANGES
*/

def input parameter v-dep like codfr.code.

{skappbra.i 
      &head      = "codfr"
      &index     = "cdco_idx no-lock"
      &formname  = "hlpcods"
      &framename = "hdep  "
      &where     = "codfr.codfr = ""sdep"" and 
                  ( if v-dep <> ""000""  and v-dep <> """" then codfr.code = v-dep else codfr.code = codfr.code) and codfr.code <> ""msc"" "
      &addcon    = "false"
      &deletecon = "false"
      &display   = "codfr.code COLUMN-LABEL ""Код"" codfr.name[1]   COLUMN-LABEL ""Наименование"" format ""x(45)"" "
      &highlight = "codfr.code "
      &postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                          on endkey undo, leave:
                           hide frame hdep.
                           return string(codfr.code).
                    end."
      &end = "hide frame hdep."
}

          



