/* s-lntrxd.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Удаление проводки по ссудному счету
 * RUN

 * CALLER
        s-lonnk.p
 * SCRIPT

 * INHERIT

 * MENU
        4-1-1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        12.09.2003 nadejda - добавила снятие специнструкции при удалении проводки-выдачи
        17.12.2003 nadejda - добавила pk0.i для перекомпиляции
        15.04.2004 nadejda - добавила transaction
        13/05/2004 madiyar  - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        12.01.2009 galina - добавила обработку нажатия кнопки "Cancel"
                            добавила закрытия фрейма ln1 при нажатии "F4"
        19/03/2009 madiyar - возможность удаления проводок банкадма у юзеров из справочника lntrxstor
        25/03/2009 madiyar - в справочник lntrxstor можно добавлять пакеты
*/

{global.i}
{lonlev.i}
{pk0.i}

def shared var s-lon like lon.lon.
def new shared var s-jh like jh.jh.

def var rcode as int.
def var rdes as char.
def var ja as log.
def var v-jdt as date.
def var v-our as log.
def var v-lon as log.
def var v-finish as log.
def var v-cash as log.
def var v-lonour as log.
def var vou-count as int.
def var v-cashgl like gl.gl.
def var i as int.
def var v-sts as int.
def var s-jhold like jh.jh.
def var v-fdt as date.
def var v-tdt as date.
def var v-dtmp as char.

def var v-isgrant as logical.
def var v-isanketa as logical.
def var v-grantacc as char.
def var v-grantsum as decimal.

DEFINE VARIABLE v-method AS char FORMAT "x(8)" label "Номер транзакции" VIEW-AS FILL-IN.
def button btn1 label "Ok".
def button btn2 label "Cancel".

def frame ln1 v-method skip
     btn1 at 10 btn2 at 50 with centered side-label scrollable.

function is_authorised returns logical (input user_id as char, input auth_list as char).
    def var v-perm as logi init no.
    def var i as integer.

    if lookup(user_id,auth_list) > 0 then v-perm = yes.
    else do:
        find first ofc where ofc.ofc = user_id no-lock no-error.
        if avail ofc then do:
            do i = 1 to num-entries(ofc.expr[1]):
                if lookup(entry(i,ofc.expr[1]),auth_list) > 0 then do: v-perm = yes. leave. end.
            end.
        end. /* if avail ofc */
    end.
    return v-perm.
end function.


find lon where lon.lon = s-lon no-lock no-error.
find loncon where loncon.lon = lon.lon no-lock no-error.
find sysc where sysc.sysc = "cashgl" no-lock no-error.
v-cashgl = sysc.inval.

def var lntrxstor_enabled as logi no-undo init no.
def var lntrxstor_list as char no-undo init ''.
find first sysc where sysc.sysc = "lntrxstor" no-lock no-error.
if avail sysc then assign lntrxstor_enabled = sysc.loval lntrxstor_list = sysc.chval.

def var v-ourbank as char.
{comm-txb.i}
v-ourbank = comm-txb().

def var v-s as char.

ja = no.
on choose of btn1 in frame ln1 do :
 v-s = v-method.
 ja = yes.
end.

on "END-ERROR" of frame ln1 do:
  hide frame ln1.
  ja = no.
end.

on choose of btn2 in frame ln1 do :
 apply "END-ERROR" to v-method in frame ln1.
end.

ON GO OF v-method DO:
    v-s = v-method.
END.

on return of v-method do:
 apply "go" to v-method in frame ln1.
end.

ENABLE v-method btn1 btn2 WITH FRAME ln1.

update v-method validate(can-find(jh where jh.jh eq integer(v-method)), "")
  with frame ln1.

wait-for choose of btn1 in frame ln1 or choose of btn2 in frame ln1.

s-jhold = integer(v-method).

