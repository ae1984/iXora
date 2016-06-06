/* exchfin.p
 * MODULE
        Анализ работы кассира
 * DESCRIPTION
        Анализ работы кассира
 * RUN
      
 * CALLER
        excsofp.p
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        09/11/2004 kanat
 * CHANGES
        10/12/2004 kanat - Добавил вывод не найденных файлов
        01/17/2005 kanat - Поменял обработку файлов
        20/09/2005 evgeniy u00568 - так как  таблицы доработаны, то теперь только like.
*/


{global.i}
{get-dep.i}
{comm-txb.i}
{msg-box.i}

def input parameter v-handler as char.

def var v-kofc as char.
def var i as int init 0 no-undo.
def var j as int init 0 no-undo.
def var err as int init 0 no-undo.
def var seltxb as int init 0.
def var fname as char no-undo.
def var ourbank as char no-undo.


def temp-table comtmpl like commonpl
    /*field date_load as date
    field time_load as integer*/.

def temp-table taxtmpl like tax
    /*field date_load as date
    field time_load as integer*/.

def temp-table pentmpl like p_f_payment
    field date_load as date
    field time_load as integer.

def temp-table comtpl like commonpl
    /*field date_load as date
    field time_load as integer*/.

def temp-table taxtpl like tax
    /*field date_load as date
    field time_load as integer*/.

def temp-table pentpl like p_f_payment
    field date_load as date
    field time_load as integer.


def var pathname as char init 'A:\\'.
def var s as char init ''.

def var v-fname-ofc as char.

def var v-minus-index as integer.
def var v-dot-index as integer.
def var v-razn-index as integer.

def var v-com-count as integer.
def var v-tax-count as integer.
def var v-pen-count as integer.

def var v-com-sum as integer.
def var v-tax-sum as integer.
def var v-pen-sum as integer.

def var d-com-count as integer.
def var d-tax-count as integer.
def var d-pen-count as integer.

def var d-com-sum as integer.
def var d-tax-sum as integer.
def var d-pen-sum as integer.

ourbank = comm-txb().
seltxb = comm-cod().

/* ------------------------------------------------------------------------------------------------------------------- */
pathname = v-handler.
pathname = caps(trim(pathname)).
pathname = replace(pathname, '/', '\\' ).

