/* txfnddt.p
 * Модуль
     Коммунальные платежи
 * Назначение
     Реестр отправленных налоговых п.п для Департамента налогового планирования
 * Применение

 * Вызов
     
 * Пункты меню
     п.3.2.10.10.9 Детальная информация по п.п НК 

 * Автор
     pragma
 * Дата создания:
     05.08.03
 * Изменения
     05.08.03 kanat Написал процедуру
     13.11.03 sasco переделал формат вывода (длину строки)
     13.12.03 kanat переделал вывод данных в файл.
     22.01.04 sasco переделал вывод в файл + заголовок только если есть tax
*/

{global.i}
{comm-txb.i}


if not connected ("comm") then run comm-con. 

def buffer ttax for tax.

def var v-date_begin   like tax.date.
def var v-plat_date    as char.
def var v-dnum_sum_1   as decimal format ">>>,>>>,>>>,>>9.99" init 0.
def var v-dnum_sum_2   as decimal format ">>>,>>>,>>>,>>9.99" init 0.
def var v-plat_name    as char.
def var v-plat_num     as integer.
def var v-txb          as integer.
def var v-choice       as logical.
def var v-kbk          as integer.
def var v-rnnnk        as char.
def var v-kv_name      as char.
def var v-records_count as integer.
def var v-sum_grp_itogo as decimal.


def var v-tmp_kbk       as char.
def var v-tmp_rnnnk     as char.
def var v-tmp_tax       as char.
def var v-tmp_acc       as char.

def var v-file_name     as char.


v-txb = comm-cod().


update v-date_begin   label "Введите дату п.п: " with centered side-label.
update v-plat_num     label "Введите номер п.п. : " with centered side-label.
update v-dnum_sum_1   label "Введите сумму квитанции с: " with centered side-label.
update v-dnum_sum_2   label "Введите сумму квитанции по: " with centered side-label.
update v-kbk          label "Введите код бюджетной классификации (Код дохода): " with centered side-label.



    message "Выбрать налоговый комитет?"
    view-as alert-box question buttons yes-no
    title "НК РК:" update v-choice.



if v-choice then do:
run taxnkall.
v-rnnnk = string(return-value).
end.
else
v-rnnnk = 'ALL'.

v-file_name = "comrstr.img".
output to value(v-file_name).

for each remtrz where valdt1 = v-date_begin and 
                      rdt = v-date_begin and
                      trim(substring(remtrz.sqn,19,8)) = string(v-plat_num) and 
                      remtrz.rcvinfo[1] = "/TAX/" and 
                      substr(remtrz.racc,4,3) = "080" no-lock. 


if trim(entry(3,remtrz.ba,'/')) = string(v-kbk) and 
   trim(entry(3,remtrz.bn[3],"/")) = v-rnnnk then do:


find first tax where tax.txb = v-txb and 
                     tax.senddoc = remtrz.remtrz and 
                     (tax.rnn_nk = v-rnnnk or v-rnnnk = 'ALL') and 
                     tax.sum >= v-dnum_sum_1 and
                     tax.sum <= v-dnum_sum_2 no-lock use-index senddoc no-error.

if avail tax then do:
   put unformatted '                                       ЗАЧИСЛЕННЫЕ В НК НАЛОГОВЫЕ ПЛАТЕЖИ - ' v-date_begin ' РЕФЕРЕНС: ' remtrz.remtrz skip.
   put fill("=",162) format "x(162)" skip.
   put unformatted 'КодНК |КБК    |N п/п    |Дата п/п |Сумма п.п    |N квитанции  |Дата квитанции | Сумма квитанции |РНН плательщика     |Наименование плательщика' skip.
   put fill("=",162) format "x(162)" skip.
end.

for each tax where tax.txb = v-txb and 
                   tax.senddoc = remtrz.remtrz and 
                  (tax.rnn_nk = v-rnnnk or v-rnnnk = 'ALL') and 
                   tax.sum >= v-dnum_sum_1 and
                   tax.sum <= v-dnum_sum_2 no-lock use-index senddoc break by tax.dnum.

if tax.rnn = "000000000000" or tax.rnn = "999999999999" then
   v-kv_name = tax.chval[1].
else do:

 find first comm.rnn where comm.rnn.trn=rnn USE-INDEX rnn no-lock no-error.
 if not avail comm.rnn then find first comm.rnnu where comm.rnnu.trn = comm.tax.rnn USE-INDEX rnn no-lock no-error.

 if avail comm.rnn then v-kv_name = trim(comm.rnn.lname) + " " + trim(comm.rnn.fname) + " " + trim(comm.rnn.mname).
 else if avail comm.rnnu then v-kv_name = caps(trim( comm.rnnu.busname )). else v-kv_name = "".    

end.

put unformatted substr(tax.rnn_nk,1,4) '  ' 
                v-kbk '   ' 
                v-plat_num '        ' 
                v-date_begin ' ' 
                remtrz.amt format ">>>,>>>,>>9.99" '     ' 
                tax.dnum format ">>>>>>>9" '   ' 
                tax.date '         ' 
                tax.sum format ">>>,>>>,>>9.99" '   ' 
                tax.rnn format "x(12)"  '        '
                v-kv_name skip.

v-records_count = v-records_count + 1.
v-sum_grp_itogo = v-sum_grp_itogo + tax.sum.

end.
end.
end.

put fill("=",162) format "x(162)" skip.
put unformatted "Итого платежей по квитанции: " v-records_count skip.
put unformatted "Итого сумма по пачке: " v-sum_grp_itogo format ">>>,>>>,>>>,>>9.99" skip.
put fill("=",162) format "x(162)" skip.


output close.
run menu-prt (v-file_name).

unix SILENT value('rm -f ' + v-file_name).









