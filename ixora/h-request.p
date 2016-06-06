/* h-request.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Вывод найденных документов
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
        20.01.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
*/

{vc.i}

def shared var s-contract like vccontrs.contract.
def shared var s-vcdoctypes as char.
def shared var s-dnvid as char.
def shared var s-docs like vcdocs.docs.


{global.i}
find first vcdocs where vcdocs.contract = s-contract and (vcdocs.dntype = "28" or vcdocs.dntype = "29") no-lock no-error.
if avail vcdocs then do:
  {jabro.i
  &head      =  "vcdocs"
  &headkey   =  "docs"
  &formname  =  "h-request"
  &framename =  "h-request"
  &where     =  " (vcdocs.contract = s-contract) and (vcdocs.dntype = '28' or vcdocs.dntype = '29')"
  &index     =  "main"
  &addcon    =  "false"
  &deletecon =  "false"
  &predisplay = " find codfr where codfr.codfr = 'vcdoc' and codfr.code = vcdocs.dntype
                        no-lock no-error."
  &display   =  " codfr.name[2] vcdocs.dnnum vcdocs.dndate when (index(s-dnvid, 'z') > 0) "
  &highlight =  " codfr.name[2] vcdocs.dnnum vcdocs.dndate "
  &postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                    s-docs = vcdocs.docs.
                    leave upper.
                  end."
  &end =        " hide frame h-request."
  }
end.
else do: message " Документы не найдены.". pause. end.

