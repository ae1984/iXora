/* repmarj1.p
 * MODULE
        Бухгалтерский отчет
 * DESCRIPTION
        Отчет Анализ процентной маржи в тенге за период в сравнении с периодом с начала года.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.18.8
 * AUTHOR
        01.04.2011 Luiza
 * BASES
        BANK COMM TXB
 * CHANGES
        21.02.2012 damir - Отчет работал не правильно, почти полностью переделал. Т.З. № 1283.
*/

def shared var v-fil-cnt as char format "x(30)".
def shared var v-fil-int as int.
def shared var dt1       as date.
def shared var dt2       as date.
def shared var dt        as date.
def shared var cntd      as inte no-undo.
def shared var cnty      as inte no-undo.
def shared var v-aktglr1 as char init "".
def shared var v-aktglr2 as char init "".
def shared var v-aktglr3 as char init "".
def shared var v-aktglr4 as char init "".
def shared var v-aktglr5 as char init "".
def shared var v-aktglr6 as char init "".

def var v-sumt   as deci no-undo.
def var v-sumt1  as deci no-undo.
def var v-sumy   as deci no-undo.
def var v-sumy1  as deci no-undo.
def var v-sumz   as deci no-undo.
def var v-sumz1  as deci no-undo.
def var v-sump   as deci no-undo.
def var v-sump1  as deci no-undo.
def var v-sumr   as deci no-undo.
def var v-sumr1  as deci no-undo.
def var v-rast   as deci no-undo.
def var v-rasy   as deci no-undo.
def var f-rast   as deci no-undo.
def var f-rasy   as deci no-undo.
def var v-rast1  as deci no-undo.
def var v-rasy1  as deci no-undo.
def var f-rast1  as deci no-undo.
def var f-rasy1  as deci no-undo.
def var v-pr     as logi init no.
def var v-jl     as deci no-undo.
def var v-res    as deci no-undo.
def var v-resv   as deci no-undo.
def var v-resul  as deci no-undo.
def var v-resulv as deci no-undo.
def var v-int1   as inte no-undo.
def var v-int2   as inte no-undo.

define shared temp-table wrk no-undo
    field p         as inte
    field pp        as inte
    field nname     as char
    field av_saldo  as deci
    field av_saldo1 as deci
    field av_saldo2 as deci
    field av_saldo3 as deci
    field an_rate   as deci
    field income    as deci
    field income1   as deci
    field an_rate1  as deci
    field income3   as deci
    field an_rate3  as deci
    index ind1 is primary p.

define shared temp-table wrk2 no-undo
    field p         as inte
    field pp        as inte
    field nname     as char
    field av_saldo  as deci
    field av_saldo1 as deci
    field av_saldo2 as deci
    field av_saldo3 as deci
    field income    as deci
    field an_rate   as deci
    field income1   as deci
    field an_rate1  as deci
    field income3   as deci
    field an_rate3  as deci
    index ind1 is primary p.

def shared temp-table t-period no-undo
    field dt as date
    index idx is primary dt.

def shared temp-table g-period no-undo
    field dt as date
    index idx is primary dt.

def shared temp-table ch no-undo
    field p   as int
    field fl  as char
    field gl  as int
    field acc as char
    field crc as int
    field glr as int
    field lev as int
    index idx is primary p fl gl.

def temp-table t-tmpgl
    field gl as inte
    index idxgl is primary gl ascending.

def shared temp-table akt_saldo no-undo
    field pr    as logic
    field p     as integer
    field fl    as char format "x(3)"
    field nname as char
    field ch    as char
    field glr   as char
    index idx1 is primary p.

def shared temp-table ob_saldo no-undo
    field pr    as logic
    field p     as integer
    field fl    as char format "x(3)"
    field pp    as integer
    field nname as char
    field ch    as char
    field glr   as char
    index idx is primary p.

def var v-ch    as char.
def var num     as inte no-undo.
def var numglr  as inte no-undo.
def var numgl   as inte no-undo.
def var i       as inte no-undo.

find first txb.cmp no-lock no-error.
if avail txb.cmp then v-fil-cnt = txb.cmp.name.
message "Ждите, идет подготовка данных для отчета " + v-fil-cnt.
v-fil-int = v-fil-int + 1.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.

def temp-table t-date
    field dayrep as date
    field num    as inte
    index idx is primary num ascending.

def var nummonth as inte.
def var yearnum  as inte.
def var v-modulo as inte.
def var k        as inte.
def var s        as inte.
def var begyear  as date.

begyear  = date(01,01,year(dt)).
nummonth = month(dt).
yearnum  = year(dt).

