/* s-fakturis0.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        создание счетов-фактур
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        31/12/99 pragma
 * CHANGES
        01.08.2003 nadejda - оптимизация циклов
        01.01.2004 nadejda - изменила ставку НДС - брать из sysc
        07.11.09 marinav - изменила алгоритм - теперь берем по всем проводкам и смотрим признак ГК с НДС
        12.10.2013 dmitriy - ТЗ 1526. Включение счетов-фактур по комиссиям за ЭЦП в реестр по реализации
*/



define shared variable g-today as date.

output to fakturset.txt append.

define variable v-cif like cif.cif.

define buffer b-jl for jl.

def var v-nds% as decimal.

find sysc where sysc = "nds" no-lock no-error.
if avail sysc then v-nds% = sysc.deval.


for each b-jl where b-jl.jdt = g-today and b-jl.dc = "D" no-lock use-index jdtdcgl :



  find jh where jh.jh = b-jl.jh no-lock no-error.
  if not avail jh or index(jh.party, "STORNO") > 0 or index(jh.party, "CONVERS") > 0 then next.

        find first jl where jl.jh = b-jl.jh and jl.dc = "C" and  jl.cam = b-jl.dam and (string(jl.gl) begins "4" or jl.gl = 287082) no-lock no-error.

        if available jl then do:

        find first sub-cod where sub-cod.sub = "gld" and  sub-cod.acc = trim(string(jl.gl))
                            and sub-cod.d-cod = "ndcgl" and sub-cod.ccode = "01"  no-lock no-error .
        if avail sub-cod then do:

             v-cif = "".
             find gl where gl.gl = b-jl.gl no-lock.
             case gl.subled :
               when "arp"
                 then do:
                      find arp where arp.arp eq b-jl.acc no-lock no-error.
                      v-cif = arp.cif.
                 end.
               when "cif"
                 then do:
                      find aaa where aaa.aaa eq b-jl.acc no-lock no-error.
                      v-cif = aaa.cif.
                 end.
               when "lon"
                 then do:
                      find lon where lon.lon = b-jl.acc no-lock no-error.
                      v-cif = lon.cif.
                 end.
               when "ock"
                 then do:
                      find ock where ock.ock eq b-jl.acc no-lock no-error.
                      find aaa where aaa.aaa = ock.aaa no-lock no-error.
                      v-cif = aaa.cif.
                 end.
             end case.

             if gl.gl = 100100 then v-cif = '100100'.

             find last crchis where crchis.crc = b-jl.crc  and crchis.rdt <= jl.jdt   use-index crcrdt no-lock no-error.

             find first fakturis where fakturis.jh eq jl.jh and
                  fakturis.trx = jl.trx and
                  fakturis.ln eq jl.ln use-index jhtrxln exclusive-lock no-error.
             if not available fakturis
             then do:

                  create fakturis.
                  assign fakturis.jdt     = jl.jdt
                         fakturis.jh      = jl.jh
                         fakturis.trx     = jl.trx
                         fakturis.ln      = jl.ln
                         fakturis.sts     = "OOO"
                         fakturis.who     = jl.who
                         fakturis.rdt     = jl.jdt
                         fakturis.tim     = time
                         fakturis.cif     = v-cif
                         fakturis.acc     = b-jl.acc
                         fakturis.amt     = crchis.rate[1] / crchis.rate[9] * (b-jl.dam + b-jl.cam).

                  fakturis.pvn     = fakturis.amt / (1 + v-nds%) * v-nds%.
                  fakturis.neto    = fakturis.amt - fakturis.pvn.
                  fakturis.order   = next-value(vptrx).
                  fakturis.faktura = 10000000 * (year(jl.jdt) modulo 100) + 100000 * month(jl.jdt) + fakturis.order.

             put unformatted jl.jdt v-cif b-jl.acc jl.jh jl.gl jl.dam jl.cam skip.
             end.
        end.
        end.
end.


output close.