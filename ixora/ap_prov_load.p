/* ap_prov_load.p
 * MODULE
        Платежи - Авнгард-Плат
 * DESCRIPTION
        Программа для загрузки провайдеров
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        13/10/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        10.04.2013 damir - Внедрено Т.З. № 1577,1571.
*/

{mainhead.i}

function getErrorDes returns char (input err_code as integer).
    def var res as char no-undo.
    find first aperrlist where aperrlist.errcode = err_code no-lock no-error.
    if avail aperrlist then res = aperrlist.errdes. else res = string(err_code) + ": неизвестная ошибка".
    return res.
end function.

function getDateTime returns char.
    def var res as char no-undo.
    res = string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + replace(string(time,"hh:mm:ss"),':','').
    return res.
end function.

def temp-table t-fils no-undo
    field fcode as char
    field fname as char
    index idx is primary fcode.

create t-fils.
assign t-fils.fcode = "<все>"
       t-fils.fname = "Все".

for each txb where txb.consolid no-lock:
    create t-fils.
    assign t-fils.fcode = txb.bank
           t-fils.fname = txb.info.
end.

def temp-table wrk like suppcom.

define query qreg for suppcom.
define query qnew for wrk.
def buffer b-suppcom for suppcom.

define browse breg query qreg
       displ suppcom.supp_id format ">>>9" label "id"
             suppcom.txb format "x(5)" label "txb"
             suppcom.name format "x(29)" label "Провайдер"
             suppcom.ap_code format ">>>9" label "ap_id"
       with 29 down overlay no-label title " Зарегистрированные провайдеры ".

define browse bnew query qnew
       displ wrk.name format "x(30)" label "Провайдер"
             wrk.ap_code format ">>>9" label "ap_id"
             wrk.ap_type format ">>>9" label "ap_type"
             wrk.ap_check format ">>>9" label "ap_chk"
             with 29 down overlay no-label title " Провайдеры Авангард-Плат ".

def var v-errcode as integer no-undo.
def var v-errdes as char no-undo.

def var v-rid as rowid no-undo.
def var v-bank as char no-undo.
def var v-request as char no-undo.
def var v-reply as char no-undo.
def var i as integer no-undo.
def var choice as logi no-undo.

define frame ft breg help "F1 - Помощь" bnew help "F1 - Помощь" skip(1) with width 110 row 3 overlay no-label no-box.

define frame fregprov
    v-bank format "x(5)"           label "txb               " validate (can-find(t-fils where t-fils.fcode = v-bank no-lock),"Некорректный код банка!") skip
    wrk.name FORMAT "x(50)"        label "Провайдер         " skip
    wrk.bname FORMAT "x(50)"       label "Банк провайдера   " skip
    wrk.iik FORMAT "x(21)"         label "ИИК провайдера    " skip
    wrk.bik FORMAT "x(21)"         label "БИК провайдера    " skip
    wrk.rnn FORMAT "x(12)"         label "РНН провайдера    " skip
    wrk.nds-cer FORMAT "x(6)"      label "НДС серия         " skip
    wrk.nds-no FORMAT "x(12)"      label "НДС номер         " skip
    wrk.nds-date FORMAT "99/99/99" label "НДС дата          " skip
    wrk.knp FORMAT "x(3)"          label "КНП               " skip
    wrk.paycod FORMAT "x(3)"       label "Код комисс ф/л    " skip
    wrk.supcod FORMAT ">>9.99"     label "Комиссия пров.    " skip
    wrk.arp FORMAT "x(21)"         label "АРП для пров.     " skip
    wrk.type FORMAT "->>>>>>9"     label "Тип провайдера    " skip
    wrk.ap_code FORMAT "->>>>>>9"  label "Код пров. в АПлат " skip
    wrk.ap_type FORMAT "->>>>>>9"  label "Тип пров. в АПлат " skip
    wrk.ap_tc FORMAT "x(12)"       label "Тел. кода пров.   " skip
    wrk.minsum FORMAT "->>,>>9.99" label "Мин.сумма платежа " skip
    wrk.minlen FORMAT "->>>>>>9"   label "Мин.длина номера  " skip
    wrk.maxlen FORMAT "->>>>>>9"   label "Макс.длина номера " skip
    wrk.ap_check FORMAT "->>>>>>9" label "Онлайн проверка   " skip
    with centered title " Регистрация провайдера в iXora " width 80 row 5 overlay side-labels.

