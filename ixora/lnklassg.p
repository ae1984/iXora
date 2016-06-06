/* lnklassg.p
 * MODULE
        Гарантии
 * DESCRIPTION
        Классификация гарантии
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        2-1-9 Гарантии - Классиф
 * AUTHOR
        01.07.2011 id00810 (на основе lnklass.p, временный вариант)
 * CHANGES
 */

{global.i}
{kd.i "new"}

define shared var s-lon like lon.lon.
define shared variable v-cif like cif.cif init "".

find first garan where garan.garan = s-lon no-lock no-error.
if not avail garan then do:
    message "Гарантия не найдена" view-as alert-box.
    return.
end.

def var bilance as decimal format "->,>>>,>>>,>>9.99".
def var v-cod as char no-undo.
def var v-rat as deci no-undo init 0.
def var v-prosr as char no-undo.
def var v-statdescr as char no-undo init ''.
def var v-dt as date no-undo init ?.
/*
def var v-dtrm as date no-undo init ?.
*/
def var ja as logical no-undo format "да/нет" init no.
def var v-select as integer no-undo init 4.
def var v-summa as deci no-undo.

def var v-sec3 as deci. /* стоимость обеспечения по 3 группе - деньги */
def var v-sec  as deci. /* стоимость остального обеспечения */
def buffer b-crc for crc.

def var choice as logical no-undo.
def var v-coun as int no-undo init 0.
def var v-maxpr as int no-undo init 0.
def var v-err as char no-undo.

def var hanket as handle.
run lnlib persistent set hanket.
pause 0.

def new shared temp-table t-klass no-undo like kdlonkl.

for each kdklass where kdklass.type = 2 use-index kritcod no-lock .
    create t-klass.
    assign t-klass.bank = s-ourbank
           t-klass.kdcif = v-cif
           t-klass.kdlon = s-lon
           t-klass.kod = kdklass.kod
           t-klass.ln = kdklass.ln
           t-klass.who = g-ofc
           t-klass.whn = g-today.
end.

define variable s_rowid as rowid.
def var v-title as char init " КЛАССИФИКАЦИЯ ОБЯЗАТЕЛЬСТВА ".
def var v-fl as integer.

find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = v-cif and kdlonkl.kdlon = s-lon use-index bclrdt no-lock no-error.
if avail kdlonkl then do:
   v-dt = kdlonkl.rdt.
   /*if kdlonkl.info[4] <> "" and kdlonkl.info[4] <> "?" then v-dtrm = date(kdlonkl.info[4]). else v-dtrm = ?.*/
   for each kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = v-cif and kdlonkl.kdlon = s-lon and kdlonkl.rdt = v-dt no-lock:
       find t-klass where t-klass.kod = kdlonkl.kod no-error.
       if avail t-klass then assign t-klass.val1 = kdlonkl.val1
                                    t-klass.rating = kdlonkl.rating
                                    t-klass.valdesc = kdlonkl.valdesc.
   end.
