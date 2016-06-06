/* vc101cif.p
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

/* vcmsg101chps.p Валютный контроль
   Выбор одного паспорта сделки из нескольких похожих при загрузке МТ101

   27.12.2002 nadejda
*/

{global.i}

def output parameter vpc like cif.cif.

def shared temp-table t-chcif
  field bank like txb.bank
  field cif like cif.cif
  field cifname as char
  field sort as char
  field rnn as char
  field okpo as char
  field valcon as logical
  index main is primary sort cif.

{jabro.i 
&head      =  "t-chcif"
&headkey   =  "cif"
&formname  =  "vc101cif"
&framename =  "f-chcif"
&where     =  " true "
&index     =  "main"
&addcon    =  "false"
&deletecon =  "false"
&predisplay = " "
&display   =  " t-chcif.bank t-chcif.cif t-chcif.cifname t-chcif.rnn t-chcif.okpo t-chcif.valcon "
&highlight =  " t-chcif.bank t-chcif.cif t-chcif.cifname t-chcif.rnn t-chcif.okpo t-chcif.valcon "
&postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                  vpc = t-chcif.cif.
                  leave upper.
                end."
&end =        " hide frame f-chcif."
}

