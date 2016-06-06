/* dclsgarpog.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Ежемесячное удержание комиссии по гарнтии со счета клента
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
        02/09/2013 galina
 * BASES
        BANK
 * CHANGES
*/

{global.i}

function get_amt returns deci (p-acc as char, p-gl as integer, p-lev as integer, p-dt as date, p-sub as char, p-crc as integer).
  def var v-amt as deci.
    find first trxbal where trxbal.subled = p-sub and trxbal.acc = p-acc and trxbal.level = p-lev and trxbal.crc = p-crc no-lock no-error.
    if avail trxbal then do:
      find first trxlevgl where trxlevgl.gl = p-gl and trxlevgl.level = p-lev no-lock no-error.
      if avail trxlevgl then do:
          find gl where gl.gl  = trxlevgl.glr no-lock no-error.

          if avail gl then do:
             if gl.type eq "A" or gl.type eq "E" then v-amt = trxbal.dam - trxbal.cam.
             else v-amt = trxbal.cam - trxbal.dam.
          end.
      end.
    end.
    else /*message "Информация об остатках на счете " + p-acc + " отсутствуе"  view-as alert-box title "Внимание"*/ v-amt = 0.

  return v-amt.
end.

def var v-jh like jh.jh no-undo.
def var v-compros as deci no-undo.
def var v-comsum as deci no-undo.
def var dat_wrk as date no-undo.
def var rcode as inte no-undo.
def var rdes as char no-undo.
def var rem1 as char no-undo.
def var rem2 as char no-undo.
def var rem3 as char no-undo.
def var vparam as char no-undo.
def var vdel as char initial "^".
def var v-acc as char no-undo.
def var v-trx as char no-undo.
def var v-availamt as deci no-undo.
def var vbal like jl.dam no-undo.
def var vavl like jl.dam no-undo.
def var vhbal like jl.dam no-undo.
def var vfbal like jl.dam no-undo.
def var vcrline like jl.dam no-undo.
def var vcrlused like jl.dam no-undo.
def var vooo like aaa.aaa no-undo.

define shared var s-target as date.




