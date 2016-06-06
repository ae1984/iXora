/* okpo_txb.p
 * MODULE
        vcmsg101_a.p
 * DESCRIPTION
        Процедура для вывода РНН и ОКПО
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        vcmsg101_a.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        12/10/2010 aigul
 * BASES
        TXB
 * CHANGES
        07.04.2011 damir - новые переменные p-bincif p-iincif
        28.04.2011 damir - поставлены ключи.


*/

def var v-bin as logi init no.

find first txb.sysc where txb.sysc.sysc = 'bin' no-lock no-error.
if avail txb.sysc then v-bin = txb.sysc.loval. /*переход на БИН и ИИН*/

if v-bin = no then do:
    define input  parameter p-cif like txb.cif.cif.
    define input  parameter p-type as char.
    def output parameter p-okpo as char.
    def output parameter p-rnn as char.

    for each txb.cif where txb.cif.cif = p-cif no-lock:
        if p-type = "1" then p-okpo = txb.cif.ssn.
        if p-type = "2" then p-rnn = txb.cif.jss.
    end.
end.
if v-bin = yes then do:
    define input  parameter p-cif1 like txb.cif.cif.
    define input  parameter p-type1 as char.
    def output parameter p-okpo1 as char.
    def output parameter p-rnn1 as char.
    def output parameter p-bincif1 as char.
    def output parameter p-iincif1 as char. /*Дамир*/

    for each txb.cif where txb.cif.cif = p-cif no-lock:
        if p-type1 = "1" then do:
            p-okpo1 = txb.cif.ssn.
            p-bincif1 = txb.cif.bin. /*Дамир*/
        end.
        if p-type1 = "2" then do:
            p-rnn1 = txb.cif.jss.
            p-iincif1 = txb.cif.bin. /*Дамир*/
        end.
    end.
end.
