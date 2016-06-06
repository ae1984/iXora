/* r-2stng2.p
 * MODULE
        Временная структура по депозитам на дату (КУРСЫ)
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
        8-2-14-1
 * AUTHOR
        22/10/04 sasco
 * CHANGES
        19/01/2005 marinav Добавились начисленные проценты 
        15.07.08 marinav - добавились сроки 1-7 дней, 7-10 дней , 2-3 года, 3-5 лет
        29.04.10 marinav - добавились сроки  1-2 года, 2-3
*/



def var v-name as char.
def var v-num as integer init 12.
def var i as integer.
def var v-summ as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-rate as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ-cred as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-names as char extent 12 init [" <=7дн "," 7дн-1мес "," 1-2 мес "," 2-3 мес "," 3-6 мес "," 6-9 мес "," 9-12мес "," 1-2 года "," 2-3 лет  "," 3-5 лет  "," >5 лет","всего "].
def var v-cln as char.
def var v-crc like crc.crc.

def var v-header as char init "                     остаток  сред.ставка      кред.поступ." format "x(70)".

def temp-table t-sums
  field txb as integer init ?
  field cln as char init ""
  field gl like gl.gl
  field crc like crc.crc
  field summ as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0]
  field rate as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0]
  field summ-cred as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0]
  field summ-pr as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0]
  index main is primary unique txb cln gl crc.

  
procedure IMPORT_SUMMS.
    define input parameter vfile as char.
    unix silent value ("touch " + vfile).
    input from value (vfile).
    repeat:
      create t-sums.
      import t-sums no-error.
      if error-status:error then delete t-sums.
    end.
    input close.
end procedure.


run IMPORT_SUMMS ("depos2TXB00.txt").
run IMPORT_SUMMS ("depos2TXB01.txt").
run IMPORT_SUMMS ("depos2TXB02.txt").
run IMPORT_SUMMS ("depos2TXB03.txt").
run IMPORT_SUMMS ("depos2TXB04.txt").
run IMPORT_SUMMS ("depos2TXB05.txt").
run IMPORT_SUMMS ("depos2TXB06.txt").
run IMPORT_SUMMS ("depos2TXB07.txt").
run IMPORT_SUMMS ("depos2TXB08.txt").
run IMPORT_SUMMS ("depos2TXB09.txt").
run IMPORT_SUMMS ("depos2TXB10.txt").
run IMPORT_SUMMS ("depos2TXB11.txt").
run IMPORT_SUMMS ("depos2TXB12.txt").
run IMPORT_SUMMS ("depos2TXB13.txt").
run IMPORT_SUMMS ("depos2TXB14.txt").
run IMPORT_SUMMS ("depos2TXB15.txt").
run IMPORT_SUMMS ("depos2TXB16.txt").

for each t-sums where cln = "" or cln = ?. delete t-sums. end.

def stream depos.

output stream depos to value("depos-crc-all.txt").

for each t-sums break by cln by gl by crc:

  if first-of(t-sums.cln) then do:
    put stream depos 
      skip(2) "-----------------------------------------------------------" skip(2).

    if cln = "1" then put stream depos "ЮР. ЛИЦА" skip.
                 else put stream depos "ФИЗ. ЛИЦА" skip.

  end.

  if first-of(gl) then do:
    find gl where gl.gl = t-sums.gl no-lock no-error.
    put stream depos  skip 
        "-----------------------------------" skip(1)
        "ГК " gl.gl "  " gl.des skip 
        "----------" skip.
  end.

  if first-of (t-sums.crc) then do:
    if t-sums.crc = 99 then v-name = "ДР.ВАЛ".
    else do:
      find crc where crc.crc = t-sums.crc no-lock no-error.
      v-name = " " + crc.code + "  ".
    end.
    put stream depos skip(1) v-name v-header skip.

    do i = 1 to v-num:
      v-summ[i] = 0.
      v-rate[i] = 0.
      v-summ-cred[i] = 0.
    end.
  end.

  do i = 1 to v-num:
    v-summ[i] = v-summ[i] + t-sums.summ[i].
    v-rate[i] = v-rate[i] + t-sums.summ[i] * t-sums.rate[i].
    v-summ-cred[i] = v-summ-cred[i] + t-sums.summ-cred[i].
  end.

  if last-of(t-sums.crc) then do:
    do i = 1 to v-num:
      v-name = v-names[i].
      if i = v-num then 
        case t-sums.cln :
          when "1" then v-name = v-name + "ЮЛ ".
          otherwise v-name = v-name + "ФЛ ".
        end case.

      put stream depos 
             v-name format "x(12)" 
             v-summ[i] format "-zzz,zzz,zzz,zzz,zz9.99" .
      if v-summ[i] = 0 then put stream depos 0 format "zzz9.99". 
                       else put stream depos v-rate[i] / v-summ[i] format "zzz9.99" .
      put stream depos v-summ-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.
    end.
  end.
end.


output stream depos close.


/* средневзвеш. ставка и конечное сальдо по всем счетам, по KZT/USD/др*/
def temp-table t-rates
  field crc like crc.crc
  field sum as decimal
  field sumrate as decimal
  index main is primary unique crc.


for each t-sums break by t-sums.crc by t-sums.cln by t-sums.gl :
  if t-sums.crc > 3 then v-crc = 99. else v-crc = t-sums.crc.
  find t-rates where t-rates.crc = v-crc no-error.
  if not avail t-rates then do:
    create t-rates.
    t-rates.crc = v-crc.
  end.

  if t-sums.summ[11] = 0 then next.

  t-rates.sum = t-rates.sum + t-sums.summ[11].
  t-rates.sumrate = t-rates.sumrate + t-sums.summ[11] * t-sums.rate[11].
end.

output stream depos to value("depos-rate-all.txt").
put stream depos 
  "ВАЛЮТА   СРЕДН/ВЗВ СТАВКА      КОНЕЧНОЕ САЛЬДО" skip
  "-------------------------------------------------" skip.
for each t-rates:
  if t-rates.sum = 0 then next.
  accumulate t-rates.sum (total).

  find crc where crc.crc = t-rates.crc no-lock no-error.
  
  if avail crc then put stream depos crc.code "   ". 
               else put stream depos "ПРОЧИЕ".
  put stream depos "       " t-rates.sumrate / t-rates.sum format "zzz9.9999" "  " t-rates.sum format "zzz,zzz,zzz,zzz,zz9.99" skip.
end.
put stream depos 
  "-------------------------------------------------" skip
  "ВСЕГО                   " accum total t-rates.sum format "zzz,zzz,zzz,zzz,zz9.99" skip.

output stream depos close.

run menu-prt ("depos-rate-all.txt").


