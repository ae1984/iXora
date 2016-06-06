/* pkmygrf.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Автоматическое переформирование графика погашения кредита
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
        16/09/2008 galina
 * CHANGES
        23/09/2008 galina - вызываем "эрку" pkmagrf..

*/


{global.i}

def shared var s-lon like lon.lon.

def new shared var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then return.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = s-lon no-lock no-error.
if not avail pkanketa then return.

def new shared var s-credtype as char.
def new shared var s-pkankln as integer.
s-credtype = pkanketa.credtype.
s-pkankln = pkanketa.ln.

define new shared var s-dogsign as char.
define new shared var s-tempfolder as char.


{pk-sysc.i}


def var v-ans as logical no-undo.
def var v-sts as logical no-undo init true.
def var i as integer no-undo.

if s-pkankln = 0 then return.

procedure fmsg-w.
    def input parameter p-bank as char no-undo.
    def input parameter p-credtype as char no-undo.
    def input parameter p-ln as integer no-undo.
    def input parameter p-msg as char no-undo.
    find first pkanketh where pkanketh.bank = p-bank and pkanketh.credtype = p-credtype and pkanketh.ln = p-ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
    pkanketh.value1 = p-msg.
    find current pkanketh no-lock.
end procedure.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
s-lon = pkanketa.lon.

def var v-inet as logi init no.
if pkanketa.id_org = "inet" then v-inet = yes.

def new shared temp-table wrk no-undo
    field nn     as integer
    field stdat  like lnsch.stdat
    field od     like lnsch.stval
    field proc   like lnsch.stval
    index idx is primary stdat.

find lon where lon.lon = pkanketa.lon no-lock.
if v-sts then do:
    run VALUE("pkmygrf" + string(lon.plan,"9")).
    
    find first lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock no-error.
    if not available lnsch then do:
        if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pklongrf - Произошла ошибка при формировании графика!").
        else message " Произошла ошибка при формировании графика! " view-as alert-box buttons ok.
        return.
    end.
end.