end.
/*
choice = no.
message "Пересчитать автоматические критерии?" view-as alert-box question buttons yes-no title "" update choice.

if choice then do:

    /* 1. финансовое состояние */
    if lon.plan = 4 or lon.plan = 5 then do:
        find t-klass where t-klass.kod = 'finsost1' no-lock no-error.
        if avail t-klass then t-klass.val1 = '01'. /* стабильное */
        find bookcod where bookcod.bookcod = 'kdfin' and bookcod.code = t-klass.val1 no-lock no-error.
        if avail bookcod then
            assign t-klass.valdesc = bookcod.name
                   t-klass.rating = deci(trim(bookcod.info[1])).
    end. /* схема не 4 и не 5 - вручную */

    /* 2. просрочка */
    run pkmaxpr("",s-lon,output v-err,output v-coun,output v-maxpr).
    if v-err <> '' then message "Ошибка при расчете дней просрочки:~n" + v-err.
    else do:
        find t-klass where t-klass.kod = 'prosr' no-lock no-error.
        if avail t-klass then do:
            if v-maxpr < 15 then t-klass.val1 = '01'.
            if v-maxpr >= 15 and v-maxpr <= 30 then t-klass.val1 = '02'.
            if v-maxpr >= 31 and v-maxpr <= 60 then t-klass.val1 = '03'.
            if v-maxpr >= 61 and v-maxpr <= 90 then t-klass.val1 = '04'.
            if v-maxpr >= 91 then t-klass.val1 = '05'.
            find bookcod where bookcod.bookcod = 'kdprosr' and bookcod.code = t-klass.val1 no-lock no-error.
                if avail bookcod then
                    assign t-klass.valdesc = bookcod.name
                           t-klass.rating = deci(trim(bookcod.info[1])).
        end.
    end.

    /* 3. качество обеспечения */
    if lon.plan = 4 or lon.plan = 5 then do:
        find t-klass where t-klass.kod = 'obesp1' no-lock no-error.
        if avail t-klass then t-klass.val1 = '05'. /* без обеспечения */
        find bookcod where bookcod.bookcod = 'kdobes' and bookcod.code = t-klass.val1 no-lock no-error.
        if avail bookcod then
            assign t-klass.valdesc = bookcod.name
                   t-klass.rating = deci(trim(bookcod.info[1])).
    end.
    else do:
        find t-klass where t-klass.kod = 'obesp1' no-lock no-error.
        if avail t-klass then do:
             find first crc where crc.crc = lon.crc no-lock no-error.
             if not avail crc then return.

             run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output bilance).
             v-sec = 0.
             v-sec3 = 0.
             for each lonsec1 where lonsec1.lon = s-lon.
                 find first b-crc where b-crc.crc = lonsec1.crc no-lock no-error.
                 if not avail b-crc then return.
                 if lonsec1.lonsec = 3 then v-sec3 = v-sec3 + lonsec1.secamt * b-crc.rate[1] / crc.rate[1].
                                       else v-sec = v-sec + lonsec1.secamt * b-crc.rate[1] / crc.rate[1].
             end.
             t-klass.val1 = '05'.
             if v-sec3 > 0 and v-sec = 0 then do:
                if v-sec3 >= bilance then t-klass.val1 = '01'.
                if v-sec3 < bilance and v-sec3 >= 0.9 * bilance then t-klass.val1 = '02'.
                if v-sec3 < 0.9 * bilance and v-sec3 >= 0.75 * bilance then t-klass.val1 = '03'.
                if v-sec3 < 0.75 * bilance and v-sec3 >= 0.5 * bilance then t-klass.val1 = '04'.
                if v-sec3 < 0.5 * bilance then t-klass.val1 = '05'.
             end.
             if v-sec > 0 then do:
                bilance = bilance - v-sec3.
                if v-sec >= bilance then t-klass.val1 = '03'.
                if v-sec < bilance and v-sec >= 0.5 * bilance then t-klass.val1 = '04'.
                if v-sec < 0.5 * bilance then t-klass.val1 = '05'.
             end.
             find bookcod where bookcod.bookcod = 'kdobes' and bookcod.code = t-klass.val1 no-lock no-error.
             if avail bookcod then assign t-klass.valdesc = bookcod.name
                                          t-klass.rating = deci(trim(bookcod.info[1])).
        end.
    end.

    /* 4. количество пролонгаций */
    find t-klass where t-klass.kod = 'long' no-lock no-error.
    if avail t-klass then do:
        t-klass.val1 = '0'.
        if lon.ddt[5] <> ? then t-klass.val1 = '1'.
        if lon.cdt[5] <> ? then t-klass.val1 = '2'.
        find bookcod where bookcod.bookcod = 'kdlong' and bookcod.code = '02' no-lock no-error.
        if avail bookcod then assign t-klass.valdesc = bookcod.name
                                     t-klass.rating = decimal(t-klass.val1) * deci(trim(bookcod.info[1])).
    end.

    /* 5. Наличие других просроченных обязательств */
    if lon.plan = 4 or lon.plan = 5 then do:
        find t-klass where t-klass.kod = 'prosr_ob1' no-lock no-error.
        if avail t-klass then t-klass.val1 = '01'. /* нет */
        find bookcod where bookcod.bookcod = 'kdlong1' and bookcod.code = t-klass.val1 no-lock no-error.
        if avail bookcod then
            assign t-klass.valdesc = bookcod.name
                   t-klass.rating = deci(trim(bookcod.info[1])).
    end. /* схема не 4 и не 5 - вручную */

    /* 6. Доля нецелевого использования активов */
    if lon.plan = 4 or lon.plan = 5 then do:
        find t-klass where t-klass.kod = 'ispakt' no-lock no-error.
        if avail t-klass then t-klass.val1 = '01'. /* до 25 % */
        find bookcod where bookcod.bookcod = 'kdispakt' and bookcod.code = t-klass.val1 no-lock no-error.
        if avail bookcod then
            assign t-klass.valdesc = bookcod.name
                   t-klass.rating = deci(trim(bookcod.info[1])).
    end. /* схема не 4 и не 5 - вручную */

    /* 7. Наличие списанной задолженности */
    if lon.plan = 4 or lon.plan = 5 then do:
        find t-klass where t-klass.kod = 'spisob1' no-lock no-error.
        if avail t-klass then t-klass.val1 = '01'. /* отсутствует */
        find bookcod where bookcod.bookcod = 'kdkred' and bookcod.code = t-klass.val1 no-lock no-error.
        if avail bookcod then
            assign t-klass.valdesc = bookcod.name
                   t-klass.rating = deci(trim(bookcod.info[1])).
    end. /* схема не 4 и не 5 - вручную */

    /* 8. Наличие рейтинга у заемщика */
    if lon.plan = 4 or lon.plan = 5 then do:
        find t-klass where t-klass.kod = 'rait1' no-lock no-error.
        if avail t-klass then t-klass.val1 = '04'. /* Ниже рейтинга РК и без рейтинга */
        find bookcod where bookcod.bookcod = 'kdrait' and bookcod.code = t-klass.val1 no-lock no-error.
        if avail bookcod then
            assign t-klass.valdesc = bookcod.name
                   t-klass.rating = deci(trim(bookcod.info[1])).
    end. /* схема не 4 и не 5 - вручную */

