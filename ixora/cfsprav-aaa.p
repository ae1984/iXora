/* cfsprav-aaa.p
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

/* cfsprav-aaa.p
   Список счетов клиента для печати справки

   26.03.2003 nadejda
*/

{global.i}

def shared temp-table t-accs
  field aaa as char
  field choice as char
  field name as char
  field dam as deci
  field damdig as char
  field damstr as char
  field cam as deci
  field camdig as char
  field camstr as char
  field gl as integer
  field crc as integer
  field crccode as char
  index aaa is primary unique aaa.

def var vans as logical.

{jabr.i 

  &start     =  " "
  &head      =  "t-accs"
  &headkey   =  "aaa"
  &index     =  "aaa"
  &formname  =  "cfsprav-aaa"
  &framename =  "f-aaa"
  &where     =  " true "
  &addcon    =  "false"
  &deletecon =  "false"
  &prechoose =  " "
  &predisplay = " "
  &display   =  " t-accs.choice t-accs.aaa t-accs.name t-accs.crccode "
  &highlight =  " t-accs.choice t-accs.aaa t-accs.name t-accs.crccode "
  &postkey   =  " else if keyfunction(lastkey) = 'insert-mode' then do:
                    if t-accs.choice = '' then t-accs.choice = '*'.
                                          else t-accs.choice = ''.
                    leave outer.
                  end.
                  else if keyfunction(lastkey) = 'return' then do:
                      t-accs.choice = '*'.
                      leave upper.
                  end. "
  &end =        " hide frame f-aaa. "
}
