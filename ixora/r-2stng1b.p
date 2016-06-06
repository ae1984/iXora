/* r-2stng1b.p
 * MODULE
        Временная структура по депозитам на дату
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


def var v-summ as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summjur as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summfiz as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].

def var v-header as char init "                     остаток  сред.ставка      кред.поступ." format "x(70)".
define variable vfu as character format "x(8)".
define variable i as integer.

define shared temp-table depf 
           field gl like bank.gl.gl
           field glr like bank.gl.gl
           field des like bank.gl.des
           field fu as character 
           field v-name1 as character extent 12
           field v-name2 as character extent 12
           field v-name11 as character extent 12
           field v-name99 as character extent 12
           field v-summ1 as decimal extent 12
           field v-rate1 as decimal extent 12
           field v-summ1-cred as decimal extent 12
           field v-summ1-pr as decimal extent 12
           field v-summ2 as decimal extent 12
           field v-rate2 as decimal extent 12
           field v-summ2-cred as decimal extent 12
           field v-summ2-pr as decimal extent 12
           field v-summ11 as decimal extent 12
           field v-rate11 as decimal extent 12
           field v-summ11-cred as decimal extent 12
           field v-summ11-pr as decimal extent 12
           field v-summ99 as decimal extent 12
           field v-rate99 as decimal extent 12
           field v-summ99-cred as decimal extent 12
           field v-summ99-pr as decimal extent 12
           index idx_depf is primary gl.


procedure IMPORT_SUMMS.
   define input parameter vfile as character.

   unix silent value ("touch " + vfile).
   input from value (vfile).
   import v-summ no-error.
   if not error-status:error then do:  
      v-summjur[1] = v-summjur[1] + v-summ[1].
      v-summjur[2] = v-summjur[2] + v-summ[2].
      v-summjur[3] = v-summjur[3] + v-summ[3].
      v-summjur[4] = v-summjur[4] + v-summ[4].
      v-summjur[5] = v-summjur[5] + v-summ[5].
      v-summjur[6] = v-summjur[6] + v-summ[6].
      v-summjur[7] = v-summjur[7] + v-summ[7].
      v-summjur[8] = v-summjur[8] + v-summ[8].
      v-summjur[9] = v-summjur[9] + v-summ[9].
      v-summjur[10] = v-summjur[10] + v-summ[10].
      v-summjur[11] = v-summjur[11] + v-summ[11].
      v-summjur[12] = v-summjur[12] + v-summ[12].
   end.
   import v-summ no-error.
   if not error-status:error then do:
      v-summfiz[1] = v-summfiz[1] + v-summ[1].
      v-summfiz[2] = v-summfiz[2] + v-summ[2].
      v-summfiz[3] = v-summfiz[3] + v-summ[3].
      v-summfiz[4] = v-summfiz[4] + v-summ[4].
      v-summfiz[5] = v-summfiz[5] + v-summ[5].
      v-summfiz[6] = v-summfiz[6] + v-summ[6].
      v-summfiz[7] = v-summfiz[7] + v-summ[7].
      v-summfiz[8] = v-summfiz[8] + v-summ[8].
      v-summfiz[9] = v-summfiz[9] + v-summ[9].
      v-summfiz[10] = v-summfiz[10] + v-summ[10].
      v-summfiz[11] = v-summfiz[11] + v-summ[11].
      v-summfiz[12] = v-summfiz[12] + v-summ[12].
   end.          
   input close.

end procedure.

run IMPORT_SUMMS ("depos1TXB00.txt").
run IMPORT_SUMMS ("depos1TXB01.txt").
run IMPORT_SUMMS ("depos1TXB02.txt").
run IMPORT_SUMMS ("depos1TXB03.txt").
run IMPORT_SUMMS ("depos1TXB04.txt").
run IMPORT_SUMMS ("depos1TXB05.txt").
run IMPORT_SUMMS ("depos1TXB06.txt").
run IMPORT_SUMMS ("depos1TXB07.txt").
run IMPORT_SUMMS ("depos1TXB08.txt").
run IMPORT_SUMMS ("depos1TXB09.txt").
run IMPORT_SUMMS ("depos1TXB10.txt").
run IMPORT_SUMMS ("depos1TXB11.txt").
run IMPORT_SUMMS ("depos1TXB12.txt").
run IMPORT_SUMMS ("depos1TXB13.txt").
run IMPORT_SUMMS ("depos1TXB14.txt").
run IMPORT_SUMMS ("depos1TXB15.txt").
run IMPORT_SUMMS ("depos1TXB16.txt").


def stream depos.
output stream depos to value("depos-all.txt").
put stream depos 
  "ЮРЛИЦА" skip
  "   <=7дн   " v-summjur[1] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   7дн-1   " v-summjur[2] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   1-2     " v-summjur[3] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   2-3     " v-summjur[4] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   3-6     " v-summjur[5] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   6-9     " v-summjur[6] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   9-12    " v-summjur[7] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   1-2 год " v-summjur[8] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   2-3 лет " v-summjur[9] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   3-5 лет " v-summjur[10] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   >5 лет  " v-summjur[11] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "всего      " v-summjur[12] format "zzz,zzz,zzz,zzz,zz9.99" skip(1)
   skip(1) 
  "ФИЗЛИЦА" skip
  "   <=7дн   " v-summfiz[1] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   7дн-1   " v-summfiz[2] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   1-2     " v-summfiz[3] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   2-3     " v-summfiz[4] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   3-6     " v-summfiz[5] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   6-9     " v-summfiz[6] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   9-12    " v-summfiz[7] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   1-2 год " v-summfiz[8] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   2-3 лет " v-summfiz[9] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   3-5 лет " v-summfiz[10] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "   >5 лет  " v-summfiz[11] format "zzz,zzz,zzz,zzz,zz9.99" skip
  "всего      " v-summfiz[12] format "zzz,zzz,zzz,zzz,zz9.99" skip(1)
  "всего  +   " v-summfiz[12] + v-summjur[12] format "zzz,zzz,zzz,zzz,zz9.99" skip(1) .

put stream depos skip (3).

for each depf break by depf.fu by depf.gl:

    if first-of (depf.fu) then do:
       if depf.fu = "F" then vfu = "ФИЗ.ЛИЦА". else vfu = "ЮР.ЛИЦА".
       put stream depos unformatted vfu skip "-----------------------------------" skip (2).
    end.

    if first-of (depf.gl) then 
    put stream depos unformatted depf.gl " (" depf.glr ")  " depf.des skip "------" skip.

    put stream depos unformatted skip (2) "KZT                      остаток  сред.ставка      кред.поступ.        Начисл %%   " skip.
    do i = 1 to 12:
      put stream depos 
             depf.v-name1[i] format "x(12)" 
             depf.v-summ1[i] format "-zzz,zzz,zzz,zzz,zz9.99" 
             depf.v-rate1[i] format "zzz9.99" 
             depf.v-summ1-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" 
             depf.v-summ1-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.
    end.
    put stream depos skip.

    put stream depos unformatted skip (2) "USD                      остаток  сред.ставка      кред.поступ.         Начисл %%    " skip.
    do i = 1 to 12:
      put stream depos 
             depf.v-name2[i] format "x(12)" 
             depf.v-summ2[i] format "-zzz,zzz,zzz,zzz,zz9.99" 
             depf.v-rate2[i] format "zzz9.99" 
             depf.v-summ2-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             depf.v-summ2-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.
    end.
    put stream depos skip.

    put stream depos unformatted skip (2) "EUR                      остаток  сред.ставка      кред.поступ.         Начисл %%     " skip.
    do i = 1 to 12:
      put stream depos 
             depf.v-name11[i] format "x(12)" 
             depf.v-summ11[i] format "-zzz,zzz,zzz,zzz,zz9.99" 
             depf.v-rate11[i] format "zzz9.99" 
             depf.v-summ11-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" 
             depf.v-summ11-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.
    end.
    put stream depos skip.

    put stream depos unformatted skip (2) "Другие валюты            остаток  сред.ставка      кред.поступ.         Начисл %%     " skip.
    do i = 1 to 12:
      put stream depos 
             depf.v-name99[i] format "x(12)" 
             depf.v-summ99[i] format "-zzz,zzz,zzz,zzz,zz9.99" 
             depf.v-rate99[i] format "zzz9.99" 
             depf.v-summ99-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" 
             depf.v-summ99-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.
    end.
    put stream depos skip.

    put stream depos unformatted skip(2).

end.

output stream depos close.

run menu-prt ("depos-all.txt").

