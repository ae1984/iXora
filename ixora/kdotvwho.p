/* kdotvwho.p
 * MODULE
        
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
        18.03.04 marinav
 * CHANGES
        30/04/2004 madiar - временно отключил просмотр отв.лиц по досье филиалов в ГБ - нужно подключение к bank филиала.
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
    05/09/06   marinav - добавление индексов
*/


{global.i}
{kd.i}
{pksysc.f}

def var kdaffilcod as char.

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if kdlon.bank <> s-ourbank then return.    /* ofc -> bank */

if kdlon.bank = s-ourbank then kdaffilcod = '37'.
else kdaffilcod = '47'.

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod no-lock no-error.
if not avail kdaffil then do:
       find first ofc where ofc.ofc = kdlon.who no-lock no-error. 
       create kdaffil.
       assign kdaffil.code = kdaffilcod
              kdaffil.bank = s-ourbank
              kdaffil.kdcif = s-kdcif 
              kdaffil.kdlon = s-kdlon.
       if avail ofc then kdaffil.name = ofc.name.
                    else kdaffil.name = kdlon.who.
       find current kdaffil no-lock no-error.
end.

define var vans as logical.

{jabr.i 
&start     = " "
&head      = "kdaffil"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "pksysc"
&framename = "kdaffil37"
&where     = " kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod "

&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = " kdaffil.bank = s-ourbank. kdaffil.code = kdaffilcod. kdaffil.kdcif = s-kdcif. kdaffil.kdlon = s-kdlon. kdaffil.who = g-ofc. kdaffil.whn = g-today.
               update kdaffil.name with frame kdaffil37 . "
                 
&prechoose = "message 'F4-Выход,   INS-Отметка,   Ctrl+D - Удалить. '."
&postdisplay = " "
&display   = " kdaffil.res kdaffil.name" 
&highlight = " kdaffil.res kdaffil.name "

&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                              update kdaffil.name with frame kdaffil37.
                      end. 
              else if keyfunction(lastkey) = 'insert-mode' then do:
                    if kdaffil.res = '' then kdaffil.res = '*' .
                                        else kdaffil.res = '' .
                    leave outer.
              end. "

&end = "hide frame kdaffil37. "
}

