/* kcd.p
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

display "Gaidiet ..." with frame aa row 10 no-label centered.
pause 0.
hide frame aa.
run KCd.
pause 0.
.94
*/

{global.i}
def stream m-out.
def var m-ind as int.
def var m-srok as int.
def var m-sum like glbal.bal.
def var i as int.
def var dame as char.
def var m-ext as char.
def var v-trloangl as char.
def var v-loncat like loncat.loncat.
def var v-okey as log.
def var m-geo as int.

def new shared stream m-err.
def new shared var m-aaa like aaa.aaa.
def new shared var v-row as int.
def new shared var v-col as int.
def new shared var v-rowp as int.
def new shared var v-colp as int.

def var v-kod as int.

def new shared var m-okey as log.
def new shared var m-hs like crchs.hs.
def new shared var m-hslat like crchs.hs .
def new shared var v-gltd as char.
def var v-row0 as int format "999".
def var v-col0 as int format "9".

def var dames as date.


{kcd.f}

m-hslat = "S".
v-gltd = "".

def var v-len as int initial 18.
def var v-poz as int extent 18 initial
[ 403, 403, 403, 404, 404, 404, 1301, 1301, 1301, 1302, 1302, 1302,
1303, 1303, 1303, 1304, 1304, 1304 ].

def var v-stabs as int extent 18 initial [1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3].

def temp-table kredcet
    field kods like loncat.loncat
    field  sumk as dec extent 7 initial 0.

output stream m-err to KredCetur.err.
output stream m-out to KredCetur.txt.

    view stream m-out frame hfnbd.
    put stream m-out v-mess1 v-row0 v-mess2 v-col0 skip
    fill("-",132) format "x(132)" skip.

find sysc where sysc.sysc = "GLDATE" no-lock no-error.
dame = string(day(sysc.daval),"99") + string(month(sysc.daval),"99").
find sysc where sysc.sysc = "BILEXT" no-lock no-error.
if available sysc then m-ext = "." + trim(sysc.chval). else m-ext = ".".

find sysc where sysc.sysc = "TRLNGL" no-lock no-error.
if available sysc then v-trloangl = trim(sysc.chval). else v-trloangl = "".


for each loncat where loncat.loncat >= 101 and loncat.loncat < 200 no-lock:
    create kredcet.
    kredcet.kods = loncat.loncat.
end.


i = 0.


for each lon where lon.loncat eq v-row0 no-lock break by crc:
    m-sum = lon.dam[1] - lon.cam[1].
    v-okey = no.
    if m-sum <> 0 then do:
       find first ln%his where ln%his.lon = lon.lon and ln%his.opnamt > 0
            and ln%his.rdt <> ? and ln%his.duedt <> ? no-lock no-error.
       if not available ln%his
       then next.
        m-srok = ln%his.duedt - ln%his.rdt.
        /* find loncnt where loncnt.lon = lon.lon no-lock no-error.
           if available loncnt then do:
              find lcnt where lcnt.lcnt = loncnt.lcnt no-lock no-error.
              if available lcnt then m-srok = lcnt.duedt - lcnt.rdt.
           end. */
        find crc where crc.crc = lon.crc no-lock no-error.
        if available crc then do:
            find gl where gl.gl eq lon.gl no-lock no-error.
            find cif  where lon.cif = cif.cif no-lock no-error.
            if available cif then do:
                m-geo = integer(cif.geo).
                run newbl1d
                (gl.gl,gl.type,crc.crc,crc.code,m-geo,cif.cgr,lon.loncat,
                m-sum,m-srok).
                repeat m-ind = 1 to v-len :
                    if v-row eq v-poz[m-ind] and v-col eq v-stabs[m-ind] then
                        v-okey = yes.
                end.
            end.

            m-ind = 0.
            if v-okey then do:
                find crchs where crchs.crc = crc.crc no-lock no-error.
                if available crchs then do:
                    if v-trloangl matches ( "*" + string(lon.gl,"999999") + "*")
                    then m-ind = 7.
                    else do:
                        if crchs.hs = "L" then m-ind = 1.
                        if crchs.hs = "H" then m-ind = 3.
                        if crchs.hs = "S" then m-ind = 5.
                        if m-srok > 366 then m-ind = m-ind + 1.
                    end.
                    if m-ind eq v-col0 then do :
                    find loncon where loncon.lon eq lon.lon no-lock no-error.

        put stream m-out
        loncon.lcnt
        " " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(40)"
        " "
        lon.lon " " lon.cif "     "
        crc.code " "
        lon.gl " "
        m-sum format ">>>,>>>,>>>,>>>,>>9.99-" " "
        m-sum * crc.rate[1] / crc.rate[9]
        format ">>>,>>>,>>>,>>>,>>9.99-" skip.
                                                      /*
                        put stream m-out lon.lon " " lon.gl " " crc.code " "
                        m-sum
                        format ">>>,>>>,>>>,>>9.99-" " "
                        m-sum * crc.rate[1] / crc.rate[9]
                        format ">>>,>>>,>>>,>>9.99-" skip
                        .
                        */
                    end.
                    find first kredcet where kredcet.kods = lon.loncat.
                    sumk[m-ind] = sumk[m-ind] +
                    m-sum * crc.rate[1] / crc.rate[9].
                end.
                else put stream m-err "Not found crchs for crc " crc.code skip.
            end.

        end.
        else put stream m-err "Not found crc for lon " lon.lon skip.
    end.
    i = i + 1.
    display  "LON " i with frame l no-label row 10 centered.
    pause 0.
