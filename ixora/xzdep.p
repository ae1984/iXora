/* xzdep.p
 * MODULE
        Операционист
 * DESCRIPTION
        Отчет по депозитам открытым депозитам ФЛ.
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
 * BASES
        BANK COMM
 * AUTHOR
        26.01.2004 dpuchkov
 * CHANGES
*/

def var d_opnamt as decimal.
def var d_dopvznos as integer.
def var d_izyatie as integer.
def var d_convert as integer.
def temp-table t-qqqqqqqqq like aaa.
def var v-val as char.
def var ddd as integer.
def var chacc as char.
def var ia as integer.
def var convert as integer.
def var v-dt as date.

define frame nnn
  v-dt label "Введите дату" help "Все депозиты открытые до вводимой даты" skip
with side-labels centered row 7.

update v-dt with frame nnn.

output to depo.csv. 
    put unformatted "Счет" ";"
                    "Валюта" ";"
                    "CIF" ";"
                    "Сумма первонач взноса" ";"
                    "Дата открытия" ";"
                    skip.


  for each lgr where lgr.led = "tda" no-lock:
    for each aaa where aaa.lgr = lgr.lgr and aaa.sta = "A" and aaa.regdt < v-dt  no-lock:
        find last cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then do:
            d_opnamt = 0. d_izyatie = 0.  d_dopvznos = 0.
            for each jl where jl.acc = aaa.aaa and jl.dc = "C" and jl.jdt = aaa.regdt and jl.lev = 1 no-lock use-index acc:
                if jl.cam - jl.dam > 0 then
                   d_opnamt = d_opnamt + (jl.cam - jl.dam).
            end.

            if aaa.crc = 1 then v-val = "KZT" .
            if aaa.crc = 2 then v-val = "USD" .
            if aaa.crc = 11 then v-val = "EUR" .

            put unformatted "[" aaa.aaa "]" ";"
                             v-val ";"
                             cif.cif ";"
                             d_opnamt ";"
                             aaa.regdt ";"
                            skip.
        end.
    end.
  end.

 
output close.
unix silent cptwin depo.csv excel.