if index(substr(pathname,length(pathname) ,1), '~\') <= 0
   then pathname = pathname + '~\'.
input through value("rsh `askhost` dir /b '" + pathname + "*.txt '") no-echo.
repeat:
       import unformatted s.
       if substr(s,1,4) = 'comz' then
       fname = s.
end.

       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').

file-info:file-name = fname.
if file-info:file-type = ? then do:
    disp  "Не найден файл загрузки " + fname.
    return.
end.

unix silent cat value(fname) | tr '\054' '\056' > base.d.

INPUT FROM base.d.
OUTPUT TO errors.txt.
i = 0.

repeat on error undo, leave:
    create comtmpl.
    import comtmpl no-error.
end.

INPUT CLOSE.
output close.

unix silent rm -f base.d.

for each comtmpl where comtmpl.sum = 0 and comtmpl.comsum = 0:
  delete comtmpl.
end.
/* ------------------------------------------------------------------------------------------------------------------- */

pathname = v-handler.
pathname = caps(trim(pathname)).
pathname = replace(pathname, '/', '\\' ).

if index(substr(pathname,length(pathname) ,1), '~\') <= 0
   then pathname = pathname + '~\'.
input through value("rsh `askhost` dir /b '" + pathname + "*.txt '") no-echo.
repeat:
       import unformatted s.
       if substr(s,1,4) = 'taxz' then
       fname = s.
end.

       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').

file-info:file-name = fname.
if file-info:file-type = ? then do:
    disp  "Не найден файл загрузки " + fname.
    return.
end.

unix silent cat value(fname) | tr '\054' '\056' > base.d.

INPUT FROM base.d.
OUTPUT TO errors.txt.
i = 0.

repeat on error undo, leave:
    create taxtmpl.
    import taxtmpl no-error.
end.

INPUT CLOSE.
output close.

unix silent rm -f base.d.

for each taxtmpl where taxtmpl.sum = 0 and taxtmpl.comsum = 0:
  delete taxtmpl.
end.

/* ------------------------------------------------------------------------------------------------------------------- */

pathname = v-handler.
pathname = caps(trim(pathname)).
pathname = replace(pathname, '/', '\\' ).

if index(substr(pathname,length(pathname) ,1), '~\') <= 0
   then pathname = pathname + '~\'.
input through value("rsh `askhost` dir /b '" + pathname + "*.txt '") no-echo.
repeat:
       import unformatted s.
       if substr(s,1,4) = 'penz' then
       fname = s.
end.

       unix silent value("rm -f *.TXT").
       unix silent value("rm -f base.d").
       unix silent value('rcp `askhost`:' + replace(pathname + fname,'\\','\\\\') + ' ./').

file-info:file-name = fname.
if file-info:file-type = ? then do:
    disp  "Не найден файл загрузки " + fname.
    return.
end.

unix silent cat value(fname) | tr '\054' '\056' > base.d.

INPUT FROM base.d.
OUTPUT TO errors.txt.
i = 0.

repeat on error undo, leave:
    create pentmpl.
    import pentmpl no-error.
end.

INPUT CLOSE.
output close.

unix silent rm -f base.d.

for each pentmpl where pentmpl.amt = 0 and pentmpl.comiss = 0:
  delete pentmpl.
end.
/* ------------------------------------------------------------------------------------------------------------------- */


for each comtmpl no-lock.
find first comtpl where comtpl.dnum = comtmpl.dnum and
                        comtpl.date = comtmpl.date and
                        comtpl.uid = comtmpl.uid and
                        comtpl.sum  = comtmpl.sum  and
                        comtpl.comsum = comtmpl.comsum and
                        comtpl.rnn = comtmpl.rnn and
                        comtpl.type = comtmpl.type and
                        comtpl.grp = comtmpl.grp no-lock no-error.
if not avail comtpl then do:
create comtpl.
buffer-copy comtmpl to comtpl.
end.
end.

for each taxtmpl no-lock.
find first taxtpl where taxtpl.dnum = taxtmpl.dnum and
                        taxtpl.date = taxtmpl.date and
                        taxtpl.uid = taxtmpl.uid and
                        taxtpl.sum  = taxtmpl.sum and
                        taxtpl.comsum = taxtmpl.comsum and
                        taxtpl.rnn = taxtmpl.rnn and
                        taxtpl.rnn_nk = taxtmpl.rnn_nk and
                        taxtpl.kb = taxtmpl.kb no-lock no-error.
if not avail taxtpl then do:
create taxtpl.
buffer-copy taxtmpl to taxtpl.
end.
end.

for each pentmpl no-lock.
find first pentpl where pentpl.dnum = pentmpl.dnum and
                        pentpl.date = pentmpl.date and
                        pentpl.uid = pentmpl.uid and
                        pentpl.amt  = pentmpl.amt and
                        pentpl.comiss = pentmpl.comiss and
                        pentpl.rnn = pentmpl.rnn and
                        pentpl.distr = pentmpl.distr and
                        pentpl.name = pentmpl.name no-lock no-error.
if not avail pentpl then do:
create pentpl.
buffer-copy pentmpl to pentpl.
end.
end.


find first comtpl where comtpl.dnum <> 0 and comtpl.deldate = ? and comtpl.uid <> ? no-lock no-error.
if avail comtpl then
v-fname-ofc = comtpl.uid.


output to scrout.img.
put unformatted " " skip.
find first ofc where ofc.ofc = v-fname-ofc no-lock no-error.
put unformatted 'Кассир: (' + v-fname-ofc + ') ' ofc.name skip.
put unformatted "Информация по принятым квитанциям кассира: " skip(2).

put unformatted "-----------------------------------------------" skip.

v-com-count = 0.
v-com-sum = 0.

put unformatted "Коммунальные платежи (АБПК PragmaTX)" skip.
put unformatted "-----------------------------------------------" skip.

for each commonpl where commonpl.txb = seltxb and
                        commonpl.date >= today - 183 and
                        commonpl.date <= today and
                        commonpl.uid = v-fname-ofc /*and
                        commonpl.deluid = ? and
                        commonpl.joudoc <> ? and
                        commonpl.rmzdoc <> ? */ no-lock.
v-com-count = v-com-count + 1.
v-com-sum = v-com-sum + commonpl.sum.
end.
put unformatted "Загружено платежей: " string(v-com-count) skip.
put unformatted "          На сумму: " string(v-com-sum) skip(1).

v-com-count = 0.
v-com-sum = 0.

put unformatted "Коммунальные платежи (Offline PragmaTX)" skip.
put unformatted "-----------------------------------------------" skip.

for each comtpl no-lock.
v-com-count = v-com-count + 1.
v-com-sum = v-com-sum + comtpl.sum.
end.
put unformatted " " skip.
put unformatted "Принято платежей: " string(v-com-count) skip.
put unformatted "        На сумму: " string(v-com-sum) skip(1).


v-com-count = 0.
v-com-sum = 0.

for each comtpl where comtpl.date_load <> ? no-lock.
v-com-count = v-com-count + 1.
v-com-sum = v-com-sum + comtpl.sum.
end.
put unformatted " " skip.
put unformatted "Принято и выгружено платежей: " string(v-com-count) skip.
put unformatted "                    На сумму: " string(v-com-sum) skip(1).

v-com-count = 0.
v-com-sum = 0.

put unformatted "Совпавшие и не совпавшие коммунальные платежи" skip.
put unformatted "-----------------------------------------------" skip.

for each comtpl where comtpl.date_load <> ? no-lock.
find first commonpl where commonpl.txb = seltxb and
                          commonpl.dnum = comtpl.dnum and
                          commonpl.date = comtpl.date and
                          commonpl.uid = comtpl.uid and
                          commonpl.sum  = comtpl.sum and
                          commonpl.comsum = comtpl.comsum and
                          commonpl.rnn = comtpl.rnn and
                          commonpl.type = comtpl.type and
                          commonpl.grp = comtpl.grp /*and
                          commonpl.deluid = ? and
                          commonpl.joudoc <> ? and
                          commonpl.rmzdoc <> ? */ no-lock no-error.
if avail commonpl then do:
v-com-count = v-com-count + 1.
v-com-sum = v-com-sum + commonpl.sum.
end.
else do:
put unformatted "Не найден в АБПК PragmaTX - " "Квит.   " string(comtpl.dnum) format "x(10)" " "
                                               "Дата:   " string(comtpl.date) format "x(10)" " "
                                               "Сумма:  " string(comtpl.sum)  format "x(20)" " "
                                               "РНН:    " string(comtpl.rnn)  format "x(12)" " "
                                               "Удален: " string(comtpl.delwhy) format "x(20)" " "
                                               "Дата выгрузки:  " string(comtpl.date_load) format "x(10)" " "
                                               "Время выгрузки: " string(comtpl.time_load, "HH:MM:SS") format "x(10)" skip.
end.
end.
put unformatted " " skip.
put unformatted "Найдено совпадений: " string(v-com-count) skip.
put unformatted "          На сумму: " string(v-com-sum) skip(1).

put unformatted "-----------------------------------------------" skip.



v-tax-count = 0.
v-tax-sum = 0.

put unformatted "Налоговые платежи (АБПК PragmaTX)" skip.
put unformatted "-----------------------------------------------" skip.

for each tax where tax.txb = seltxb and
                   tax.date >= today - 183 and
                   tax.date <= today and
                   tax.uid = v-fname-ofc /* and
                   tax.duid = ? and
                   tax.taxdoc <> ? and
                   tax.senddoc <> ? */ no-lock.
v-tax-count = v-tax-count + 1.
v-tax-sum = v-tax-sum + tax.sum.
end.
put unformatted " " skip.
put unformatted "Загружено платежей: " string(v-tax-count) skip.
put unformatted "          На сумму: " string(v-tax-sum) skip(1).


v-tax-count = 0.
v-tax-sum = 0.

put unformatted "Налоговые платежи (Offline PragmaTX)" skip.
put unformatted "-----------------------------------------------" skip.

for each taxtpl no-lock.
v-tax-count = v-tax-count + 1.
v-tax-sum = v-tax-sum + taxtpl.sum.
end.
put unformatted " " skip.
put unformatted "Принято платежей: " string(v-tax-count) skip.
put unformatted "        На сумму: " string(v-tax-sum) skip(1).


v-tax-count = 0.
v-tax-sum = 0.

for each taxtpl where taxtpl.date_load <> ? and taxtpl.time_load <> ? no-lock.
v-tax-count = v-tax-count + 1.
v-tax-sum = v-tax-sum + taxtpl.sum.
end.
put unformatted " " skip.
put unformatted "Принято и выгружено платежей: " string(v-tax-count) skip.
put unformatted "                    На сумму: " string(v-tax-sum) skip(1).


v-tax-count = 0.
v-tax-sum = 0.


put unformatted "Совпавшие и не совпавшие налоговые платежи" skip.
put unformatted "-----------------------------------------------" skip.

for each taxtpl no-lock.
find first tax where tax.txb = seltxb and
                     tax.dnum = taxtpl.dnum and
                     tax.date = taxtpl.date and
                     tax.uid = taxtpl.uid and
                     tax.sum  = taxtpl.sum and
                     tax.comsum = taxtpl.comsum and
                     tax.rnn = taxtpl.rnn and
                     tax.rnn_nk = taxtpl.rnn_nk and
                     tax.kb = taxtpl.kb /*and
                     tax.taxdoc <> ? and
                     tax.senddoc <> ? */ no-lock no-error.
if avail tax then do:
v-tax-count = v-tax-count + 1.
v-tax-sum = v-tax-sum + tax.sum.
end.
else do:
put unformatted "Не найден в АБПК PragmaTX - " "Квит.   " string(taxtpl.dnum) format "x(10)" " "
                                               "Дата:   " string(taxtpl.date) format "x(10)" " "
                                               "Сумма:  " string(taxtpl.sum)  format "x(20)" " "
                                               "РНН:    " string(taxtpl.rnn)  format "x(12)" " "
                                               "Удален: " string(taxtpl.delwhy) format "x(20)" " "
                                               "Дата выгрузки:  " string(taxtpl.date_load) format "x(10)" " "
                                               "Время выгрузки: " string(taxtpl.time_load, "HH:MM:SS") format "x(10)" skip.
end.
end.
put unformatted " " skip.
put unformatted "Найдено совпадений: " string(v-tax-count) skip.
put unformatted "          На сумму: " string(v-tax-sum) skip(1).



put unformatted "-----------------------------------------------" skip.



v-pen-count = 0.
v-pen-sum = 0.

put unformatted "Пенсионные платежи (АБПК PragmaTX)" skip.
put unformatted "-----------------------------------------------" skip.

for each p_f_payment where p_f_payment.txb = seltxb and
                           p_f_payment.date >= today - 183 and
                           p_f_payment.date <= today and
                           p_f_payment.uid = v-fname-ofc /*and
                           p_f_payment.deluid = ? and
                           p_f_payment.stcif > 0 */ no-lock.
v-pen-count = v-pen-count + 1.
v-pen-sum = v-pen-sum + p_f_payment.amt.
end.
put unformatted " " skip.
put unformatted "Загружено платежей: " string(v-pen-count) skip.
put unformatted "          На сумму: " string(v-pen-sum) skip(1).


v-pen-count = 0.
v-pen-sum = 0.

put unformatted "Пенсионные платежи (Offline PragmaTX)" skip.
put unformatted "-----------------------------------------------" skip.

for each pentpl no-lock.
v-pen-count = v-pen-count + 1.
v-pen-sum = v-pen-sum + pentpl.amt.
end.
put unformatted " " skip.
put unformatted "Принято платежей: " string(v-pen-count) skip.
put unformatted "        На сумму: " string(v-pen-sum) skip(1).


v-pen-count = 0.
v-pen-sum = 0.


for each pentpl where pentpl.date_load <> ? and pentpl.time_load <> ? no-lock.
v-pen-count = v-pen-count + 1.
v-pen-sum = v-pen-sum + pentpl.amt.
end.
put unformatted " " skip.
put unformatted "Принято и выгружено платежей: " string(v-pen-count) skip.
put unformatted "                    На сумму: " string(v-pen-sum) skip(1).


v-pen-count = 0.
v-pen-sum = 0.


put unformatted "Совпавшие и не совпавшие пенсионные платежи" skip.
put unformatted "-----------------------------------------------" skip.

for each pentpl no-lock.
find first p_f_payment where p_f_payment.txb = seltxb and
                             p_f_payment.dnum = pentpl.dnum and
                             p_f_payment.date = pentpl.date and
                             p_f_payment.uid = pentpl.uid and
                             p_f_payment.amt  = pentpl.amt and
                             p_f_payment.comiss = pentpl.comiss and
                             p_f_payment.rnn = pentpl.rnn and
                             p_f_payment.distr = pentpl.distr /*and
                             p_f_payment.stcif > 0 */ no-lock no-error.
if avail p_f_payment then do:
v-pen-count = v-pen-count + 1.
v-pen-sum = v-pen-sum + p_f_payment.amt.
end.
else do:
put unformatted "Не найден в АБПК PragmaTX - " "Квит.   " string(pentpl.dnum) format "x(10)" " "
                                               "Дата:   " string(pentpl.date) format "x(10)" " "
                                               "Сумма:  " string(pentpl.amt)  format "x(20)" " "
                                               "РНН:    " string(pentpl.rnn)  format "x(12)" " "
                                               "Удален: " string(pentpl.delwhy) format "x(20)" " "
                                               "Дата выгрузки:  " string(pentpl.date_load) format "x(10)" " "
                                               "Время выгрузки: " string(pentpl.time_load, "HH:MM:SS") format "x(10)" skip.
end.
end.
put unformatted " " skip.
put unformatted "Найдено совпадений: " string(v-pen-count) skip.
put unformatted "          На сумму: " string(v-pen-sum) skip(1).


put unformatted "-----------------------------------------------" skip.

output close.
run menu-prt("scrout.img").