do k = 1 to nummonth:
    if k = 1 or k = 3 or k = 5 or k = 7 or k = 8 or k = 10 or k = 12 then do:
        create t-date.
        assign
        t-date.dayrep = date(k,31,yearnum)
        t-date.num    = k.
    end.
    if k = 4 or k = 6 or k = 11 or k = 9 then do:
        create t-date.
        assign
        t-date.dayrep = date(k,30,yearnum)
        t-date.num    = k.
    end.
    if k = 2 then do:
        v-modulo = integer(substr(string(yearnum),3,2)) modulo 4.
        if v-modulo = 0 then do:
            create t-date.
            assign
            t-date.dayrep = date(k,29,yearnum)
            t-date.num    = k.
        end.
        else do:
            create t-date.
            assign
            t-date.dayrep = date(k,28,yearnum)
            t-date.num    = k.
        end.
    end.
end.

/*message "Конечные дни месяцев начиная с начала года" view-as alert-box.
for each t-date no-lock:
    message t-date.dayrep view-as alert-box.
end.

message "За месяц" view-as alert-box.
for each txb.cls where txb.cls.whn >= date(month(dt),01,year(dt)) and txb.cls.cls <= dt no-lock:
    message txb.cls.whn view-as alert-box.
end.

message "Отчет даты с начала года" view-as alert-box.
for each txb.cls where txb.cls.whn >= begyear and txb.cls.cls <= dt no-lock:
    message txb.cls.whn view-as alert-box.
end.*/

empty temp-table ch.

def var v-sum11 as deci.
def var v-sum12 as deci.
def var v-sum21 as deci.
def var v-sum22 as deci.
def var v-sum31 as deci.
def var v-sum32 as deci.
def var v-sum41 as deci.
def var v-sum42 as deci.
def var v-sum51 as deci.
def var v-sum52 as deci.
def var v-sum61 as deci.
def var v-sum62 as deci.
def var v-sum71 as deci.
def var v-sum72 as deci.
def var v-sum81 as deci.
def var v-sum82 as deci.
def var v-sum91 as deci.
def var v-sum92 as deci.
def var v-sum101 as deci.
def var v-sum102 as deci.
def var v-sum111 as deci.
def var v-sum112 as deci.
def var v-sum121 as deci.
def var v-sum122 as deci.

def var v-totalsum1 as deci.
def var v-totalsum2 as deci.

def buffer b-t-date1 for t-date.
def buffer b-t-date2 for t-date.
def buffer b-t-date3 for t-date.
def buffer b-t-date4 for t-date.
def buffer b-t-date5 for t-date.
def buffer b-t-date6 for t-date.
def buffer b-t-date7 for t-date.
def buffer b-t-date8 for t-date.
def buffer b-t-date9 for t-date.
def buffer b-t-date10 for t-date.
def buffer b-t-date11 for t-date.
def buffer b-t-date12 for t-date.

/*Сбор счетов ГК для обработки*/
for each akt_saldo no-lock:
    num = num-entries(akt_saldo.ch).
    /*Среднемесячное сальдо*/
    do i = 1 to num:
        assign v-ch = "".
        v-ch = entry(i,akt_saldo.ch).
        for each txb.gl where txb.gl.gl >= integer(v-ch) * 100 and txb.gl.gl <= (integer(v-ch) * 100) + 99 no-lock:
            create ch.
            assign
            ch.p  = akt_saldo.p
            ch.fl = "gl"
            ch.gl = txb.gl.gl.
        end.
    end.
    numglr = num-entries(akt_saldo.glr).
    /*Доход/расход по балансу*/
    do i = 1 to numglr:
        assign v-ch = "".
        v-ch = entry(i,akt_saldo.glr).
        for each txb.gl where txb.gl.gl >= integer(v-ch) * 100 and txb.gl.gl <= (integer(v-ch) * 100) + 99 no-lock:
            create ch.
            assign
            ch.p  = akt_saldo.p
            ch.fl = "glr"
            ch.gl = txb.gl.gl.
        end.
    end.
    if akt_saldo.p = 3 or akt_saldo.p = 4 then do:
        numgl = num-entries(akt_saldo.glr).
        do i = 1 to numgl:
            assign v-ch = "".
            v-ch = entry(i,akt_saldo.glr).
            for each txb.gl where txb.gl.gl >= integer(v-ch) * 100 and txb.gl.gl <= (integer(v-ch) * 100) + 99 no-lock:
                create t-tmpgl.
                assign
                t-tmpgl.gl = txb.gl.gl.
            end.
        end.
    end.
end.

