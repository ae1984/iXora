/* arpt.p
 * MODULE
        Настройка ARP  и тарифов
 * DESCRIPTION
        Настройка ARP  и тарифов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        2-7-6
 * AUTHOR
        19/09/05 nataly
 * CHANGES
        20/09/2013 Luiza    - ТЗ 1916 изменение поиска записи в таблице tarif2
*/

{mainhead.i SSGEN}


define variable s_rowid as rowid.
def var vans as logical.
def stream rpt.

define variable s-mask as character format "x(20)" initial "*".

define variable s-entries as character initial "".
define variable srch as character format "x(40)" label "Строка поиска" initial "".
define variable srch2 as character.

/*{headln-w.i */
{jabr.i
&start     = "  ON HELP of arptarif.kod  in FRAME cods DO:
              run help-tarif.
              arptarif.kod:screen-value = frame-value.
              arptarif.kod = arptarif.kod:screen-value.
            end.
            "
&head      = "arptarif"
&headkey   = "arp"
&index     = "arp_idx"
&formname  = "arpt"
&framename = "cods"
&where     = " arptarif.arp = arptarif.arp "
&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = "
            update
            arptarif.arp  validate(can-find( arp no-lock where arp.arp = arptarif.arp  ), 'Счет ARP не найден !')
            arptarif.kod  validate (can-find( tarif2 no-lock where tarif2.str5  = trim(arptarif.kod)  ) , 'Тариф не найден! ')
                with frame cods.  "
&prechoose = "message 'F4-Выход,Enter-Вставка,P-Печать,CTRL+D-удаление'."
&postdisplay = " "
&display   = " arptarif.arp arptarif.kod  "
&highlight = " arptarif.arp arptarif.kod  "
&postkey = " else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                              update arptarif.arp arptarif.kod with frame cods .
                      end.
      else if keyfunction(lastkey) = 'P' then
                            do:
/*                               s_rowid = rowid(cods).*/
                               output stream rpt to tarif.img .
                               put stream rpt unformatted 'Список счетов ARP с привязкой кодов тарифов.' skip  .
                               put stream rpt unformatted '     -----------------' skip  .
                               put stream rpt unformatted '     |ARP      |  КОД | ' skip.
                               put stream rpt unformatted '     -----------------' skip .
                               for each arptarif:
                                   put stream  rpt unformatted  space(5) '|' arptarif.arp format 'x(9)' '|  '  arptarif.kod  format 'x(3)' ' |'  skip.
                               end.
                               put stream rpt unformatted   '     -----------------' skip .
                               output stream rpt close.
                               output stream rpt to terminal.
                               run menu-prt('tarif.img').
                              /* find cods where rowid(cods) = s_rowid no-lock.*/
                       end.

              /* else if keyfunction(lastkey) = 'D' then
                      do:
                          s-mask = '*'. s-entries = ''.
                          find first cods where cods.code matches s-mask and (s-entries = '' or lookup(cods.code, s-entries) > 0)  use-index codegl_id no-lock no-error.
                         trec = recid(cods).
                         next upper.
                      end.
*/
                     "
&end = "hide frame cods. hide frame y."
}

hide message.
/*
procedure do_sysc_search.

     update srch with side-labels color messages overlay row 5 centered frame srchfr.
     hide frame srchfr.
     s-entries = ''.

     if srch <> '' then do: /* создадим строку с найденными sysc */
        srch = '*' + trim (srch) + '*'.
        for each cods no-lock:
            srch2 = ''.
            srch2 = srch2 + string(cods.gl).
            if srch2 matches srch then s-entries = s-entries + cods.code + ','.
        end.
     end.
     if s-entries = '' then message 'Не найдены записи в cods по строке ' skip srch skip
                'Возврат к default по маске~n' s-mask view-as alert-box title ''.
     else
     if s-mask <> '*' then message 'Внимание!~nНайденные записи в cods показаны~nсогласно маске~n' +
                           s-mask view-as alert-box title "".

end procedure.
  */