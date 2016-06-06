/* h-dolgs.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Поиск документов
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
        24/06/04 saltanat
 * CHANGES
        27.12.2010 aigul -  изменила вывод дат
*/

{vc.i}

def shared var s-contract like vccontrs.contract.
def shared var s-dolgs like vcdolgs.dolgs.

{global.i}

find first vcdolgs where vcdolgs.contract = s-contract no-lock no-error.

if avail vcdolgs then do:
 {jabro.i
  &head      =  "vcdolgs"
  &headkey   =  "dolgs"
  &formname  =  "h-dolgs"
  &framename =  "h-dolgs"
  &where     =  " (vcdolgs.contract = s-contract) "
  &index     =  "main"
  &addcon    =  "false"
  &deletecon =  "false"
  &predisplay = " find codfr where codfr.codfr = 'vcdoc' and codfr.code = vcdolgs.dntype
                        no-lock no-error. "
  &display   =  " /*vcdolgs.dnvn*/ vcdolgs.dndate vcdolgs.pdt codfr.name[2] vcdolgs.dnnum vcdolgs.sum"
  &highlight =  " /*vcdolgs.dnvn*/ vcdolgs.dndate vcdolgs.pdt codfr.name[2] vcdolgs.dnnum vcdolgs.sum"
  &postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                    s-dolgs = vcdolgs.dolgs.
                    leave upper.
                  end."
  &end =        " hide frame h-dolgs."
  }
end.
else do: message " Документы данного типа не найдены.". pause. end.


