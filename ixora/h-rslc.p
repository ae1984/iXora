/* h-rslc.p
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

/* h-rslc.p Валютный контроль
   Поиск-список рег.св-в/лицензий

   18.10.2002 nadejda создан
*/

{vc.i}

def shared var s-contract like vccontrs.contract.
def shared var s-rslc like vcrslc.rslc.

{global.i}

find first vcrslc where vcrslc.contract = s-contract no-lock no-error.
if avail vcrslc then do:
  {jabro.i 
  &head      =  "vcrslc"
  &headkey   =  "rslc"
  &formname  =  "h-rslc"
  &framename =  "h-rslc"
  &where     =  " (vcrslc.contract = s-contract) "
  &index     =  "main"
  &addcon    =  "false"
  &deletecon =  "false"
  &predisplay = " find codfr where codfr.codfr = 'vcdoc' and codfr.code = vcrslc.dntype 
                        no-lock no-error. "
  &display   =  " vcrslc.dnnum codfr.name[2] vcrslc.dndate vcrslc.lastdate "
  &highlight =  " vcrslc.dndate vcrslc.dnnum codfr.name[2] vcrslc.lastdate "
  &postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                    s-rslc = vcrslc.rslc.
                    leave upper.
                  end."
  &end =        " hide frame h-rslc."
  }
end.
else do: message " Документы не найдены.". pause. end.

