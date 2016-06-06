/* bn-check-rmz.p
 * MODULE
        Операции
 * DESCRIPTION
        Проверка реквизитов бенефициара по rmz
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
        06/11/2012 id00810
 * BASES
        BANK COMM TXB
 * CHANGES
        01/10/2013 Luiza перекомпиляция
        12.11.2013 Luibov - ТЗ 2204, убрала проверку перехода на ИИН/БИН
*/

def input  param p-fname as char no-undo.
def output param p-spnom as char no-undo.
def output param p-txt   as char no-undo.

def var v-str as char no-undo.
def var v-21  as char no-undo.
def var v-fm  as char no-undo.
def var v-nm  as char no-undo.
def var v-ft  as char no-undo.
def var v-rnn as char no-undo.
def var v-la  as char no-undo.
def var v-err as logi no-undo.
def stream r-in.

input stream r-in from value(p-fname). /*читаем содержимое файла*/
repeat:
    import stream r-in unformatted v-str.
    v-str = trim(v-str).
    if v-str begins ':21:' then do:
        assign v-21  = trim(substr(v-str,5))
               v-fm  = ''
               v-nm  = ''
               v-ft  = ''
               v-rnn = ''
               v-la  = ''
               v-err = no.
        next.
    end.
    else if v-str begins '/FM/'  then do: v-fm  = trim(substr(v-str,5)). next. end.
    else if v-str begins '/NM/'  then do: v-nm  = trim(substr(v-str,5)). next. end.
    else if v-str begins '/FT/'  then do: v-ft  = trim(substr(v-str,5)). next. end.
    else if v-str begins '/RNN/' then do: v-rnn = trim(substr(v-str,6)). next. end.
    else if v-str begins '/IDN/' then do: v-rnn = trim(substr(v-str,6)). next. end.
    else if v-str begins '/LA/'  then do:
        v-la = trim(substr(v-str,5)).
        find first txb.aaa where txb.aaa.aaa = v-la and txb.aaa.sta <> 'C' no-lock no-error.
        if not avail txb.aaa then do:
            p-spnom = p-spnom + v-21 + ','.
            p-txt = p-txt + '\n' + v-21 + '-' + '/LA/' + v-la + ' нет такого счета.'.
            next.
        end.
        find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
        if not avail txb.cif then do:
            p-spnom = p-spnom + v-21 + ','.
            p-txt = p-txt + '\n' + v-21 + '-' + '/LA/' + v-la + ' нет клиента с таким счетом.'.
            next.
        end.
        if v-fm ne entry(1,txb.cif.name,' ') then do:
            p-spnom = p-spnom + v-21 + ','.
            p-txt = p-txt + '\n' + v-21 + '-' + '/FM/' + v-fm + ' <> ' +  entry(1,txb.cif.name,' ') + '.'.
            v-err = yes.
        end.
        if v-nm ne entry(2,txb.cif.name,' ') then do:
            if not v-err then p-spnom = p-spnom + v-21 + ','.
            p-txt = p-txt + '\n' + v-21 + '-' + '/NM/' + v-nm + ' <> ' +  entry(2,txb.cif.name,' ') + '.'.
            v-err = yes.
        end.
        if num-entries(trim(txb.cif.name),' ') = 3 then if v-ft ne entry(3,trim(txb.cif.name),' ') then do:
            if not v-err then p-spnom = p-spnom + v-21 + ','.
            p-txt = p-txt + '\n' + v-21 + '-' + '/FT/' + v-ft + ' <> ' +  entry(3,trim(txb.cif.name),' ') + '.'.
            v-err = yes.
        end.
        if v-rnn ne '' then do:
            if v-rnn ne txb.cif.bin then do:
                if not v-err then p-spnom = p-spnom + v-21 + ','.
                p-txt = p-txt + '\n' + v-21 + '-' + '/IDN/' + v-rnn + ' <> ' + txb.cif.bin + '.'.
            end.
        end.
    end.
end.
input stream r-in close.
