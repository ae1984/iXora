/* pcfupl.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        выбор уполномоченного лица клиента
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
        19/07/2012 id00810
 * BASES
 		BANK COMM TXB
 * CHANGES
*/

def input  param p-cif   as char no-undo.
def input  param p-aaa   as char no-undo.
def output param p-lname as char no-undo.
def output param p-doc   as char no-undo.
def output param p-rnn   as char no-undo.
def        var   v-id    as int  no-undo.

find first txb.cif where txb.cif.cif = p-cif no-lock no-error.
if avail txb.cif then do:
    {itemlist.i
    &file = "txb.uplcif"
    &frame = "row 6 centered scroll 1 12 down width 90 overlay "
    &where = " txb.uplcif.cif = txb.cif.cif and txb.uplcif.dop = p-aaa and txb.uplcif.finday > today "
    &findadd = "v-id = v-id + 1."
    &flddisp = " v-id               label 'N'               format 'zz9'
                 txb.uplcif.badd[1] label 'Ф.И.О.'          format 'x(20)'
                 txb.uplcif.rnn     label 'РНН'             format 'x(12)'
                 txb.uplcif.badd[2] label 'Паспорт.данные'  format 'x(20)'
                 txb.uplcif.badd[3] label 'Кем/Когда выдан' format 'x(20)'
                 txb.uplcif.finday  label 'Дата окон.дов.'
               "
    &chkey = "badd[1]"
    &chtype = "string"
    &index  = "uplcif"
    &end = "if keyfunction(lastkey) eq 'end-error' then return."
   }
   assign p-lname = txb.uplcif.badd[1]
          p-doc   = txb.uplcif.badd[2] + " " + txb.uplcif.badd[3]
          p-rnn   = txb.uplcif.rnn.
end.
