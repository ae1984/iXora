/* z-remtrz.p
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

/* h-remtrz.p */
{global.i}
{lgps.i }
def var h as int .
h = 12 .

def shared var s-remtrz like que.remtrz .
def new shared var v-amt like remtrz.amt .
def new shared var v-cif like cif.cif .
def new shared var v-date as  date .
def new shared var v-ref like remtrz.ref.
def new shared var ourbank like remtrz.sbank.
def new shared var v-sqn like remtrz.sqn  .
def var v-rrr as cha  format "x(10)" column-label "Nr."   .
def var v-all as cha . 
def var v-cur as int .
def var ui as cha .
v-all = "" . 

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message "Отсутствует запись OURBNK в таблице SYSC!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.
if (m_pid = "O" or m_pid = "P" ) and u_pid ne "v-stat" then v-all = g-ofc.  
if m_pid = "I" then ui = "UI" . else ui = "" .
if m_pid ne "R" then do:

       {browpnp.i
        &h = "h"
        &where = "m_pid = que.pid 
          and que.con ne ""F"" and 
          ( can-find(remtrz where remtrz.remtrz = que.remtrz and 
           ( remtrz.rwho = g-ofc or v-all eq """" ) and remtrz.source ne
                       ui no-lock ))      
           use-index fprc "
        &frame-phrase = "row 1 centered scroll 1 h down
        title 'Поиск: [Д]ата,[С]умма,[К]лиент,[Н]омер,' +
        'повторить [П]оследний поиск по сумме' overlay "
        &predisp = "find remtrz where remtrz.remtrz = que.remtrz
          no-lock no-error . 
          if remtrz.source ne ""H"" then 
          v-rrr = substr(remtrz.sqn,19) .
          else v-rrr = remtrz.sqn.
          display 
            remtrz.source column-label 'Ист.'
            remtrz.ptype column-label 'Тип'
            remtrz.rdt column-label 'Рег.дата'
            remtrz.valdt1 column-label 'Вал.дата1' 
            remtrz.valdt2 column-label 'Вал.дата2' 
            remtrz.sbank column-label 'Отпр.банк'
            remtrz.rbank column-label 'Получ.банк'
            with row 17 centered . pause 0 .
          if avail que then display 
            que.pid column-label 'Код'
            que.con column-label 'Сост.'
            with row 17 centered . pause 0  . "
        &seldisp = "que.remtrz" &file = "que"
        &disp = "
         que.remtrz  label 'Платеж' 
         v-rrr label 'Nr.'
         remtrz.fcrc label 'Вал.Д'
         remtrz.amt label 'СуммаД'
         remtrz.tcrc label 'Вал.К'
         remtrz.payment label 'СуммаК' "
        &addupd = " que.remtrz " &upd    = "  " &addcon = "false"
        &updcon = "false" &delcon = "false" &retcon = "true"
        &befret = " s-remtrz = que.remtrz .
                    if u_pid ne ""v-stat"" then 
                    frame-value = que.remtrz . hide frame frm . "
        &action = "
        v-cur = recid(remtrz) .
        run pshact(input-output v-cur) .
        if v-cur ne 0 then do:
         cur = v-cur .
         leave .
        end .
         " }

end.
