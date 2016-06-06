/* rcli.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Автоматизированный подсчет доходов и расходов
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
 * AUTHOR
        31/03/04 suchkov
 * CHANGES
*/

{mainhead.i}
/*{comm-txb.i}*/
{get-dep.i}

def var sum_tax as decimal.
def var sum_pf as decimal.
def var sum_com10  as decimal.
def var sum_com20  as decimal.

def var  vprofit as char.
def var v-name as char.
def var sum11 as decimal.
def var v-dep as char format "x(3)".
def var prz as integer.
def var seltxb as int.
def var dt1 as date.
def var dt2 as date.
def var d1 as integer .
def var d2 as integer .
def var v-supusr as char.
def var v-dat as date.
def var rateusd as decimal .
def var i as integer .
def var a as decimal .

def buffer bjl for jl.

def temp-table temp 
    field cif like cif.cif 
    field name like cif.name
    field amt1 like jl.dam 
    field amtkzt1 like jl.dam
    field amt2 like jl.dam
    field amtkzt2 like jl.dam .

define frame f-dis 
    a " %" with centered row 6.

define temp-table t-cif 
    field i as integer 
    field name like cif.name 
    field cif  like cif.cif .

    dt1 = 01/01/04. dt2 = 03/01/04 . v-dep = "01" .

def frame opt 
       v-dep label "Код департамента" 
       d1 label  "предыдущий месяц расчета" 
         validate (dt1 <= g-today, " Дата не может быть больше текущей!")
       d2 label  "отчетный месяц"
         validate (dt2 <= g-today, " Дата не может быть больше текущей!")
       with row 8 centered .

update v-dep 
       d1
       d2
            with frame opt.

dt1 = date("01/" + string(d1) + "/" + string(year(today))).
dt2 = date("01/" + string(d2 + 1) + "/" + string(year(today))).

if dt2 < dt1 then do:
    message "Неверно задана дата конца отчета".
    undo,retry.    
end.
hide frame opt.

find ppoint where ppoint.depart = integer(v-dep)  no-error.
if not available ppoint then do:
    message "Неверный код департамента".
    leave.    
end.

displ "РАСЧЕТ РАСХОДОВ И ДОХОДОВ " string(time,"hh:mm:ss") with centered row 5.

find sysc where sysc.sysc = "sys1" no-lock no-error.
v-supusr = sysc.des.


for each cif where integer (cif.jame) mod 1000 = integer(v-dep) no-lock :
    create t-cif. t-cif.cif = cif.cif . t-cif.name = cif.name .
    i = i + 1.
    t-cif.i = i.
end.

for each t-cif no-lock .
    
    a = t-cif.i / i * 100 .
    display a label "Выполнено" with frame f-dis. pause 0.
                                                                                                                      
    for each aaa where aaa.cif = t-cif.cif and aaa.sta <> "C" no-lock .
        find lgr where lgr.lgr = aaa.lgr and lgr.led = "DDA" no-lock no-error.
        if not available lgr then next.

        create temp. 
        temp.amt1 = 0.
        temp.amtkzt1 = 0.
        temp.amt2 = 0.
        temp.amtkzt2 = 0.
        temp.cif = t-cif.name.
        for each jl where jl.jdt >= dt1 and jl.jdt < dt2 
                   and jl.acc = aaa.aaa 
                   and jl.lev = 1 no-lock :
    
            find last crchis where crchis.crc = 2 and crchis.regdt <= jl.jdt no-lock no-error.
            rateusd = crchis.rate[1].
            find last crchis where crchis.crc = jl.crc and crchis.regdt <= jl.jdt no-lock no-error.

            if month(jl.jdt) = d1 then temp.amtkzt1 = temp.amtkzt1 + jl.cam * crchis.rate[1] / rateusd .
                                  else temp.amtkzt2 = temp.amtkzt2 + jl.cam * crchis.rate[1] / rateusd .

            find jh where jl.jh = jh.jh no-lock .
            for each bjl where bjl.jh = jh.jh and (lookup(substr(string(bjl.gl), 1, 1), "4") > 0) no-lock .
                if month(bjl.jdt) = d1 then temp.amt1 = temp.amt1 + bjl.cam * crchis.rate[1] / rateusd .
                                       else temp.amt2 = temp.amt2 + bjl.cam * crchis.rate[1] / rateusd .
            end.
        end.

    end.
end.

output to report.html.
{html-start.i}
put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
      "<TR>"
      "<TD> Наименование клиента                 </TD>"      
      "<TD> Обороты по счетам предыдущего месяца </TD>"      
      "<TD> Доход предыдущего месяца             </TD>"      
      "<TD> Обороты по счетам текущего месяца    </TD>"      
      "<TD> Доход текущего месяца                </TD>"      
      "<TD> Суммовая разница между показателями предыдущего и текущего месяцев по оборотам клиентов </TD>"      
      "<TD> Процентная разница между показателями предыдущего и текущего месяцев по оборотам клиентов </TD></TR>".
for each temp break by temp.cif.  
    if temp.amt1 = 0 and temp.amtkzt1 = 0 and temp.amt2 = 0 and temp.amtkzt2 = 0 then next.
    put unformatted "<TR>" skip
                    "<TD>" temp.cif                            "</TD>" 
                    "<TD>" temp.amtkzt1  format ">>>,>>>,>>>,>>>"  "</TD>"
                    "<TD>" temp.amt1     format ">>>,>>>,>>>,>>>"  "</TD>"
                    "<TD>" temp.amtkzt2  format ">>>,>>>,>>>,>>>"  "</TD>"
                    "<TD>" temp.amt2     format ">>>,>>>,>>>,>>>"  "</TD>"
                    "<TD>" temp.amtkzt2 - temp.amtkzt1  format ">>>,>>>,>>>,>>>-"  "</TD>"
                    "<TD>" temp.amtkzt2 / temp.amtkzt1 * 100 format ">>>>>" "</TD></TR>".
end.                
{html-end.i}
output close .

unix silent cptwin report.html excel.
