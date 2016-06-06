/* r-dfbday.p
 * MODULE
        Корреспондентские счета
 * DESCRIPTION
        Обороты по банкам за период
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        06.01.2004 nadejda - по просьбе филиалов добавила количество проводок, переделала подборку и печать данных
        23.01.2006 sasco - переделал вывод отчета по требованию Актбинска, чтобы простыня не печаталась (как в Уральске) :-)
*/

/* checked  */
/* r-dfbday.p */

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{mainhead.i}  /* REPORT DFB BAL & TRX */

define var vdfb like dfb.dfb.
define var vfdt as date label "ДАТА  С ".
define var vtdt as date label " ПО ".
define var sak-dat as date.
DEFINE VARIABLE last-upd AS DATE.
DEFINE VARIABLE v-can-pro AS LOGICAL.


vdfb = "ALL".
vfdt = g-today.
vtdt = g-today.


start:
do:

{image1.i rpt.img}
  if g-batch ne true then do:
      find sysc where sysc.sysc = "begday" no-lock.
      sak-dat = sysc.daval.

      update vdfb 
             vfdt validate (vfdt >= sak-dat, "Неверная начальная или конечная дата ")
             vtdt validate (vtdt >= sak-dat, "Неверная начальная или конечная дата ")
         with 1 down centered side-label.
   end.
{image2.i}

{report1.i 63}

if seltxb > 0 then do: /* = 2 */
   output close.
   output to value(vimgfname) page-size 0 append.
end.

vtitle = "ОБОРОТЫ ПО БАНКАМ ЗА ПЕРИОД " + string(vfdt)
  + " - " + string(vtdt).

/*
if vdfb eq "ALL" then
 do:
    for each crc where crc.sts <> 9 no-lock:
       for each dfb where dfb.crc = crc.crc  break by dfb.crc by dfb.dfb:
         find trxbal where trxbal.subled = "dfb" and trxbal.acc = dfb.dfb
              and trxbal.level = 1 and trxbal.crc = dfb.crc no-lock no-error.
          IF (trxbal.pdam - trxbal.pcam > 0) or
             (dfb.dam[1] - trxbal.pdam > 0) or
             (dfb.cam[1] - trxbal.pcam > 0) or
             (dfb.dam[1] - dfb.cam[1] > 0) THEN
           do:

              {report2.i 132}
              display dfb.dfb dfb.name  skip dfb.crc
                 trxbal.pdam - trxbal.pcam format "z,zzz,zzz,zzz,zz9.99-"
                 label "НАЧАЛО ДНЯ     " (sub-total by dfb.crc)
                 dfb.dam[1] - trxbal.pdam format "z,zzz,zzz,zzz,zz9.99-"
                 label "ДНЕВНОЙ ДЕБЕТ  " (sub-total by dfb.crc)
                 dfb.cam[1] - trxbal.pcam format "z,zzz,zzz,zzz,zz9.99-"
                 label "ДНЕВНОЙ КРЕДИТ  " (sub-total by dfb.crc)
                 dfb.dam[1] - dfb.cam[1] format "z,zzz,zzz,zzz,zz9.99-"
                 label "КОНЕЦ ДНЯ      " (sub-total by dfb.crc)
                    with width 132 down frame dfbbal no-box.
            end.
        end.

    end.

   page.
 end.

*/

if seltxb <> 0 then do:

  put unformatted g-comp " "  vtoday  " " vtime  " "  "Исп."  " "  caps(g-ofc)
     " "  "стр." + string(page-number, "zzz9") format "x(10)" skip
  g-fname  " "  g-mdes skip
  vtitle skip
  fill("=",132) format "x(132)" skip.

end.

form jl.jdt jl.jh jl.dam jl.cam jl.rem[1]
   with frame jl down width 132.


if seltxb = 2 then 
do:
     {report2.i 132 " " "aa"}
end.

/* 06.01.2004 nadejda - подборка данных для печати */
def temp-table t-jl 
  field jh like jh.jh
  field jdt like jl.jdt
  field acc like jl.acc
  field dam like jl.dam
  field cam like jl.cam
  field crc like crc.crc
  field rem as char format "x(60)"
  index main is primary unique acc jdt dam cam desc jh.

def var v-cntd as integer format ">>>>>>>>>>>9".
def var v-cntc as integer format ">>>>>>>>>>>9".