for each akt_saldo no-lock:
    assign  v-sumt = 0 v-sumt1 = 0
            v-sumy = 0 v-sumy1 = 0
            v-sumz = 0 v-sumz1 = 0
            v-sump = 0 v-sump1 = 0
            v-sumr = 0 v-sumr1 = 0
            v-sum11 = 0 v-sum12 = 0 v-sum21 = 0 v-sum22 = 0 v-sum31 = 0 v-sum32 = 0 v-sum41 = 0 v-sum42 = 0 v-sum51 = 0 v-sum52 = 0
            v-sum61 = 0 v-sum62 = 0 v-sum71 = 0 v-sum72 = 0 v-sum81 = 0 v-sum82 = 0 v-sum91 = 0 v-sum92 = 0 v-sum101 = 0 v-sum102 = 0
            v-sum111 = 0 v-sum112 = 0 v-sum121 = 0 v-sum122 = 0 v-totalsum1 = 0 v-totalsum2 = 0.

    create wrk.
    assign
    wrk.p  = akt_saldo.p
    wrk.pp = akt_saldo.p.
    for each ch where ch.p = akt_saldo.p and trim(ch.fl) = "gl" no-lock:
        assign v-res = 0 v-resv = 0.
        run getGL(ch.gl,dt,akt_saldo.p,yes,output v-res,output v-resv).
        v-sumt  = v-sumt  + v-res.
        v-sumt1 = v-sumt1 + v-resv.
    end.
    for each ch where ch.p = akt_saldo.p and trim(ch.fl) = "glr" no-lock:
        if month(dt) > 1 then do:
            find first b-t-date1 where b-t-date1.num = month(dt) no-lock no-error.
            assign v-resul = 0 v-resulv = 0.
            run getGL(ch.gl,b-t-date1.dayrep,0,no,output v-resul,output v-resulv).
            v-sumz  = v-sumz  + v-resul.
            v-sumz1 = v-sumz1 + v-resulv.

            find first b-t-date2 where b-t-date2.num = month(dt) - 1 no-lock no-error.
            assign v-resul = 0 v-resulv = 0.
            run getGL(ch.gl,b-t-date2.dayrep,0,no,output v-resul,output v-resulv).
            v-sumr  = v-sumr  + v-resul.
            v-sumr1 = v-sumr1 + v-resulv.
        end.
        else do:
            assign v-resul = 0 v-resulv = 0.
            run getGL(ch.gl,dt,0,no,output v-resul,output v-resulv).
            v-sumz  = v-sumz  + v-resul.
            v-sumz1 = v-sumz1 + v-resulv.
        end.
    end.
    assign
    wrk.av_saldo  = round(v-sumt,2)   /*KZT*/
    wrk.av_saldo1 = round(v-sumt1,2)  /*OTHER RATE*/
    wrk.av_saldo2 = round(absolute(v-sumz - v-sumr),2)   /*KZT*/
    wrk.av_saldo3 = round(absolute(v-sumz1 - v-sumr1),2). /*OTHER RATE*/

    create wrk.
    wrk.p = akt_saldo.p.
    wrk.pp = 0. /*Данные сначала года*/
    for each ch where ch.p = akt_saldo.p and trim(ch.fl) = "gl" no-lock:
        for each t-date use-index idx:
            assign v-res = 0 v-resv = 0.
            run getGL(ch.gl,t-date.dayrep,akt_saldo.p,yes,output v-res,output v-resv).
            v-sumy  = v-sumy  + v-res.
            v-sumy1 = v-sumy1 + v-resv.
        end.
    end.
    for each ch where ch.p = akt_saldo.p and trim(ch.fl) = "glr" no-lock:
        run BEGCOMPUTING.
    end.
    v-totalsum1 = v-sum11 + v-sum21 + v-sum31 + v-sum41 + v-sum51 + v-sum61 + v-sum71 + v-sum81 + v-sum91 + v-sum101 + v-sum111 +
    v-sum121.
    v-totalsum2 = v-sum12 + v-sum22 + v-sum32 + v-sum42 + v-sum52 + v-sum62 + v-sum72 + v-sum82 + v-sum92 + v-sum102 + v-sum112 +
    v-sum122.
    assign
    wrk.av_saldo  = round(v-sumy / month(dt),2)
    wrk.av_saldo1 = round(v-sumy1 / month(dt),2)
    wrk.av_saldo2 = round(v-totalsum1 / month(dt),2)
    wrk.av_saldo3 = round(v-totalsum2 / month(dt),2).
end.

/*message "Активы" view-as alert-box.
for each wrk no-lock:
    message wrk.p " " wrk.pp " " wrk.av_saldo " " wrk.av_saldo1 " " wrk.av_saldo2 " " wrk.av_saldo3 view-as alert-box.
end.*/

/*   обязательства  ------------------------------------------------------------------------- */
empty temp-table ch.
for each ob_saldo no-lock:
    num = NUM-ENTRIES(ob_saldo.ch).
    do i = 1 to num:
        assign v-ch = "".
        v-ch = entry(i,ob_saldo.ch).
        for each txb.gl where txb.gl.gl >= integer(v-ch) * 100 and  txb.gl.gl <= (integer(v-ch) * 100) + 99 no-lock:
            create ch.
            ch.p  = ob_saldo.p.
            ch.fl = "gl".
            ch.gl = txb.gl.gl.
        end.
    end.
    numglr = NUM-ENTRIES(ob_saldo.glr).
    do i = 1 to numglr:
        assign v-ch = "".
        v-ch = entry(i,ob_saldo.glr).
        for each txb.gl where txb.gl.gl >= integer(v-ch) * 100 and  txb.gl.gl <= (integer(v-ch) * 100) + 99 no-lock:
            create ch.
            ch.p  = ob_saldo.p.
            ch.fl = "glr".
            ch.gl = txb.gl.gl.
        end.
    end.
