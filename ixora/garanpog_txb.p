/* garanpog_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Гарантии, по которым настал срок погашения
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
        02/09/2013 galina ТЗ 1918
 * BASES
        BANK TXB
 * CHANGES
*/
define {1} shared var g-today  as date.
def var v-amt as deci no-undo.
def var v-days as int no-undo.
def input parameter p-filial as char.

def shared temp-table t-garanpros
     field filial    as char
     field aaa       like  txb.aaa.aaa
     field regdt     like  txb.aaa.regdt
     field expdt     like  txb.aaa.expdt
     field srok      like  txb.aaa.expdt
     field vid       as    character  format 'x(10)'
     field cif       like  txb.cif.cif
     field name      like  txb.cif.sname
     field crc       like  txb.crc.code
     field ost       like  txb.jl.dam     init 0
     index main is primary filial cif.


for each txb.garan where txb.garan.dtto < g-today no-lock:
    find first txb.cif where txb.cif.cif = txb.garan.cif no-lock no-error.
    if not avail txb.cif then next.

    find first txb.aaa where txb.aaa.aaa = txb.garan.garan no-lock no-error.
    if not avail txb.aaa then next.
    if txb.aaa.sta = 'C' then next.


    v-amt = 0.
    find first txb.trxbal where txb.trxbal.subled = 'CIF' and txb.trxbal.acc = txb.aaa.aaa and txb.trxbal.level = 7 and txb.trxbal.crc = txb.garan.crc no-lock no-error.
    if avail txb.trxbal then do:
      find first txb.trxlevgl where txb.trxlevgl.gl = txb.aaa.gl and txb.trxlevgl.level = 7 no-lock no-error.
      if avail txb.trxlevgl then do:
          find txb.gl where txb.gl.gl  = txb.trxlevgl.glr no-lock no-error.
          if avail txb.gl and (txb.gl.type eq "A" or gl.type eq "E") then v-amt = txb.trxbal.dam - txb.trxbal.cam.
          else v-amt = txb.trxbal.cam - txb.trxbal.dam.
      end.
    end.
    if v-amt = 0 then next.
    find first txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.

    if trim(txb.garan.obesp) = '3' then v-days = 5.
    else v-days = 30.
    if txb.garan.dtto + v-days >= g-today then next.
    create t-garanpros.
    assign t-garanpros.filial = p-filial
           t-garanpros.aaa = txb.garan.garan
           t-garanpros.regdt = txb.garan.dtfrom
           t-garanpros.expdt = txb.garan.dtto
           t-garanpros.srok = txb.garan.dtto + v-days
           t-garanpros.cif = txb.garan.cif
           t-garanpros.name = if avail txb.cif then trim(trim(txb.cif.prefix) + " " + trim(txb.cif.sname)) else ''
           t-garanpros.crc = if avail txb.crc then trim(txb.crc.code) else ''
           t-garanpros.ost = v-amt.
    find txb.trxlevgl where txb.trxlevgl.gl = txb.aaa.gl and txb.trxlevgl.subled  =  'cif' and txb.trxlevgl.level = 7 no-lock no-error.
    if avail txb.trxlevgl then do:
        if txb.trxlevgl.glr = 605530 then  t-garanpros.vid = 'депозит'.
        else if txb.trxlevgl.glr = 605540 then t-garanpros.vid = 'др.залог'.
        else  t-garanpros.vid = 'н/обесп.'.
    end.
end.






