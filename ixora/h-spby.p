/* h-spby.p
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

/* h-spby.p
   Хелп на поле arp.spby - список arp-карточек на счете 600510 (аккредитивы)

   11.03.2003 nadejda
*/

{global.i}
{name2sort.i}

def var v-akkred as char init "600510".
def var i as integer.
def var v-gl like gl.gl.

def temp-table t-arp 
  field sort as char
  field arp like arp.arp
  field des like arp.des
  field gl like gl.gl
  index arp is primary unique sort arp.

find sysc where sysc.sysc = "glakkr" no-lock no-error.
if avail sysc then v-akkred = sysc.chval.

do i = 1 to num-entries(v-akkred):
  v-gl = integer(entry(i, v-akkred)).
  for each arp where arp.gl = v-gl no-lock:
    create t-arp.
    assign t-arp.arp = arp.arp
           t-arp.des = arp.des
           t-arp.gl = arp.gl.
    t-arp.sort = name2sort(arp.des).
  end.
end.



{itemlist.i 
       &updvar = " "
       &file = "t-arp"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = " true "
       &predisp = " "
       &flddisp = "t-arp.arp format 'x(10)' label 'КАРТОЧКА'
                   t-arp.des format 'x(40)' label 'НАИМЕНОВАНИЕ ARP-КАРТОЧКИ'
                   t-arp.gl format '999999' column-label 'СЧЕТ ГК' "
       &chkey = "arp"
       &chtype = "string"
       &index  = "arp"
       &findadd = " "
       &funadd = " " }