for each gl where gl.subled = "DFB" no-lock:

  for each jl where jl.jdt >= vfdt and jl.jdt <= vtdt and jl.gl = gl.gl no-lock use-index jdt:
    if vdfb = "ALL" or jl.acc = vdfb then do:
      find crc where crc.crc = jl.crc no-lock no-error.
      if crc.sts <> 9 then do:
        create t-jl.
        assign t-jl.jh = jl.jh
               t-jl.jdt = jl.jdt
               t-jl.acc = jl.acc
               t-jl.crc = jl.crc
               t-jl.dam = jl.dam
               t-jl.cam = jl.cam
               t-jl.rem = jl.rem[1].
      end.
    end.
  end.
end.

form t-jl.jdt t-jl.jh t-jl.dam t-jl.cam t-jl.rem
   with frame t-jl down width 132.

/* 06.01.2004 nadejda - собственно печать */
for each t-jl use-index main break by t-jl.acc by t-jl.jdt by t-jl.dam by t-jl.cam descending:
  if seltxb /* <> 2 */ = 0 then do:
     {report2.i 132 " " "aa"}
  end.

  if first-of(t-jl.acc) then do:
      find dfb where dfb.dfb = t-jl.acc no-lock no-error.
      find crc where crc.crc = t-jl.crc no-lock no-error.

      disp "БАНК       " dfb.name /*"par" to 60 g-today at 62 */ skip
           "ВАЛЮТА     " crc.des  skip(1)
           with no-label frame dfb.

     v-cntd = 0.
     v-cntc = 0.
   end. /* first-of(jl.acc) */


  display t-jl.jdt label "Дата" t-jl.jh label "Номер пров." t-jl.dam label "Дебет"
          t-jl.cam label "Кредит" t-jl.rem label "Примечание"
     with frame t-jl.
  down 1 with frame t-jl.

  if last-of(t-jl.jdt) then
     down 2 with frame t-jl.

  accumulate t-jl.dam(sub-total sub-count by t-jl.acc) t-jl.cam(sub-total sub-count by t-jl.acc).

  if last-of(t-jl.acc) then do:
      underline t-jl.dam t-jl.cam with frame t-jl.
      down 1 with frame t-jl.
      display (accum sub-total by t-jl.acc t-jl.dam) @ t-jl.dam
         (accum sub-total by t-jl.acc t-jl.cam) @ t-jl.cam
         with frame t-jl.
      down 1 with frame t-jl.

      v-cntd = accum sub-count by t-jl.acc t-jl.dam.
      v-cntc = accum sub-count by t-jl.acc t-jl.cam.

      put v-cntd to 41 v-cntc to 63 "ИТОГО КОЛИЧЕСТВО" at 66 skip.
   end. /* last-of(jl.acc) */
end.




/* 06.01.2004 nadejda - переделала вывод см. выше
for each gl where gl.subled = "DFB" no-lock
   ,each jl where jl.gl = gl.gl
             and  jl.jdt >= vfdt
             and  jl.jdt <= vtdt
             and  (if vdfb = "ALL" then true else jl.acc = vdfb) no-lock
                  break by jl.acc by jl.jdt by jl.dam by jl.cam descending:

  find crc where crc.crc = jl.crc no-lock.
  if crc.sts <> 9 then do:

      if seltxb <> 2 then do:
         {report2.i 132 " " "aa"}
      end.

      if first-of(jl.acc) then do:
          find dfb where dfb.dfb = jl.acc no-lock no-error.

          disp "БАНК       " dfb.name "par" to 60 g-today at 62 skip
               "ВАЛЮТА     "  crc.des  skip(1)
               with no-label frame dfb.
       end. /* first-of(jl.acc) */


      display jl.jdt label "Дата" jl.jh label "Номер пров."jl.dam label "Дебет"
              jl.cam label "Кредит" jl.rem[1] label "Примечание"
         with frame jl.
      down 1 with frame jl.

      if last-of(jl.jdt) then
         down 2 with frame jl.

      accumulate jl.dam(sub-total sub-count by jl.acc) jl.cam(sub-total sub-count by jl.acc).

      if last-of(jl.acc) then do:
          underline jl.dam jl.cam with frame jl.
          down 1 with frame jl.
          display (accum sub-total by jl.acc jl.dam) @ jl.dam
             (accum sub-total by jl.acc jl.cam) @ jl.cam
             with frame jl.
          down 1 with frame jl.

          v-cntd = accum sub-count by jl.acc jl.dam.
          v-cntc = accum sub-count by jl.acc jl.cam

          put v-cntd to 41 v-cntc to 63 skip.
       end. /* last-of(jl.acc) */
   end.
end. /* for each gl, each jl */
*/


hide frame rptbottom.
{report3.i}
{image3.i}

end.
