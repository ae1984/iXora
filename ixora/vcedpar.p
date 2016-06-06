/* vcedpar.p
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

/* vcedpar.p Валютный контроль 
   Редактирование справочника настроек

   18.10.2002 nadejda создан
*/

{vc.i}

{mainhead.i VCEDPARS}

{comm-txb.i}
def new shared var s-vcourbank as char.
s-vcourbank = comm-txb().


define variable s_rowid as rowid.
def var v-title as char init "ПАРАМЕТРЫ МОДУЛЯ ""ВАЛЮТНЫЙ КОНТРОЛЬ""".

form vcparams.valchar
   with frame vcchar overlay side-label row 18 width 78 centered top-only.

{jabrw.i
&start     = "displ v-title format 'x(50)' at 14 with row 4 no-box no-label frame vcheader."
&head      = "vcparams"
&headkey   = "parcode"
&index     = "parcode"

&formname  = "vcedpar"
&framename = "vced"
&where     = " "

&addcon    = "true"
&deletecon = "true"
&postcreate = " "
&postupdate   = " update vcparams.vallogi vcparams.valinte vcparams.valdeci with frame vced.
                  update vcparams.valchar with frame vcchar. "
            
       
&prechoose = "displ 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать' 
  with centered row 22 no-box frame vcfooter."

&postdisplay = " "

&display   = " vcparams.parcode vcparams.name vcparams.partype vcparams.vallogi
     vcparams.valinte vcparams.valdeci "
&update    = " vcparams.parcode vcparams.name vcparams.partype "
&highlight = " vcparams.parcode "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(vcparams).
                         output to vcdata.img .
                         for each vcparams no-lock:
                             display vcparams.parcode vcparams.name vcparams.partype
                               vcparams.valdeci vcparams.valinte vcparams.valchar vcparams.vallogi.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('vcdata.img').
                         find vcparams where rowid(vcparams) = s_rowid no-lock.
                      end. "

&end = "hide all no-pause."
}
hide message.



