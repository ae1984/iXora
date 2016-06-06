/* h-remtrzR.p
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

/* h-remtrzR.p */
{global.i}

def var h as int .
h = 12 .

def shared var s-remtrz like que.remtrz .

def new shared var v-amt like remtrz.amt .
def new shared var v-cif like cif.cif .
def new shared var v-date as  date .
def new shared var v-ref like remtrz.ref.
def new shared var ourbank like remtrz.sbank.
def new shared var v-sqn like remtrz.sqn  .
def var v-cur as int .
def var v-rrr as cha  format "x(10)" column-label "REF"   .



find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBANK в таблице SYSC!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

       {browpnp.i
        &h = "h"
        &where = " true "
        &frame-phrase = "row 1 centered scroll 1 h down
        title 'Поиск: [Д]ата,[С]умма,[К]лиент,[Н]омер,' +
        'повторить [П]оследний поиск по сумме' overlay "
        &predisp = "find que where que.remtrz = remtrz.remtrz
         no-lock no-error .
                    v-rrr = substr(remtrz.sqn,19) .
          display remtrz.source column-label ""Источник""
            remtrz.ptype column-label ""Тип""
            remtrz.rdt column-label ""Рег.дата""
            remtrz.valdt1 column-label ""1Дата""
            remtrz.valdt2 column-label ""2Дата""
            remtrz.sbank column-label ""БанкО""
            remtrz.rbank column-label ""БанкП""
            with row 17 centered . pause 0 .
          if avail que then 
           display que.pid column-label ""Код""
             que.con column-label ""Сост.""
             with row 17 centered .
          pause 0 . "
        &seldisp = "remtrz.remtrz"
        &file = "remtrz"
        &disp = "remtrz.remtrz column-label ""Платеж""
         v-rrr column-label ""Nr."" 
         remtrz.fcrc column-label ""Вал.Д""
         remtrz.amt column-label ""СуммаД""
         remtrz.tcrc column-label ""Вал.К""
         remtrz.payment column-label ""СуммаК"" "
        &addupd = " remtrz.remtrz "
        &upd    = " "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " s-remtrz = remtrz.remtrz . 
         frame-value = remtrz.remtrz . hide all . "
        &action = "
        v-cur = recid(remtrz) .
        run pshact(input-output v-cur) .
        if v-cur ne 0 then do:
         find first que where recid(que) = v-cur no-lock .
         find first remtrz where remtrz.remtrz = que.remtrz no-lock .
         cur = recid(remtrz) .
         leave .
        end .
        "
       }