on help of v-bank in frame fregprov do:
    {itemlist.i
       &file = "t-fils"
       &frame = "row 6 centered scroll 1 20 down overlay "
       &where = " true "
       &flddisp = " t-fils.fcode label 'Код' format 'x(5)'
                    t-fils.fname label 'Филиал' format 'x(50)'
                  "
       &chkey = "fcode"
       &chtype = "string"
       &index  = "idx"
    }
    v-bank= t-fils.fcode.
    displ v-bank with frame fregprov.
end.

function GetArp returns char (input parm1 as char).
   def buffer b-filarp for suppcom.
    find first b-filarp where b-filarp.txb = parm1 and b-filarp.type <> 0  no-lock no-error.
    if avail b-filarp then return b-filarp.arp.
    else return "".
end function.

procedure parse_reply:
    def input parameter p-str as char no-undo.
    def var v-str as char no-undo.
    v-str = substring(p-str,10,length(p-str) - 9). /* убираем начальный тэг <SRV_SH2> */
    def var v-entry as char no-undo.
    do i = 1 to num-entries(v-str,';'):
        v-entry = entry(i,v-str,';').
        if num-entries(v-entry,'`') = 12 then do:
            create wrk.
            assign wrk.ap_code = integer(entry(1,v-entry,'`'))
                   wrk.name = entry(2,v-entry,'`')
                   wrk.minsum = deci(entry(3,v-entry,'`'))
                   wrk.minlen = integer(entry(4,v-entry,'`'))
                   wrk.maxlen = integer(entry(5,v-entry,'`'))
                   wrk.ap_tc = entry(6,v-entry,'`')
                   wrk.ap_type = integer(entry(7,v-entry,'`'))
                   wrk.ap_check = integer(entry(12,v-entry,'`')).
        end.
    end.
end procedure.

on "go" of breg in frame ft or "go" of bnew in frame ft do:
    message "  Зарегистрированные провайдеры         Провайдеры Авангард-Плат            ~n~n" +
            "[Space]  - обновить                 [Ctrl+R] - Послать запрос               ~n" +
            "                                    [Insert] - Зарегистрировать провайдера  ~n" +
            "                                    [Enter]  - Подробная информация         ~n~n"
    view-as alert-box information title "Помощь".
end. /* on "return" of b1 */

on " " of breg in frame ft do:
    breg:set-repositioned-row(breg:focused-row, "always").
    v-rid = rowid(suppcom).
    open query qreg for each suppcom no-lock.
    reposition qreg to rowid v-rid no-error.
    if avail suppcom then breg:refresh().
end. /* on " " of breg */

on "RECALL" of bnew in frame ft do:
    choice = no.
    message "Отправить запрос?" view-as alert-box question buttons ok-cancel title "" update choice.
    if choice then do:
        empty temp-table wrk.
        /* build request string */
        v-request = '<SRV_SH2>'.
        v-reply = ''.
        v-errcode = 0.

        /* send request */
        run savelog('ap','ap_prov_load->' + v-request).
        run ap_send("tcp",no,v-request,output v-reply).
        run savelog('ap','ap_prov_load<-' + v-reply).

        /* process reply */
        v-reply = trim(v-reply).

        v-errcode = 0.
        if v-reply matches "mcberr*" then do:
            v-errcode = integer(entry(2,v-reply,'=')) no-error. /* код ошибки возвращается ESB-сервисом */
            v-errdes = getErrorDes(v-errcode).
        end.

        if v-reply = v-request then do:
            v-errcode = 9010. /* Сервис недоступен */
            v-errdes = getErrorDes(v-errcode).
        end.

        if v-reply = '?' then do:
            v-errcode = 9011. /* Ошибка обработки ответа на запрос */
            v-errdes = '(?) ' + getErrorDes(v-errcode).
        end.

        if trim(v-reply) = "" then do:
            v-errcode = 9005. /* Сервис вернул пустую строку */
            v-errdes = getErrorDes(v-errcode).
        end.

        if (not (v-reply matches "<SRV_SH2>*")) or (length(v-reply) < 10) then do:
            v-errcode = 9011. /* Ошибка обработки ответа на запрос */
            v-errdes = getErrorDes(v-errcode).
        end.

        if v-errcode = 0 then do:
            run parse_reply(v-reply).
            open query qnew for each wrk.
            if avail wrk then breg:refresh().
        end.
        else message v-errcode ":" v-errdes view-as alert-box error.
    end.