end.
for each ob_saldo no-lock:
    assign  v-sumt = 0 v-sumt1 = 0
            v-sumy = 0 v-sumy1 = 0
            v-sumz = 0 v-sumz1 = 0
            v-sump = 0 v-sump1 = 0
            v-sumr = 0 v-sumr1 = 0
            v-sum11 = 0 v-sum12 = 0 v-sum21 = 0 v-sum22 = 0 v-sum31 = 0 v-sum32 = 0 v-sum41 = 0 v-sum42 = 0 v-sum51 = 0 v-sum52 = 0
            v-sum61 = 0 v-sum62 = 0 v-sum71 = 0 v-sum72 = 0 v-sum81 = 0 v-sum82 = 0 v-sum91 = 0 v-sum92 = 0 v-sum101 = 0 v-sum102 = 0
            v-sum111 = 0 v-sum112 = 0 v-sum121 = 0 v-sum122 = 0 v-totalsum1 = 0 v-totalsum2 = 0.

    create wrk2.
    assign
    wrk2.p  = ob_saldo.p
    wrk2.pp = ob_saldo.p.
    for each ch where ch.p = ob_saldo.p and trim(ch.fl) = "gl" no-lock:
        assign v-res = 0 v-resv = 0.
        run getGL(ch.gl,dt,0,no,output v-res,output v-resv).
        v-sumt  = v-sumt  + v-res.
        v-sumt1 = v-sumt1 + v-resv.
    end.
    for each ch where ch.p = ob_saldo.p and trim(ch.fl) = "glr" no-lock:
        if month(dt) > 1 then do:
            find first b-t-date1 where b-t-date1.num = month(dt) no-lock no-error.
            assign v-resul = 0 v-resulv = 0.
            run getGL(ch.gl,b-t-date1.dayrep,0,no,output v-resul,output v-resulv).
            v-sumz  = v-sumz  + v-resul.
            v-sumz1 = v-sumz1 + v-resulv.

            find first b-t-date2 where b-t-date2.num = month(dt) - 1 no-lock no-error.
            assign v-resul = 0 v-resulv = 0.
            run getGL(ch.gl,b-t-date2.dayrep,0,no,output v-resul,output v-resulv).
            v-sumr  = v-sumr  + v-resul.
            v-sumr1 = v-sumr1 + v-resulv.
        end.
        else do:
            assign v-resul = 0 v-resulv = 0.
            run getGL(ch.gl,dt,0,no,output v-resul,output v-resulv).
            v-sumz  = v-sumz  + v-resul.
            v-sumz1 = v-sumz1 + v-resulv.
        end.
    end.
    assign
    wrk2.av_saldo  = round(v-sumt,2)   /*KZT*/
    wrk2.av_saldo1 = round(v-sumt1,2)  /*OTHER RATE*/
    wrk2.av_saldo2 = round(absolute(v-sumz - v-sumr),2)   /*KZT*/
    wrk2.av_saldo3 = round(absolute(v-sumz1 - v-sumr1),2). /*OTHER RATE*/

    create wrk2.
    assign
    wrk2.p  = ob_saldo.p
    wrk2.pp = 0.
    for each ch where ch.p = ob_saldo.p and trim(ch.fl) = "gl" no-lock:
        for each t-date use-index idx:
            assign v-res = 0 v-resv = 0.
            run getGL(ch.gl,t-date.dayrep,0,no,output v-res,output v-resv).
            v-sumy  = v-sumy  + v-res.
            v-sumy1 = v-sumy1 + v-resv.
        end.
    end.
    for each ch where ch.p = ob_saldo.p and trim(ch.fl) = "glr" no-lock:
        run BEGCOMPUTING.
    end.
    v-totalsum1 = v-sum11 + v-sum21 + v-sum31 + v-sum41 + v-sum51 + v-sum61 + v-sum71 + v-sum81 + v-sum91 + v-sum101 + v-sum111 +
    v-sum121.
    v-totalsum2 = v-sum12 + v-sum22 + v-sum32 + v-sum42 + v-sum52 + v-sum62 + v-sum72 + v-sum82 + v-sum92 + v-sum102 + v-sum112 +
    v-sum122.
    assign
    wrk2.av_saldo  = round(v-sumy / month(dt),2)
    wrk2.av_saldo1 = round(v-sumy1 / month(dt),2)
    wrk2.av_saldo2 = round(v-totalsum1 / month(dt),2)
    wrk2.av_saldo3 = round(v-totalsum2 / month(dt),2).