end.
hide frame l.

/* oda */

i = 0.

for each lgr where lgr.led = "oda" no-lock :

for each aaa where aaa.lgr = lgr.lgr no-lock :

    m-sum = aaa.dr[1] - aaa.cr[1].
    if m-sum <> 0 then do:
        v-loncat = 0.
        find cif where cif.cif = aaa.cif no-lock no-error.
        if available cif
        then do:
             find first lon where lon.lcr = aaa.aaa and lon.gua = "OD"
                  no-lock no-error.
             if available lon
             then v-loncat = lon.loncat.
        end.
        if v-loncat eq v-row0 then do:

        find crc where crc.crc = aaa.crc no-lock no-error.
        if available crc then do:
            find gl where gl.gl eq aaa.gl no-lock no-error.
            m-geo = integer(cif.geo).
            run newbld
            (gl.gl,gl.type,crc.crc,crc.code,m-geo,cif.cgr,m-sum,m-srok).
            repeat m-ind = 1 to v-len :
                if v-row eq v-poz[m-ind] and v-col eq v-stabs[m-ind] then
                v-okey = yes.
            end.
            if v-okey then do:

            find crchs where crchs.crc = crc.crc no-lock no-error.
            if available crchs then do:
                if v-trloangl matches ( "*" + string(aaa.gl,"999999") + "*")
                then m-ind = 7.
                else do:
                    if crchs.hs = "L" then m-ind = 1.
                    if crchs.hs = "H" then m-ind = 3.
                    if crchs.hs = "S" then m-ind = 5.
                end.
                if v-col0 eq m-ind then do :
                        put stream m-out
                        "           " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(40)" " "
                        aaa.aaa " " aaa.gl " " crc.code " "
                        m-sum
                        format ">>>,>>>,>>>,>>9.99-" " "
                        m-sum * crc.rate[1] / crc.rate[9]
                        format ">>>,>>>,>>>,>>9.99-" skip
                        .
                end.
                find first kredcet where kredcet.kods = v-loncat.
                sumk[m-ind] = sumk[m-ind] + m-sum * crc.rate[1] / crc.rate[9].

            end.
            else put stream m-err "Not found crchs for crc " crc.code skip.
            end.
        end.
        else put stream m-err "Not found crc for aaa " aaa.aaa skip.
        end.

    end.
end.
    i = i + 1.
    display  "ODA " i with frame l1 no-label row 10 centered.
    pause 0.
end.
hide frame l1.




for each kredcet where kredcet.kods eq v-row0:
        put stream m-out fill("-",132) format "x(132)" skip
        v-mess3 sumk[v-col0] at 112
        format ">,>>>,>>>,>>>,>>9.99-"  skip.
        i = i + 1.
    end.

output stream m-err close.
output stream m-out close.


{image1.i rpt.img}.


if v-col0 gt 0 and v-row0 gt 0 then
unix silent value(dest) KredCetur.txt.
pause 0.

return.
/*------------------------------------------------------------------------------
  #3.
     1.izmai‡a - kredЁta ilgums tiek fiksёts no s–kotnёj– termi‡a,t.i. izmai‡as
       neiek ‡emtas vёr–
     2.izmai‡a - overdrafts nozarei tiek piesaistЁts caur kredЁtu nevis CIF
------------------------------------------------------------------------------*/