end. /* if choice */
*/

repeat:

    {jabrw.i
    &start     = " "
    &head      = "t-klass"
    &headkey   = "kod"
    &index     = "bankln"

    &formname  = "lnklass"
    &framename = "lnklass"
    &frameparm = " "
    &where     = " true "
    &predisplay = " find first kdklass where kdklass.kod = t-klass.kod no-lock no-error. "
    &addcon    = "false"
    &deletecon = "false"
    &postcreate = " "
    &postupdate   = " find first kdklass where kdklass.kod = t-klass.kod no-lock no-error.
                      run value(kdklass.proc) in hanket (kdklass.kod).
                      display kdklass.name t-klass.val1 t-klass.valdesc t-klass.rating with frame lnklass. "

    &prechoose = " hide message. message 'Последняя дата классификации ' v-dt ."

    &postdisplay = " "

    &display   = " kdklass.name t-klass.val1 t-klass.valdesc t-klass.rating "
    &update    = " t-klass.val1 "
    &highlight = " t-klass.val1 "

    &postkey   = " "
    &end = " hide message no-pause. "
    }


    ja = no.
    run sel2 ("ВЫБЕРИТЕ РЕШЕНИЕ :",
              " 1. Сохранить классификацию по одному счету | 2. Сохранить классификацию по всем счетам | 3. Не сохранять классификацию | 4. Вернуться к редактированию ",
              output v-select).

    case v-select:
        when 1 then do: ja = yes. leave. end.
        when 2 then do: ja = yes. leave. end.
        when 3 then do: ja = no. leave. end.
    end case.

end. /* repeat */

hide all no-pause.

/* сохранение */

if ja then do:
    for each kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = v-cif and kdlonkl.kdlon = s-lon and kdlonkl.rdt = g-today .
        delete kdlonkl.
    end.

    for each t-klass:
        create kdlonkl.
        buffer-copy t-klass to kdlonkl.
        kdlonkl.rdt = g-today.
        v-rat = v-rat + t-klass.rating.
        if t-klass.kod = 'prosr' then v-prosr = t-klass.val1.
    end.

    create kdlonkl.
    assign kdlonkl.bank = s-ourbank
           kdlonkl.kdcif = v-cif
           kdlonkl.kdlon = s-lon
           kdlonkl.kod = 'klass'
           kdlonkl.rdt = g-today
           kdlonkl.who = g-ofc
           kdlonkl.whn = g-today.

    if v-rat <= 1 then kdlonkl.val1 = '01'.
    else
    if v-rat > 1 and v-rat <= 2 and v-prosr = '01' then kdlonkl.val1 = '02'.
    else
    if v-rat > 1 and v-rat <= 2 and v-prosr <> '01' then kdlonkl.val1 = '03'.
    else
    if v-rat > 2 and v-rat <= 3 and v-prosr = '01' then kdlonkl.val1 = '04'.
    else
    if v-rat > 2 and v-rat <= 3 and v-prosr <> '01' then kdlonkl.val1 = '05'.
    else
    if v-rat > 3 and v-rat <= 4 then kdlonkl.val1 = '06'.
    else
    if v-rat > 4 then kdlonkl.val1 = '07'.

    find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = kdlonkl.val1 no-lock no-error.
    if avail bookcod then v-statdescr = bookcod.name.
    message 'Классификация этого кредита - '  kdlonkl.val1 ' ' v-statdescr.
    release kdlonkl.
    pause.
end.

if v-select = 2 then do:

    empty temp-table t-klass.

    for each kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = v-cif and kdlonkl.kdlon = s-lon and kdlonkl.rdt = g-today no-lock:
        create t-klass.
        buffer-copy kdlonkl to t-klass.
    end.

    for each garan where garan.cif = v-cif and garan.garan <> s-lon no-lock:
        for each t-klass:
            create kdlonkl.
            buffer-copy t-klass to kdlonkl.
            kdlonkl.kdlon = garan.garan.
        end.
    end.
end.
