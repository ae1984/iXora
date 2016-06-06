/* h-cifdss.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        11.11.2011 damir - перекомпиляция
*/

{global.i}

def shared var s-uninum as inte.

def var vnom  as char.
def var v-sel as char format "x(1)".

message "Выберите тип поиска F) ФИО  R) РНН" update v-sel.

case v-sel:
    when "F" or when "R" or when "А" or when "К" then do:
        vnom = ''. {imesg.i 2808} update vnom.
        hide message.
    end.
end.

if vnom <> "" then vnom = "*" + vnom + "*".

{jabdss.i
  &head       = cifdss
  &headkey    = uninum
  &formname   = "h-cifdss"
  &framename  = "cifdss"
  &where      = " ( if (v-sel = 'F' or v-sel = 'А') then (cifdss.fiomain matches vnom) else
                    if (v-sel = 'R' or v-sel = 'К') then (cifdss.rnnokpo matches vnom) else true) "
  &index      = " "
  &addcon     = "false"
  &deletecon  = "false"
  &predisplay = " "
  &display    = " cifdss.rnnokpo cifdss.dtnumreg cifdss.fiomain "
  &highlight  = " cifdss.rnnokpo cifdss.dtnumreg cifdss.fiomain "
  &postkey    = " else if keyfunction(lastkey) = 'return' then do:
                      s-uninum = cifdss.uninum.
                      leave upper.
                  end. "
  &subprg     = "securprog"
  &end        = " hide frame cifdss."
  }