for each garan no-lock:
   if garan.aaa3 = '' then next.
   find first aaa where aaa.aaa = garan.aaa3 no-lock no-error.
   if not avail aaa then next.
   if aaa.sta = 'C' then next.
   else v-acc = garan.aaa3.


   find first aaa where aaa.aaa = garan.garan no-lock no-error.
   if not avail aaa then next.
   if aaa.sta = 'C' then next.
   if get_amt(garan.garan,aaa.gl,7,g-today, "cif", garan.crc) = 0 then next.

   if get_amt(garan.garan,aaa.gl,29,g-today, "cif", garan.crc) = 0 then next.

   v-comsum = 0.
   find last garancomgraf where garancomgraf.garan = garan.garan and garancomgraf.dtcom >= g-today and garancomgraf.dtcom < s-target  no-lock no-error.
   if not avail garancomgraf then next.
   else v-comsum = garancomgraf.comsum.

   if v-comsum > get_amt(garan.garan,aaa.gl,29,g-today, "cif", garan.crc) then v-comsum = get_amt(garan.garan,aaa.gl,29,g-today, "cif", garan.crc).
   v-compros = 0.
   v-compros = get_amt(garan.garan,aaa.gl,31,g-today, "cif", garan.crc).
   run aaa-bal777(v-acc, output vbal, output vavl, output vhbal, output vfbal, output vcrline, output vcrlused, output vooo).

   rem1 = ''.
   rem2 = ''.
   rem3 = ''.
   vparam = ''.
   if vavl <= 0 then do:
       rem1 = 'Перенос комиссии на счет просроченной задолженности по гарантии № ' + garan.garnum + ' от ' + string(garan.dtfrom,'99/99/9999') + 'г.'.
       rem2 = 'Оплата просроченной комиссии по гарантии № ' + garan.garnum + ' от ' + string(garan.dtfrom,'99/99/9999') + 'г.'.
       vparam = string(v-comsum) + vdel + string(garan.crc) + vdel + '31' + vdel + garan.garan + vdel + '29' + vdel + garan.garan + vdel + rem1
                + vdel + string(0) + vdel + string(garan.crc) + vdel + '1' + vdel + v-acc + vdel + '29' + vdel + garan.garan + vdel + rem2
                + vdel + string(0) + vdel + string(garan.crc) + vdel + '1' + vdel + v-acc + vdel + '29' + vdel + garan.garan + vdel + rem3.
   end.
   else do:
       if v-compros > vavl then do:
           rem1 = 'Оплата просроченной комиссии по гарантии № ' + garan.garnum + ' от ' + string(garan.dtfrom,'99/99/9999') + 'г.'.
           rem2 = 'Перенос комиссии на счет просроченной задолженности по гарантии № ' + garan.garnum + ' от ' + string(garan.dtfrom,'99/99/9999') + 'г.'.
           vparam = string(vavl) + vdel + string(garan.crc) + vdel + '1' + vdel + v-acc + vdel + '31' + vdel + garan.garan + vdel + rem1
                    + vdel + string(v-comsum) + vdel + string(garan.crc) + vdel + '29' + vdel + garan.garan + vdel + '31' + vdel + garan.garan + vdel + rem2
                    + vdel + string(0) + vdel + string(garan.crc) + vdel + '1' + vdel + v-acc + vdel + '29' + vdel + garan.garan + vdel + rem3.
       end.
       else do:
           if vavl - v-compros >= v-comsum then do:
               rem1 = 'Оплата просроченной комиссии по гарантии № ' + garan.garnum + ' от ' + string(garan.dtfrom,'99/99/9999') + 'г.'.
               rem2 = 'Оплата комиссии по гарантии № ' + garan.garnum + ' от ' + string(garan.dtfrom,'99/99/9999') + 'г.'.
               vparam = string(v-compros) + vdel + string(garan.crc) + vdel + '1' + vdel + v-acc + vdel + '31' + vdel + garan.garan + vdel + rem1
                        + vdel + string(v-comsum) + vdel + string(garan.crc) + vdel + '1' + vdel + v-acc + vdel + '29' + vdel + garan.garan + vdel + rem2
                        + vdel + string(0) + vdel + string(garan.crc) + vdel + '1' + vdel + v-acc + vdel + '29' + vdel + garan.garan + vdel + rem3.
           end.
           else do:
               rem1 = 'Оплата просроченной комиссии по гарантии № ' + garan.garnum + ' от ' + string(garan.dtfrom,'99/99/9999') + 'г.'.
               rem2 = 'Оплата комиссии по гарантии № ' + garan.garnum + ' от ' + string(garan.dtfrom,'99/99/9999') + 'г.'.
               rem3 = 'Перенос комиссии на счет просроченной задолженности по гарантии № ' + garan.garnum + ' от ' + string(garan.dtfrom,'99/99/9999') + 'г.'.
               vparam = string(v-compros) + vdel + string(garan.crc) + vdel + '1' + vdel + v-acc + vdel + '31' + vdel + garan.garan + vdel + rem1
                        + vdel + string(vavl - v-compros) + vdel + string(garan.crc) + vdel + '1' + vdel + v-acc + vdel + '29' + vdel + garan.garan + vdel + rem2
                        + vdel + string(v-comsum - (vavl - v-compros)) + vdel + string(garan.crc) + vdel + '31' + vdel + garan.garan + vdel + '29' + vdel + garan.garan + vdel + rem3.
           end.
       end.
   end.
   v-jh = 0.
   rcode = 0.
   v-trx = 'CIF0029'.
   run trxgen (v-trx, vdel, vparam, "CIF", garan.garan, output rcode, output rdes, input-output v-jh).

   if rcode ne 0 then run savelog("dclsgarpog", "ERROR " + garan.cif + " " + garan.garan + " " + rdes + " " + v-trx).

   else run savelog("dclsgarpog", "OK " + garan.cif + " " + garan.garan + " " + string(v-jh) ).
end.

