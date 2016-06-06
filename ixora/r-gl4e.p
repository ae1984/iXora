/* r-gl4e.p
 * MODULE
        Обороты по счетам ГК
 * DESCRIPTION
        Обороты по счетам ГК
 * RUN
        В цикле, с коннектом ко всем базам.
 * CALLER
        r-gl4
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
         COMM TXB
 * AUTHOR
        27/05/2010 - id00024
 * CHANGES
*/

define stream rep.

define input parameter v-from as date format "99/99/9999".
define input parameter v-to as date format "99/99/9999".
define input parameter v-count as integer.

define input parameter v-name as char.

define output parameter v-count1 as integer format '>>>>>>>>>>>>>>>>9'.
define output parameter v-summa1 as decimal format '>>>>>>>>>>>9.99'.

define output parameter v-count2 as integer format '>>>>>>>>>>>>>>>>9'.
define output parameter v-summa2 as decimal format '>>>>>>>>>>>9.99'.

define output parameter v-count3 as integer format '>>>>>>>>>>>>>>>>9'.
define output parameter v-summa3 as decimal format '>>>>>>>>>>>9.99'.

v-count1 = 0.
v-summa1 = 0.


for each txb.jl where txb.jl.jdt >= v-from and txb.jl.jdt < v-to and
   (txb.jl.gl = 453010
or txb.jl.gl = 453080
or txb.jl.gl = 460111
or txb.jl.gl = 460122
or txb.jl.gl = 460123
or txb.jl.gl = 460124
or txb.jl.gl = 460125
or txb.jl.gl = 460126
or txb.jl.gl = 460127
or txb.jl.gl = 460410
or txb.jl.gl = 460713
or txb.jl.gl = 460721
or txb.jl.gl = 461110
or txb.jl.gl = 461120
or txb.jl.gl = 492120
or txb.jl.gl = 492130
or txb.jl.gl = 492140) no-lock:

if txb.jl.dc = 'D' and jl.rem[1] = "Свертка доходов" then next.
if jl.dc = 'C' then v-count1 = v-count1 + 1.
    if txb.jl.crc = 1 then v-summa1 = v-summa1 + txb.jl.cam - txb.jl.dam.
    else do:
        find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
        if avail txb.crchis then v-summa1 = v-summa1 + (txb.jl.cam * crchis.rate[1]) - (txb.jl.dam * crchis.rate[1]).
    end.
end.

v-count2 = 0.
v-summa2 = 0.


for each txb.jl where txb.jl.jdt >= v-from and txb.jl.jdt < v-to and (txb.jl.gl = 453020) no-lock:
if txb.jl.dc = 'D' and jl.rem[1] = "Свертка доходов" then next.
if jl.dc = 'c' then v-count2 = v-count2 + 1.
    if txb.jl.crc = 1 then v-summa2 = v-summa2 + txb.jl.cam - txb.jl.dam.
    else do:
        find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
        if avail txb.crchis then v-summa2 = v-summa2 + (txb.jl.cam * crchis.rate[1]) - (txb.jl.dam * crchis.rate[1]).
    end.
end.


v-count3 = 0.
v-summa3 = 0.

for each txb.jl where txb.jl.jdt >= v-from and txb.jl.jdt < v-to and (txb.jl.gl = 460610) no-lock:
if txb.jl.dc = 'D' and jl.rem[1] = "Свертка доходов" then next.
if jl.dc = 'C' then v-count3 = v-count3 + 1.
    if txb.jl.crc = 1 then v-summa3 = v-summa3 + txb.jl.cam - txb.jl.dam.
    else do:
        find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
        if avail txb.crchis then v-summa3 = v-summa3 + (txb.jl.cam * crchis.rate[1]) - (txb.jl.dam * crchis.rate[1]).
    end.
end.

output stream rep to "outputfile.html" append.

    put stream rep unformatted "<TABLE border=1>" skip.
    put stream rep unformatted "<TR>" skip.
    put stream rep unformatted "<td>" v-count "</td>" skip.
    put stream rep unformatted "<td>" v-name format "x(18)" "</td> <td>" replace(string(v-summa1, ">>>>>>>>>>>9.99"), ".", ",") "</td> <td>" v-count1 "</td>" skip.
    put stream rep unformatted "<td>" replace(string(v-summa2, ">>>>>>>>>>>9.99"), ".", ",") "</td>" "<td>" v-count2 "</td>" skip.
    put stream rep unformatted "<td>" replace(string(v-summa3, ">>>>>>>>>>>9.99"), ".", ",") "</td>" "<td>" v-count3 "</td>" skip.
    put stream rep unformatted "</TR>" skip.
    put stream rep unformatted "</TABLE>" skip.

output stream rep close.
