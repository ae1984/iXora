/* lnaddtr.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Привязка уже существующего транша к КЛ
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
        03/12/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

def shared var s-lon like lon.lon.
def shared var g-today as date.
def shared var g-ofc as char.
def shared var g-lang as char.

def var v-lontr like lon.lon.
def var v-type as integer no-undo.
def var v-ja as logi no-undo.

def var v-msg as char no-undo.
def var v-ost as deci no-undo.
def buffer b-lon for lon.
def buffer b-loncon for loncon.
def var s-glrem as char no-undo.

def new shared var s-jh like jh.jh init 0.
def var v-templ as char no-undo.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.

def var ja-ne as log no-undo format "да/нет".
def var vou-count as int no-undo.
def var i as int no-undo.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then return.

find first loncon where loncon.lon = lon.lon no-lock no-error.
if not avail loncon then do:
    message "Не найдена запись loncon!" view-as alert-box error.
    return.
end.

find first cif where cif.cif = lon.cif no-lock no-error.
if not avail cif then do:
    message "Не найдена карточка клиента!" view-as alert-box error.
    return.
end.

if lon.gua <> "CL" then do:
    message "Не кредитная линия!" view-as alert-box error.
    return.
end.

function valLon returns logical (input p-lon as char, input p-type as integer).
    def var res as logi no-undo.
    res = yes.
    def buffer bb for lon.
    def var v-bal as deci no-undo.
    def var v-balcl as deci no-undo.
    find first bb where bb.lon = p-lon no-lock no-error.
    if not avail bb then res = no.
    if res then do:
        if bb.opnamt <= 0 then do:
            v-msg = "Одобренная сумма = 0!".
            res = no.
        end.
    end.
    if res then do:
        if bb.cif <> lon.cif then do:
            v-msg = "Кредит другого клиента!".
            res = no.
        end.
    end.
    if res then do:
        if bb.crc <> lon.crc then do:
            v-msg = "Валюты не совпадают!".
            res = no.
        end.
    end.
    if res then do:
        run lonbalcrc('lon',p-lon,g-today,"1,7",yes,bb.crc,output v-bal).
        if v-bal <= 0 then do:
            v-msg = "Остаток ОД = 0!".
            res = no.
        end.
    end.
    if res then do:
        v-bal = 0.
        v-balcl = 0.
        if p-type = 1 then do:
            run lonbalcrc('lon',p-lon,g-today,"1,7",yes,bb.crc,output v-bal).
            run lonbalcrc('lon',lon.lon,g-today,"15",yes,lon.crc,output v-balcl).
        end.
        else
        if p-type = 2 then do:
            v-bal = bb.opnamt.
            run lonbalcrc('lon',lon.lon,g-today,"35",yes,lon.crc,output v-balcl).
        end.
        v-balcl = - v-balcl.
        if v-balcl < v-bal then do:
            if p-type = 1 then v-msg = "Остаток ОД > возобн. доступного остатка КЛ!".
            else v-msg = "Одобр. сумма > невозобн. доступного остатка КЛ!".
            res = no.
        end.
    end.
    return res.
end function.

form v-type label "Тип транша (1-возобн., 2-невозобн.)" format "9" validate(v-type > 0 and v-type < 3,"Некорректный тип транша!") skip
     v-lontr label "Номер сс. счета транша............." format "x(9)" validate(valLon(v-lontr,v-type),v-msg) skip
     v-ja label "Произвести привязку транша?........" format "да/нет"
with centered row 13 side-labels overlay frame fr.

def temp-table t-lon no-undo
  field lon as char
  field opnamt as deci
  field lcnt as char
  field rdt as date
  index idx is primary rdt lon.

on help of v-lontr do:
    empty temp-table t-lon.
    for each b-lon where b-lon.cif = lon.cif and b-lon.gua <> "CL" and b-lon.opnamt > 0 no-lock:
        create t-lon.
        assign t-lon.lon = b-lon.lon
               t-lon.opnamt = b-lon.opnamt
               t-lon.rdt = b-lon.rdt.
        find first b-loncon where b-loncon.lon = b-lon.lon no-lock no-error.
        if avail b-loncon then t-lon.lcnt = b-loncon.lcnt.
    end.
    {itemlist.i
        &file = "t-lon"
        &frame = "row 6 centered scroll 1 20 down overlay "
        &where = " true "
        &flddisp = " t-lon.lon label 'Сс.счет' format 'x(9)'
                     t-lon.lcnt label 'Договор' format 'x(40)'
                     t-lon.rdt label 'ДатаВыд' format '99/99/9999'
                     t-lon.opnamt label 'ОдобрСумма' format '>>>,>>>,>>>,>>9.99'
                   "
        &chkey = "lon"
        &chtype = "string"
        &index  = "idx"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-lontr = t-lon.lon.
    displ v-lontr with frame fr.
end.

v-type = 1.
v-lontr = ''.
v-ja = no.

display v-type v-lontr v-ja with frame fr.

update v-type with frame fr.
update v-lontr with frame fr.
update v-ja with frame fr.

if v-ja then do:

    s-jh = 0.
    find first crc where crc.crc = lon.crc no-lock no-error.

    find first b-lon where b-lon.lon = v-lontr no-lock no-error.
    if avail b-lon then do:
        if v-type = 1 then do:
            v-templ = "LON0139".
            run lonbalcrc('lon',v-lontr,g-today,"1,7",yes,b-lon.crc,output v-ost).
        end.
        else do:
            v-templ = "LON0140".
            v-ost = b-lon.opnamt.
        end.

        v-param = string (v-ost) + vdel + lon.lon.

        s-glrem = "Списание ".
        if v-type = 1 then s-glrem = s-glrem + "возобн. ".
        else s-glrem = s-glrem + "невозобн. ".
        s-glrem = s-glrem + "дост. остатка КЛ, " + lon.lon + " " + loncon.lcnt +
                  " " + trim(string(v-ost,">>>,>>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code +
                  " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss.
        v-param = v-param + vdel + s-glrem + vdel + vdel + vdel + vdel.

        run trxgen (v-templ, vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        if rcode <> 0 then do:
            message rdes + " Ошибка списания дост. остатка КЛ!".
            pause.
            return.
        end.

        do transaction:
            find current b-lon exclusive-lock.
            b-lon.clmain = lon.lon.
            b-lon.trtype = v-type.
            find current b-lon no-lock.
        end.

        if s-jh > 0 then do transaction:
            ja-ne = no.
            vou-count = 1.
            do on endkey undo:
                message "Печатать ваучер?" update ja-ne.
                if ja-ne then do:
                    message "Сколько?" update vou-count format "9" .
                    if vou-count > 0 and vou-count < 10 then do:
                        find first jl where jl.jh = s-jh no-lock no-error.
                        if available jl then do:
                            {mesg.i 0933} s-jh.
                            do i = 1 to vou-count:
                                run vou_lon(s-jh,'1').
                            end.
                            find jh where jh.jh = s-jh exclusive-lock.
                            if jh.sts < 5 then jh.sts = 5.
                            for each jl of jh:
                                if jl.sts < 5 then jl.sts = 5.
                            end.
                        end.
                        else do:
                            message "Не найдена транзакция " s-jh view-as alert-box.
                        end.
                    end.
                end.
            end.
        end.

    end.
    else message "Транш не найден!" view-as alert-box error.
end.