if ja then do transaction on error undo, return:
    v-jdt = g-today.
    v-our = yes.
    v-lonour = no.

    find first jh where jh.jh = s-jhold no-lock no-error.

    for each jl where jl.jh eq s-jhold no-lock:
        if jl.sts eq 6 then v-finish = yes.
        if jl.gl eq v-cashgl then v-cash = yes.
        if jl.jdt ne g-today then v-jdt = jl.jdt.
        if jl.who ne g-ofc then v-our = no.
        if jl.acc eq s-lon then v-lonour = yes.
    end.

    /* если включена возможность сторнирования проводок банкадма у юзеров из справочника - редактируем v-our */
    if lntrxstor_enabled then
        if not v-our then v-our = (jh.who = "bankadm" and jh.jdt <> g-today and is_authorised(g-ofc,lntrxstor_list)).

    if not v-our then do :
      message "Вы не можете удалить чужую транзакцию."
      VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
      return.
    end.
    if v-finish and v-cash then do:
        message "Вы не можете удалить выполненную кассовую транзакцию."
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        return.
    end.
    if not v-lonour then do:
        message "Транзакция не связана с кредитом. Удаление невозможно."
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        return.
    end.

    ja = no.
    if v-jdt ne g-today then do :
        message "Транзакция не текущего дня. Выполнить сторно?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO update ja.
        if not ja then return.
    end.

    /* это проводка на выдачу? */
    find first jl where jl.jh = s-jhold and jl.acc = s-lon and jl.sub = "lon" and jl.dc = "d" and jl.lev = 1 no-lock no-error.
    v-isgrant = (jh.party begins "GRANT OF LOAN") and (avail jl).

    find first jl where jl.jh = s-jhold and jl.sub = "cif" and jl.dc = "c" and jl.lev = 1 no-lock no-error.
    v-isgrant = v-isgrant and (avail jl).

    if v-isgrant then do:
      v-grantacc = jl.acc.
      v-grantsum = jl.cam.

      /* есть анкета потребкредита, свзянная с этой транзакцией? */
      find first pkanketa where pkanketa.bank = v-ourbank and pkanketa.lon = s-lon and pkanketa.trx1 = s-jhold no-lock no-error.
      v-isanketa = avail pkanketa.
    end.
    else v-isanketa = no.

    if v-jdt eq g-today then do:
        v-sts = 0.
        run trxsts(input s-jhold, input v-sts, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes VIEW-AS ALERT-BOX.
            return.
        end.
        run trxdel(input s-jhold, input true, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes VIEW-AS ALERT-BOX.
            return.
        end.

        for each lnsch where lnsch.lnn eq s-lon and lnsch.jh eq s-jhold exclusive-lock:
            delete lnsch.
        end.
        for each lnsci where lnsci.lni eq s-lon and lnsci.jh eq s-jhold exclusive-lock:
            delete lnsci.
        end.
        for each lnscg where lnscg.lng eq s-lon and lnscg.jh eq s-jhold exclusive-lock:
            delete lnscg.
        end.
        for each lonres where lonres.lon eq s-lon and lonres.jh eq s-jhold exclusive-lock:
            if lonres.dc eq "D" and lonres.lev eq 2 then do:
                do i = 2 to num-entries(lonres.rem) by 2:
                    v-dtmp = entry(i,lonres.rem).
                    v-fdt = ?.
                    v-tdt = ?.
                    if length(v-dtmp) eq 8 then do:
                        v-tdt = date(
                        integer(substring(v-dtmp,5,2)),
                        integer(substring(v-dtmp,7,2)),
                        integer(substring(v-dtmp,1,4))
                        ) no-error.
                    end.
                    find acr where acr.lon eq s-lon and
                    acr.tdt eq v-tdt exclusive-lock no-error.
                    if available acr then do:
                      acr.sts = 0.
                      release acr.
                    end.
                end.
            end.
            delete lonres.
        end.
    end.
    else do:
        v-sts = 0.
        run trxstor(input s-jhold, input v-sts, output s-jh, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes VIEW-AS ALERT-BOX.
            return.
        end.

        for each lnsch where lnsch.lnn eq s-lon and lnsch.jh eq s-jhold exclusive-lock:
            delete lnsch.
        end.
        for each lnsci where lnsci.lni eq s-lon and lnsci.jh eq s-jhold exclusive-lock:
            delete lnsci.
        end.
        for each lnscg where lnscg.lng eq s-lon and lnscg.jh eq s-jhold exclusive-lock:
            delete lnscg.
        end.
        for each lonres where lonres.lon eq s-lon and lonres.jh eq s-jhold exclusive-lock:
            if lonres.dc eq "D" and lonres.lev eq 2 then do:
                do i = 2 to num-entries(lonres.rem) by 2:
                    v-dtmp = entry(i,lonres.rem).
                    v-fdt = ?.
                    v-tdt = ?.
                    if length(v-dtmp) eq 8 then do:
                        v-tdt = date(
                        integer(substring(v-dtmp,5,2)),
                        integer(substring(v-dtmp,7,2)),
                        integer(substring(v-dtmp,1,4))
                        ) no-error.
                    end.
                    find acr where acr.lon eq s-lon and acr.tdt eq v-tdt exclusive-lock no-error.
                    if available acr then do:
                      acr.sts = 0.
                      release acr.
                    end.
                end.
            end.
            delete lonres.
        end.


        /* pechat vauchera */
        ja = no.
        vou-count = 1. /* kolichestvo vaucherov */
        find jh where jh.jh eq s-jh no-lock no-error.
        do on endkey undo:
            message "Печатать ваучер ? " + string(s-jh) view-as alert-box
            buttons yes-no update ja.
            if ja then do:
                message "Сколько ?" update /* view-as alert-box set */ vou-count.
                if vou-count > 0 and vou-count < 10 then do:
                    find first jl where jl.jh = s-jh no-lock no-error.
                    if available jl then do:
                        {mesg.i 0933} s-jh.
                        do i = 1 to vou-count:
                            run x-jlvou.
                        end.

                        if jh.sts < 5 then jh.sts = 5.
                        for each jl of jh exclusive-lock:
                            if jl.sts < 5 then jl.sts = 5.
                        end.
                    end.  /* if available jl */
                    else do:
                        message "Can't find transaction " s-jh view-as alert-box.
                        return.
                    end.
                end.  /* if vou-count > 0 */
            end. /* if ja */
            pause 0.
        end.
        pause 0.
        view frame lon.
        view frame ln1.
        ja = no.
        message "Штамповать ?" update ja.
        if ja then run jl-stmp.
    end.

    /* если это проводка на выдачу - снять специнструкцию */
    if v-isgrant then run jou-aasdel (v-grantacc, v-grantsum, s-jhold).

    if v-isanketa then do:
        find first pkanketa where pkanketa.bank = v-ourbank and pkanketa.lon = s-lon and pkanketa.trx1 = s-jhold exclusive-lock no-error.
        if pkanketa.sts <= "40" then pkanketa.sts = "30".
        pkanketa.trx1 = 0.
        find current pkanketa no-lock.
    end.
end.