end. /* on "RECALL" of bnew */

on "RETURN" of bnew in frame ft do:
    if avail wrk then do:
        v-bank = ''.
        displ v-bank
              wrk.name wrk.bname wrk.iik wrk.bik wrk.rnn
              wrk.nds-cer wrk.nds-no wrk.nds-date
              wrk.knp wrk.paycod wrk.supcod
              wrk.arp wrk.type
              wrk.ap_code wrk.ap_type wrk.ap_tc
              wrk.minsum wrk.minlen wrk.maxlen
              wrk.ap_check
              with frame fregprov.
        update v-bank
               wrk.name wrk.bname wrk.iik wrk.bik wrk.rnn
               wrk.nds-cer wrk.nds-no wrk.nds-date
               wrk.knp wrk.paycod wrk.supcod
               wrk.arp wrk.type
               wrk.ap_code wrk.ap_type wrk.ap_tc
               wrk.minsum wrk.minlen wrk.maxlen
               wrk.ap_check
               with frame fregprov.
        hide frame fregprov.
    end.
end.

on "INSERT" of bnew in frame ft do:
    if avail wrk then do:
        v-bank = ''.
        displ v-bank
              wrk.name wrk.bname wrk.iik wrk.bik wrk.rnn
              wrk.nds-cer wrk.nds-no wrk.nds-date
              wrk.knp wrk.paycod wrk.supcod
              wrk.arp wrk.type
              wrk.ap_code wrk.ap_type wrk.ap_tc
              wrk.minsum wrk.minlen wrk.maxlen
              wrk.ap_check
              with frame fregprov.
        update v-bank
               wrk.name wrk.bname wrk.iik wrk.bik wrk.rnn
               wrk.nds-cer wrk.nds-no wrk.nds-date
               wrk.knp wrk.paycod wrk.supcod
               wrk.arp wrk.type
               wrk.ap_code wrk.ap_type wrk.ap_tc
               wrk.minsum wrk.minlen wrk.maxlen
               wrk.ap_check
               with frame fregprov.

        choice = no.
        if v-bank = "<все>" then message "Зарегистрировать провайдера на всех филиалах?" view-as alert-box question buttons ok-cancel title "" update choice.
        else message "Зарегистрировать провайдера в указанном филиале?" view-as alert-box question buttons ok-cancel title "" update choice.
        if choice then do:
            hide frame fregprov.
            if v-bank = "<все>" then do:
                for each txb where txb.consolid no-lock:
                    create b-suppcom.
                    b-suppcom.supp_id = next-value(suppid).
                    b-suppcom.txb = txb.bank.
                    b-suppcom.arp = GetArp(txb.bank).
                    buffer-copy wrk except wrk.txb wrk.supp_id wrk.arp to b-suppcom.
                end.
            end.
            else do:
                create b-suppcom.
                b-suppcom.supp_id = next-value(suppid).
                b-suppcom.txb = v-bank.
                buffer-copy wrk except wrk.txb wrk.supp_id to b-suppcom.
            end.
        end.
    end.
end.

open query qreg for each suppcom no-lock.
open query qnew for each wrk.
enable breg bnew with frame ft.

wait-for window-close of current-window.
pause 0.


