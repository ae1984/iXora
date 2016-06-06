/* h-remtrz.p
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
        11.11.2004 saltanat - Закоментарила и вернула то,что было изменено 08.11.01 (см.ниже)
*/

/* h-remtrz.p */
/* корректировка от 08.11.01 
было:  показывались платежи только по исполнителям в п.п. 5-3-1, 5.3.2
стало: показываются все платежи в п.п. 5-3-1
18/03/2002 - для TXB00, 3G - выбор (платежи СПФ/TXB00 или остальные)
*/

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
def var v-rrr as cha  format "x(10)" column-label "REF"   .
def var v-all as cha . 
def var v-cur as int .

v-all = "" . 

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBANK в таблице SYSC!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

if m_pid =  "P" and u_pid ne "v-stat" then v-all = g-ofc.  

if m_pid = "O" and u_pid ne "v-stat" then do:
    find ofc where ofc.ofc = g-ofc no-lock no-error.
    if avail ofc and ofc.titcd = '103' then do:
       v-all = g-ofc.  
    end.
end.
if m_pid ne "R" then do:

/* for outgoing RKO SWIFT TXB00 QUE='3G' */
def var v-dep as integer.
def var v-3G as integer init 2. /* RKO */
{get-dep.i}
v-dep = get-dep(g-ofc, g-today).
if ourbank <> 'TXB00' then v-dep = 1. /* check TXB00 */
if v-dep <> 1 then v-3G = 1. /* check HeadTXB00Office */
if m_pid <> '3G' then v-3G = 1. /* check 3G que */
if v-3G = 2 then do: v-3G = 1. message "1) Остальные 2) СПФ " update v-3G. hide message. end.
if v-3G <> 1 and v-3G <> 2 then v-3G = 1.

       {browpnp.i
        &h = "h"
        &where = "m_pid = que.pid
          and que.con ne ""F"" and
          ( can-find(remtrz where remtrz.remtrz = que.remtrz and
            remtrz.rwho = g-ofc and (m_pid = 'P' or m_pid = 'O' or
            ((v-3G = 2 and remtrz.rbank = """" and not remtrz.source = 'IBH') or
            (v-3G = 1 and (remtrz.rbank <> """" or remtrz.source = 'IBH' )))))
            or
            (v-all eq """" and
            can-find(remtrz where remtrz.remtrz = que.remtrz and
            (m_pid = 'P' or m_pid = 'O' or ((v-3G = 2 and remtrz.rbank = """" and not remtrz.source = 'IBH') or
            (v-3G = 1 and (remtrz.rbank <> """" or remtrz.source = 'IBH' )))))))
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
            remtrz.source column-label ""Источник""
            remtrz.ptype column-label ""Тип""
            remtrz.rdt column-label ""Рег.дата""
            remtrz.valdt1 column-label ""1Дата""
            remtrz.valdt2 column-label ""2Дата""
            remtrz.sbank column-label ""БанкО""
            remtrz.rbank column-label ""БанкП""          
            with row 17 centered . pause 0 .
          if avail que then display 
            que.pid column-label ""Код""
            que.con column-label ""Сост.""          
            with row 17 centered . pause 0  . "
        &seldisp = "que.remtrz" &file = "que"
        &disp = "
         que.remtrz column-label ""Платеж""
         v-rrr column-label ""Nr."" 
         remtrz.fcrc column-label ""Вал.Д""
         remtrz.amt column-label ""СуммаД""
         remtrz.tcrc column-label ""Вал.К""
         remtrz.payment column-label ""СуммаК"" "
        &addupd = " que.remtrz " &upd    = "  " &addcon = "false"
        &updcon = "false" &delcon = "false" &retcon = "true"
        &befret = " s-remtrz = que.remtrz .
                    if u_pid ne ""v-stat"" then 
                    frame-value = que.remtrz . hide all . "
        &action = "
        v-cur = recid(remtrz) .
        run pshact(input-output v-cur) .
        if v-cur ne 0 then do:
         cur = v-cur .
         leave .
        end .
         " }

end.
else if m_pid = "R" then
   do:
    run h-remtrzR.
   end.
