/* vcedfs.p
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

/* vcedfs.p Валютный контроль 
   Редактирование справочника форм собственности

   18.10.2002 nadejda создан
*/

{global.i}

def input parameter v-title as char.
def input parameter v-codif as char.

def var massname as char init '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,А,Б,В,Г,Д,Е,Ж,З,И,Й,К,Л,М,Н,О,П,Р,С,Т,У,Ф,Х,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,'.
def var massnode as char init '01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,'. 
def var s_rowid as rowid.
def var i as integer.
def var n as integer.
def var s as char.
def var c as char.


{jabrw.i
&start     = "displ v-title format 'x(50)' at 15 with row 4 no-box no-label frame vcheader."
&head      = "codfr"
&headkey   = "code"
&index     = "main"

&formname  = "vced"
&framename = "vced"
&where     = " codfr.codfr = v-codif and codfr.code <> 'msc' "

&addcon    = "true"
&deletecon = "true"
&postcreate = "codfr.codfr = v-codif. codfr.level = 1. tree-node = v-codif + '99999999'. "
       
&prechoose = "displ 'F4- выход,  INS- вставка,  F10- удалить,  P- печать,  S- сортировка' 
  with centered row 22 no-box frame vcfooter."

&postdisplay = " "

&display   = " codfr.code codfr.name[1] "

&highlight = " codfr.code  "

&update   = " codfr.code codfr.name[1] "

&postupdate = " s = ''. 
                do i = 1 to length(codfr.code):
                  c = caps(substring(codfr.code, i, 1)). n = lookup(c, massname).
                  if n = 0 then s = s + c. else s = s + entry(n, massnode). end.
                codfr.tree-node  = 'ownform' + s. "

&postkey   = "else if keyfunction(lastkey) = 'P' then do:
                         s_rowid = rowid(codfr).
                         output to vcdata.img .
                         for each codfr where codfr.codfr = v-codif no-lock:
                             display codfr.code codfr.name[1].
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('vcdata.img').
                         find codfr where rowid(codfr) = s_rowid no-lock.
                      end.
              else if keyfunction(lastkey) = 'S' then do:
                         for each codfr where codfr.codfr = v-codif use-index main :
                           s = ''. 
                           do i = 1 to length(codfr.code):
                             c = caps(substring(codfr.code, i, 1)). n = lookup(c, massname).
                             if n = 0 then s = s + c. else s = s + entry(n, massnode). end.
                           codfr.tree-node  = 'ownform' + s. 
                         end.
                         clin = 0.
                         next upper.
                      end. "

&end = "hide frame vced. hide frame vcheader. hide frame vcfooter."
}
hide message.