end.
/*message "Обязательства" view-as alert-box.
for each wrk2 no-lock:
    message wrk2.p " " wrk2.pp " " wrk2.av_saldo " " wrk2.av_saldo1 " " wrk2.av_saldo2 " " wrk2.av_saldo3 view-as alert-box.
end.*/
hide message no-pause.

procedure getGL:
    def input  parameter p-gl as inte.
    def input  parameter p-dt as date.
    def input  parameter p-pp as inte.
    def input  parameter p-lo as logi.
    def output parameter res  as deci. /*KZT*/
    def output parameter resv as deci. /*Other RATE*/

    def var res1 as deci no-undo.

    assign res = 0 resv = 0 res1 = 0.

    find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = 1 and txb.glday.gdt <= p-dt no-lock no-error.
    if avail txb.glday then do:
        if p-lo = yes then do:
            if p-pp <> 3 and p-pp <> 4 then res = ABSOLUTE(txb.glday.dam - txb.glday.cam).
            else res = txb.glday.dam - txb.glday.cam.
        end.
        else res = ABSOLUTE(txb.glday.dam - txb.glday.cam).
    end.

    for each txb.crc where txb.crc.crc <> 1 no-lock:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt no-lock no-error.
        if avail txb.glday then do:
            res1 = txb.glday.dam - txb.glday.cam.
            find last txb.crchis where txb.crchis.crc = txb.glday.crc and txb.crchis.rdt <= p-dt no-lock no-error.
            if avail txb.crchis then do:
                if p-lo = yes then do:
                    if p-pp <> 3 and p-pp <> 4 then resv = resv + (ABSOLUTE(res1) * txb.crchis.rate[1]).
                    else resv = resv + (res1 * txb.crchis.rate[1]).
                end.
                else resv = resv + (ABSOLUTE(res1) * txb.crchis.rate[1]).
            end.
        end.
    end.
end procedure.

procedure getGLBEGINSYEAR:
    def input parameter  p-gl   as inte.
    def input parameter  p-dt1  as date.
    def input parameter  p-dt2  as date.
    def output parameter res    as deci.
    def output parameter resv   as deci.

    def var v-resultkzt1 as deci.
    def var v-resultoth1 as deci.
    def var v-resultkzt2 as deci.
    def var v-resultoth2 as deci.
    def var v-tmpstr     as char init "".

    for each t-tmpgl no-lock:
        if v-tmpstr <> "" then v-tmpstr = v-tmpstr + "," + trim(string(t-tmpgl.gl)).
        else v-tmpstr = trim(string(t-tmpgl.gl)).
    end.

    assign v-resultkzt1 = 0 v-resultoth1 = 0 v-resultkzt2 = 0 v-resultoth2 = 0.
    assign res = 0 resv = 0.

    if p-dt1 <> ? then do:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = 1 and txb.glday.gdt <= p-dt1 no-lock no-error.
        if avail txb.glday then do:
            if lookup(string(p-gl),v-tmpstr) <= 0 then v-resultkzt1 = ABSOLUTE(txb.glday.dam - txb.glday.cam).
            else v-resultkzt1 = txb.glday.dam - txb.glday.cam.
        end.
        for each txb.crc where txb.crc.crc <> 1 no-lock:
            find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt1 no-lock no-error.
            if avail txb.glday then do:
                find last txb.crchis where txb.crchis.crc = txb.glday.crc and txb.crchis.rdt <= p-dt1 no-lock no-error.
                if avail txb.crchis then do:
                    if lookup(string(p-gl),v-tmpstr) <= 0 then v-resultoth1 = v-resultoth1 + (ABSOLUTE(txb.glday.dam - txb.glday.cam) * txb.crchis.rate[1]).
                    else v-resultoth1 = v-resultoth1 + (txb.glday.dam - txb.glday.cam) * txb.crchis.rate[1].
                end.
            end.
        end.
    end.
/*----------------------------------------------------------------------------------------------------------------------------------*/

    if p-dt2 <> ? then do:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = 1 and txb.glday.gdt <= p-dt2 no-lock no-error.
        if avail txb.glday then do:
            if lookup(string(p-gl),v-tmpstr) <= 0 then v-resultkzt2 = ABSOLUTE(txb.glday.dam - txb.glday.cam).
            else v-resultkzt2 = txb.glday.dam - txb.glday.cam.
        end.
        for each txb.crc where txb.crc.crc <> 1 no-lock:
            find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt2 no-lock no-error.
            if avail txb.glday then do:
                find last txb.crchis where txb.crchis.crc = txb.glday.crc and txb.crchis.rdt <= p-dt2 no-lock no-error.
                if avail txb.crchis then do:
                    if lookup(string(p-gl),v-tmpstr) <= 0 then v-resultoth2 = v-resultoth2 + (ABSOLUTE(txb.glday.dam - txb.glday.cam) * txb.crchis.rate[1]).
                    else v-resultoth2 = v-resultoth2 + (txb.glday.dam - txb.glday.cam) * txb.crchis.rate[1].
                end.
            end.
        end.
    end.

    if lookup(string(p-gl),v-tmpstr) <= 0 then do:
        res = ABSOLUTE(v-resultkzt1 - v-resultkzt2).
        resv = ABSOLUTE(v-resultoth1 - v-resultoth2).
    end.
    else do:
        res = v-resultkzt1 - v-resultkzt2.
        resv = v-resultoth1 - v-resultoth2.
    end.
