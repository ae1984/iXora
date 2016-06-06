/* ratios-1.p
 * MODULE

 * DESCRIPTION
        Сверка текущего счета клиента и платежей ВК
 * RUN
        3-4-5-11
 * CALLER
        ratios.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        10.04.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        27.02.2013 damir - Внедрено Т.З. № 1607.
*/
{global.i}
def input parameter v-dt as date.

def var v-bank as char.


find cmp no-lock no-error.
v-bank = cmp.name.

define new shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .
define shared temp-table tgl1
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .
define shared variable v-gldate as date.
def shared var v-gl1 as int no-undo.
def shared var v-gl2 as int no-undo.
def shared var v-gl-cl as int no-undo.
def var RepName as char.
def var RepPath as char init "/data/reports/array/".

v-gldate = v-dt.
/*v-gl1 = 110000.
v-gl2 = 250000.*/
function FileExist returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("cat " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.

RepName = "array" + string(v-gl1) + string(v-gl2) + string(v-gl-cl) + replace(string(v-gldate,"99/99/9999"),"/","-") + ".rep".
if not FileExist(RepPath + RepName) then do:
 run array-create.
end.


procedure ImportData:
    empty temp-table tgl.
    INPUT FROM value(RepPath + RepName) NO-ECHO.
    LOOP:
    REPEAT TRANSACTION:
        REPEAT ON ENDKEY UNDO, LEAVE LOOP:
            CREATE tgl.
            IMPORT
            tgl.txb
            tgl.gl
            tgl.gl4
            tgl.gl7
            tgl.gl-des
            tgl.crc
            tgl.sum
            tgl.sum-val
            tgl.type
            tgl.sub-type
            tgl.totlev
            tgl.totgl
            tgl.level
            tgl.code
            tgl.grp
            tgl.acc
            tgl.acc-des
            tgl.geo
            tgl.odt
            tgl.cdt
            tgl.perc
            tgl.prod.
        END. /*REPEAT*/
    END. /*TRANSACTION*/
    input close.
end procedure.
run ImportData.

for each tgl no-lock:
    create tgl1.
    tgl1.txb = tgl.txb.
    tgl1.gl = tgl.gl.
    tgl1.gl4 = tgl.gl4.
    tgl1.gl7 = tgl.gl7.
    tgl1.gl-des = tgl.gl-des.
    tgl1.crc = tgl.crc.
    tgl1.sum = tgl.sum.
    tgl1.sum-val = tgl.sum-val.
    tgl1.type = tgl.type.
    tgl1.sub-type = tgl.sub-type.
    tgl1.totlev = tgl.totlev.
    tgl1.totgl = tgl.totgl.
    tgl1.level = tgl.level.
    tgl1.code = tgl.code.
    tgl1.grp = tgl.grp.
    tgl1.acc = tgl.acc.
    tgl1.acc-des = tgl.acc-des.
    tgl1.geo = tgl.geo.
    tgl1.odt = tgl.odt.
    tgl1.cdt= tgl.cdt.
    tgl1.perc = tgl.perc.
    tgl1.prod = tgl.prod.
end.