/* dclsgarcom.p
 * MODULE
        Закрытие операционного дня
 * DESCRIPTION
        Амортизация комиссии по гарантиям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        dayclose.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        06/12/2011 id00810
 * BASES
        BANK
 * CHANGES
        29/12/2011 id00810 - добавлена проверка на наличие проводки по выдаче гарантии,
                             уточнен алгоритм определения счета доходов
        02/09/2013 galina - ТЗ 1918 забираем комиссию в доходы с 30 уровня счета гарантии
*/

{global.i}
define shared var s-target as date.

def var v-comsum as deci no-undo.
def var v-dto    as date no-undo.
def var v-jh     like jh.jh no-undo.
def var v-gl     as char no-undo.
def var v-comacc as char no-undo.
def var v-crc    like crc.crc no-undo.
def var v-rem    as char no-undo.
def var v-param  as char no-undo.
def var vdel     as char no-undo initial "^".
def var rcode    as int  no-undo.
def var rdes     as char no-undo.
def var v-trx    as char no-undo.
def var v-rez    as char no-undo init '1'.
def var v-sect   as char no-undo init '4'.
def var v-knp    as char no-undo init '182'.
def var v-amt    as deci no-undo.
def buffer b-garan for garan.

for each garan no-lock:
    if deci(garan.info[3]) = 0 then next.
    if garan.jh = 0 then next.
    find first aaa where aaa.aaa = garan.garan no-lock no-error.
    if not avail aaa then next.
    if aaa.sta = 'C' then next.




    assign v-dto    = garan.dtto
           v-comsum = deci(garan.info[3])
           v-comacc = garan.aaa3
           v-crc    = garan.crc2
           v-gl     = if lookup(trim(garan.obesp),'3,5') > 0 then '460610' else '460620'
           v-comsum = if s-target < v-dto then round((v-comsum / (v-dto - g-today)) * (s-target - g-today), 2) else v-comsum
           v-rem = 'Доходы по амортизации комиссионного вознаграждения за выпуск гарантии по договору № ' + trim(garan.garnum)  + ' от ' + string(garan.dtfrom).

    v-amt = 0.
    find first trxbal where trxbal.subled = 'CIF' and trxbal.acc = aaa.aaa and trxbal.level = 30 and trxbal.crc = v-crc no-lock no-error.
    if avail trxbal then do:
      find first trxlevgl where trxlevgl.gl = aaa.gl and trxlevgl.level = 30 no-lock no-error.
      if avail trxlevgl then do:
          find gl where gl.gl  = trxlevgl.glr no-lock no-error.
          if avail gl and (gl.type eq "A" or gl.type eq "E") then v-amt = trxbal.dam - trxbal.cam.
          else v-amt = trxbal.cam - trxbal.dam.
      end.
    end.
    if v-amt = 0 then do:

        if v-crc > 1
        then assign v-param = string(v-comsum) + vdel + string(v-crc) + vdel + '286920' + vdel + v-rem + vdel + v-rez + vdel + v-rez + vdel + v-sect + vdel + v-sect + vdel + v-knp + vdel + '1' + vdel + v-gl
                    v-trx = 'uni0022'.
        else assign v-param = string(v-comsum) + vdel + string(v-crc) + vdel + '286920' + vdel + v-gl + vdel + v-rem
                    v-trx = 'uni0144'.
   end.
   else do:
        v-param = string(v-comsum) + vdel + string(v-crc) + vdel + '30' + vdel + aaa.aaa + vdel + v-gl + vdel +  v-rem .
        v-trx = 'CIF0019'.
   end.
     v-jh = 0.
    run trxgen (v-trx, vdel, v-param, "cif" , v-comacc , output rcode, output rdes, input-output v-jh).

    if rcode ne 0 then run savelog("garcom", "ERROR " + garan.cif + " " + garan.garan + " " + rdes + " " + v-trx).


    else if v-jh > 0 then do:
        find first b-garan where b-garan.garan = garan.garan exclusive-lock no-error.
        if avail b-garan then b-garan.info[3] = string(deci(b-garan.info[3]) - v-comsum).
        find current b-garan no-lock no-error.
        run savelog("garcom", "OK " + garan.cif + " " + garan.garan + " " + string(v-jh) ).

    end.
end.