end procedure.

procedure BEGCOMPUTING:
    if month(dt) = 1 then do:
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,dt,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 2 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 3 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        find first b-t-date2 where b-t-date2.num = month(dt) - 2 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum31 = v-sum31 + v-res.
        v-sum32 = v-sum32 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date2.dayrep,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date2.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 4 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        find first b-t-date2 where b-t-date2.num = month(dt) - 2 no-lock no-error.
        find first b-t-date3 where b-t-date3.num = month(dt) - 3 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum41 = v-sum41 + v-res.
        v-sum42 = v-sum42 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date2.dayrep,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum31 = v-sum31 + v-res.
        v-sum32 = v-sum32 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date3.dayrep,b-t-date2.dayrep,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date3.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 5 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        find first b-t-date2 where b-t-date2.num = month(dt) - 2 no-lock no-error.
        find first b-t-date3 where b-t-date3.num = month(dt) - 3 no-lock no-error.
        find first b-t-date4 where b-t-date4.num = month(dt) - 4 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum51 = v-sum51 + v-res.
        v-sum52 = v-sum52 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date2.dayrep,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum41 = v-sum41 + v-res.
        v-sum42 = v-sum42 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date3.dayrep,b-t-date2.dayrep,output v-res,output v-resv).
        v-sum31 = v-sum31 + v-res.
        v-sum32 = v-sum32 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date4.dayrep,b-t-date3.dayrep,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date4.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 6 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        find first b-t-date2 where b-t-date2.num = month(dt) - 2 no-lock no-error.
        find first b-t-date3 where b-t-date3.num = month(dt) - 3 no-lock no-error.
        find first b-t-date4 where b-t-date4.num = month(dt) - 4 no-lock no-error.
        find first b-t-date5 where b-t-date5.num = month(dt) - 5 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum61 = v-sum61 + v-res.
        v-sum62 = v-sum62 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date2.dayrep,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum51 = v-sum51 + v-res.
        v-sum52 = v-sum52 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date3.dayrep,b-t-date2.dayrep,output v-res,output v-resv).
        v-sum41 = v-sum41 + v-res.
        v-sum42 = v-sum42 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date4.dayrep,b-t-date3.dayrep,output v-res,output v-resv).
        v-sum31 = v-sum31 + v-res.
        v-sum32 = v-sum32 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date5.dayrep,b-t-date4.dayrep,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date5.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 7 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        find first b-t-date2 where b-t-date2.num = month(dt) - 2 no-lock no-error.
        find first b-t-date3 where b-t-date3.num = month(dt) - 3 no-lock no-error.
        find first b-t-date4 where b-t-date4.num = month(dt) - 4 no-lock no-error.
        find first b-t-date5 where b-t-date5.num = month(dt) - 5 no-lock no-error.
        find first b-t-date6 where b-t-date6.num = month(dt) - 6 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum71 = v-sum71 + v-res.
        v-sum72 = v-sum72 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date2.dayrep,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum61 = v-sum61 + v-res.
        v-sum62 = v-sum62 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date3.dayrep,b-t-date2.dayrep,output v-res,output v-resv).
        v-sum51 = v-sum51 + v-res.
        v-sum52 = v-sum52 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date4.dayrep,b-t-date3.dayrep,output v-res,output v-resv).
        v-sum41 = v-sum41 + v-res.
        v-sum42 = v-sum42 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date5.dayrep,b-t-date4.dayrep,output v-res,output v-resv).
        v-sum31 = v-sum31 + v-res.
        v-sum32 = v-sum32 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date6.dayrep,b-t-date5.dayrep,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date6.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 8 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        find first b-t-date2 where b-t-date2.num = month(dt) - 2 no-lock no-error.
        find first b-t-date3 where b-t-date3.num = month(dt) - 3 no-lock no-error.
        find first b-t-date4 where b-t-date4.num = month(dt) - 4 no-lock no-error.
        find first b-t-date5 where b-t-date5.num = month(dt) - 5 no-lock no-error.
        find first b-t-date6 where b-t-date6.num = month(dt) - 6 no-lock no-error.
        find first b-t-date7 where b-t-date7.num = month(dt) - 7 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum81 = v-sum81 + v-res.
        v-sum82 = v-sum82 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date2.dayrep,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum71 = v-sum71 + v-res.
        v-sum72 = v-sum72 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date3.dayrep,b-t-date2.dayrep,output v-res,output v-resv).
        v-sum61 = v-sum61 + v-res.
        v-sum62 = v-sum62 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date4.dayrep,b-t-date3.dayrep,output v-res,output v-resv).
        v-sum51 = v-sum51 + v-res.
        v-sum52 = v-sum52 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date5.dayrep,b-t-date4.dayrep,output v-res,output v-resv).
        v-sum41 = v-sum41 + v-res.
        v-sum42 = v-sum42 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date6.dayrep,b-t-date5.dayrep,output v-res,output v-resv).
        v-sum31 = v-sum31 + v-res.
        v-sum32 = v-sum32 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date7.dayrep,b-t-date6.dayrep,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date7.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 9 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        find first b-t-date2 where b-t-date2.num = month(dt) - 2 no-lock no-error.
        find first b-t-date3 where b-t-date3.num = month(dt) - 3 no-lock no-error.
        find first b-t-date4 where b-t-date4.num = month(dt) - 4 no-lock no-error.
        find first b-t-date5 where b-t-date5.num = month(dt) - 5 no-lock no-error.
        find first b-t-date6 where b-t-date6.num = month(dt) - 6 no-lock no-error.
        find first b-t-date7 where b-t-date7.num = month(dt) - 7 no-lock no-error.
        find first b-t-date8 where b-t-date8.num = month(dt) - 8 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum91 = v-sum91 + v-res.
        v-sum92 = v-sum92 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date2.dayrep,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum81 = v-sum81 + v-res.
        v-sum82 = v-sum82 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date3.dayrep,b-t-date2.dayrep,output v-res,output v-resv).
        v-sum71 = v-sum71 + v-res.
        v-sum72 = v-sum72 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date4.dayrep,b-t-date3.dayrep,output v-res,output v-resv).
        v-sum61 = v-sum61 + v-res.
        v-sum62 = v-sum62 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date5.dayrep,b-t-date4.dayrep,output v-res,output v-resv).
        v-sum51 = v-sum51 + v-res.
        v-sum52 = v-sum52 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date6.dayrep,b-t-date5.dayrep,output v-res,output v-resv).
        v-sum41 = v-sum41 + v-res.
        v-sum42 = v-sum42 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date7.dayrep,b-t-date6.dayrep,output v-res,output v-resv).
        v-sum31 = v-sum31 + v-res.
        v-sum32 = v-sum32 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date8.dayrep,b-t-date7.dayrep,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date8.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 10 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        find first b-t-date2 where b-t-date2.num = month(dt) - 2 no-lock no-error.
        find first b-t-date3 where b-t-date3.num = month(dt) - 3 no-lock no-error.
        find first b-t-date4 where b-t-date4.num = month(dt) - 4 no-lock no-error.
        find first b-t-date5 where b-t-date5.num = month(dt) - 5 no-lock no-error.
        find first b-t-date6 where b-t-date6.num = month(dt) - 6 no-lock no-error.
        find first b-t-date7 where b-t-date7.num = month(dt) - 7 no-lock no-error.
        find first b-t-date8 where b-t-date8.num = month(dt) - 8 no-lock no-error.
        find first b-t-date9 where b-t-date9.num = month(dt) - 9 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum101 = v-sum101 + v-res.
        v-sum102 = v-sum102 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date2.dayrep,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum91 = v-sum91 + v-res.
        v-sum92 = v-sum92 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date3.dayrep,b-t-date2.dayrep,output v-res,output v-resv).
        v-sum81 = v-sum81 + v-res.
        v-sum82 = v-sum82 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date4.dayrep,b-t-date3.dayrep,output v-res,output v-resv).
        v-sum71 = v-sum71 + v-res.
        v-sum72 = v-sum72 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date5.dayrep,b-t-date4.dayrep,output v-res,output v-resv).
        v-sum61 = v-sum61 + v-res.
        v-sum62 = v-sum62 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date6.dayrep,b-t-date5.dayrep,output v-res,output v-resv).
        v-sum51 = v-sum51 + v-res.
        v-sum52 = v-sum52 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date7.dayrep,b-t-date6.dayrep,output v-res,output v-resv).
        v-sum41 = v-sum41 + v-res.
        v-sum42 = v-sum42 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date8.dayrep,b-t-date7.dayrep,output v-res,output v-resv).
        v-sum31 = v-sum31 + v-res.
        v-sum32 = v-sum32 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date9.dayrep,b-t-date8.dayrep,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date9.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 11 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        find first b-t-date2 where b-t-date2.num = month(dt) - 2 no-lock no-error.
        find first b-t-date3 where b-t-date3.num = month(dt) - 3 no-lock no-error.
        find first b-t-date4 where b-t-date4.num = month(dt) - 4 no-lock no-error.
        find first b-t-date5 where b-t-date5.num = month(dt) - 5 no-lock no-error.
        find first b-t-date6 where b-t-date6.num = month(dt) - 6 no-lock no-error.
        find first b-t-date7 where b-t-date7.num = month(dt) - 7 no-lock no-error.
        find first b-t-date8 where b-t-date8.num = month(dt) - 8 no-lock no-error.
        find first b-t-date9 where b-t-date9.num = month(dt) - 9 no-lock no-error.
        find first b-t-date10 where b-t-date10.num = month(dt) - 10 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum111 = v-sum111 + v-res.
        v-sum112 = v-sum112 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date2.dayrep,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum101 = v-sum101 + v-res.
        v-sum102 = v-sum102 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date3.dayrep,b-t-date2.dayrep,output v-res,output v-resv).
        v-sum91 = v-sum91 + v-res.
        v-sum92 = v-sum92 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date4.dayrep,b-t-date3.dayrep,output v-res,output v-resv).
        v-sum81 = v-sum81 + v-res.
        v-sum82 = v-sum82 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date5.dayrep,b-t-date4.dayrep,output v-res,output v-resv).
        v-sum71 = v-sum71 + v-res.
        v-sum72 = v-sum72 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date6.dayrep,b-t-date5.dayrep,output v-res,output v-resv).
        v-sum61 = v-sum61 + v-res.
        v-sum62 = v-sum62 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date7.dayrep,b-t-date6.dayrep,output v-res,output v-resv).
        v-sum51 = v-sum51 + v-res.
        v-sum52 = v-sum52 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date8.dayrep,b-t-date7.dayrep,output v-res,output v-resv).
        v-sum41 = v-sum41 + v-res.
        v-sum42 = v-sum42 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date9.dayrep,b-t-date8.dayrep,output v-res,output v-resv).
        v-sum31 = v-sum31 + v-res.
        v-sum32 = v-sum32 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date10.dayrep,b-t-date9.dayrep,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date10.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
    else if month(dt) = 12 then do:
        find first b-t-date1 where b-t-date1.num = month(dt) - 1 no-lock no-error.
        find first b-t-date2 where b-t-date2.num = month(dt) - 2 no-lock no-error.
        find first b-t-date3 where b-t-date3.num = month(dt) - 3 no-lock no-error.
        find first b-t-date4 where b-t-date4.num = month(dt) - 4 no-lock no-error.
        find first b-t-date5 where b-t-date5.num = month(dt) - 5 no-lock no-error.
        find first b-t-date6 where b-t-date6.num = month(dt) - 6 no-lock no-error.
        find first b-t-date7 where b-t-date7.num = month(dt) - 7 no-lock no-error.
        find first b-t-date8 where b-t-date8.num = month(dt) - 8 no-lock no-error.
        find first b-t-date9 where b-t-date9.num = month(dt) - 9 no-lock no-error.
        find first b-t-date10 where b-t-date10.num = month(dt) - 10 no-lock no-error.
        find first b-t-date11 where b-t-date11.num = month(dt) - 11 no-lock no-error.
        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date1.dayrep,dt,output v-res,output v-resv).
        v-sum121 = v-sum121 + v-res.
        v-sum122 = v-sum122 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date2.dayrep,b-t-date1.dayrep,output v-res,output v-resv).
        v-sum111 = v-sum111 + v-res.
        v-sum112 = v-sum112 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date3.dayrep,b-t-date2.dayrep,output v-res,output v-resv).
        v-sum101 = v-sum101 + v-res.
        v-sum102 = v-sum102 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date4.dayrep,b-t-date3.dayrep,output v-res,output v-resv).
        v-sum91 = v-sum91 + v-res.
        v-sum92 = v-sum92 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date5.dayrep,b-t-date4.dayrep,output v-res,output v-resv).
        v-sum81 = v-sum81 + v-res.
        v-sum82 = v-sum82 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date6.dayrep,b-t-date5.dayrep,output v-res,output v-resv).
        v-sum71 = v-sum71 + v-res.
        v-sum72 = v-sum72 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date7.dayrep,b-t-date6.dayrep,output v-res,output v-resv).
        v-sum61 = v-sum61 + v-res.
        v-sum62 = v-sum62 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date8.dayrep,b-t-date7.dayrep,output v-res,output v-resv).
        v-sum51 = v-sum51 + v-res.
        v-sum52 = v-sum52 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date9.dayrep,b-t-date8.dayrep,output v-res,output v-resv).
        v-sum41 = v-sum41 + v-res.
        v-sum42 = v-sum42 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date10.dayrep,b-t-date9.dayrep,output v-res,output v-resv).
        v-sum31 = v-sum31 + v-res.
        v-sum32 = v-sum32 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,b-t-date11.dayrep,b-t-date10.dayrep,output v-res,output v-resv).
        v-sum21 = v-sum21 + v-res.
        v-sum22 = v-sum22 + v-resv.

        assign v-res = 0 v-resv = 0.
        run getGLBEGINSYEAR(ch.gl,?,b-t-date11.dayrep,output v-res,output v-resv).
        v-sum11 = v-sum11 + v-res.
        v-sum12 = v-sum12 + v-resv.
    end.
end procedure.




