/* loadcartost.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Загрузка данных по остаткам на карточных счетах
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
        13/08/2013 galina ТЗ1938
 * BASES
        BANK COMM
 * CHANGES
        13/09/2013 galina - ТЗ2086 при повторной загрузке за месяц удаляем загруженные записи
*/
{yes-no.i}
{global.i}


def var v-str as char.
def var v-str2 as char.
def var file_list as char.
def var i as int.
def var v-text1 as char.
def stream instream.
def stream outstream.
def var num as int.
def var v-numstr as int.
def var v-dtost as date.
def var v-dtcred as date.
def var v-sumost as deci no-undo.
def var v-sumproc as deci no-undo.
def var v-sumost_pros as deci no-undo.
def var v-sumproc_pros as deci no-undo.
def var v-sub as char no-undo.
def var v-subold as char no-undo.
def var v-logshow as logi no-undo init no.
def var v-delall as int no-undo.

function getMonthName returns char (input p-month as integer).
    def var v-res as char no-undo.
    v-res = ''.
    def var v-monthList as char no-undo.
    v-monthList = "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".
    if p-month >= 1 and p-month <= 12 then v-res = entry(p-month,v-monthList).
    return v-res.
end function.

num = 0.
input through value( "ssh Administrator@`askhost` dir /B C:\\\\kartost\\\\*.CSV").
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    if v-str <> '' then do:
        v-str = entry(num-entries(v-str,"\\"),v-str,"\\").
        if file_list  <> "" then file_list  = file_list  + "|".
        file_list  = file_list  + v-str.
    end.
end.
if file_list = '' then do:
    message "Не найден файл для загрузки!" view-as alert-box.
    return.
end.
message "Ждите идет загрузка....".

do i = 1 to num-entries(file_list, "|"):
     input through value ("scp -pq Administrator@`askhost`:C:/kartost"  + "/"+ entry(i, file_list, "|") + " /home/" + g-ofc + '/' + entry(i, file_list, "|") + ";echo $?").
     import unformatted v-str2.
     if v-str2 <> "0" then do:
         message "Ошибка копирования файла ! " + entry(i, file_list, "|") +  ". Имя файла не должно содержать русские символы и пробелы!" view-as alert-box.
         return.
     end.

     unix silent value("cat  /home/" + g-ofc + '/' + entry(i, file_list, "|") + " | /pragma/bin9/alt2koi > kart.txt").


     output to value("kart.txt") append.
     put unformatted chr(10).
     output close.

     output stream outstream to logkart.txt append.
     put stream outstream unformatted skip(2).
     put stream outstream unformatted '-----карточные счета начало загрузки-----' + string(g-today) + ' ' + g-ofc + ' ' + string(time,'HH:MM:SS') + '  файл ' + entry(i, file_list, "|")  skip.

     input stream instream from value('kart.txt').
     v-numstr = 0.
     v-delall = 0.
     repeat:
        do transaction:
            import stream instream unformatted v-text1.
            v-text1 = trim(v-text1).
            v-numstr = v-numstr + 1.
            if trim(v-text1) = '' then next.
            if num-entries(v-text1,';') <> 11 and num-entries(v-text1,';') <> 6 then do:
                 put stream outstream unformatted "Номер строки " + string(v-numstr) + " Неверный формат строки " + trim(v-text1) skip.
                 next.
            end.
            if v-text1 <> "" then do:
                    if not trim(v-text1) begins 'TXB' then next.
                    find first txb where txb.bank = trim(entry(1, v-text1, ";")) no-lock no-error.
                    if not avail txb then do:
                        put stream outstream unformatted "Номер строки " + string(v-numstr) +  " Неверный код банка " + trim(entry(1, v-text1, ";")) skip.
                        next.
                    end.
                    else do:
                        find first crc where crc.crc = int(trim(entry(3,v-text1,";"))) no-lock no-error.
                        if not avail crc then do:
                            put stream outstream unformatted "Номер строки " + string(v-numstr) +  " Неверный код валюты " + trim(entry(3, v-text1, ";")) skip.
                            next.
                        end.

                        v-sumost = deci(replace(entry(4,v-text1,";"),' ','')) no-error.
                        if error-status:error then do:
                            put stream outstream unformatted "Номер строки " + string(v-numstr) +  " Неверный формат суммы остатка (ОД) " + trim(entry(4, v-text1, ";")) skip.
                            next.
                        end.

                        v-dtost = date(trim(entry(5,v-text1,";"))) no-error.
                        if error-status:error then do:
                            put stream outstream unformatted "Номер строки " + string(v-numstr) +  " Неверный формат даты " + trim(entry(5, v-text1, ";")) skip.
                            next.
                        end.


                        if lookup(trim(entry(6,v-text1,";")),'aaa,lon') = 0 then do:
                            put stream outstream unformatted "Номер строки " + string(v-numstr) +  " Неверный тип счета " + trim(entry(6, v-text1, ";")) skip.
                            next.
                        end.
                        else v-sub = trim(entry(6,v-text1,";")).
                        if num-entries(v-text1,';') = 11 then do:
                            v-sumproc = deci(replace(entry(7,v-text1,";"),' ','')) no-error.
                            if error-status:error then do:
                                put stream outstream unformatted "Номер строки " + string(v-numstr) +  " Неверный формат суммы % " + trim(entry(7, v-text1, ";")) skip.
                                next.
                            end.

                            v-sumost_pros = deci(replace(entry(8,v-text1,";"),' ','')) no-error.
                            if error-status:error then do:
                                put stream outstream unformatted "Номер строки " + string(v-numstr) +  " Неверный формат суммы просроченного ОД " + trim(entry(8, v-text1, ";")) skip.
                                next.
                            end.

                            v-sumproc_pros = deci(replace(entry(9,v-text1,";"),' ','')) no-error.
                            if error-status:error then do:
                                put stream outstream unformatted "Номер строки " + string(v-numstr) +  " Неверный формат суммы просроченных % " + trim(entry(9, v-text1, ";")) skip.
                                next.
                            end.


                            v-dtcred = date(entry(11,v-text1,";")) no-error.
                            if error-status:error then do:
                                put stream outstream unformatted "Номер строки " + string(v-numstr) +  " Неверный формат даты " + trim(entry(11, v-text1, ";")) skip.
                                next.
                            end.
                        end.
                        if v-subold <> v-sub and v-delall < 2 then do:
                            find first cartost where cartost.sub = v-sub and substr(string(cartost.dtost,'99/99/9999'),4,7) = substr(string(v-dtost,'99/99/9999'),4,7) no-lock no-error.
                            if avail cartost then do:
                               if yes-no ('', (if v-sub = 'aaa' then 'Данные по остаткам на карточных счетах ' else 'Данные по кредитным лимитам для карточных счетов ') + 'за ' + getMonthName(month(cartost.dtost)) + ' ' + string(year(cartost.dtost),'9999')  + ' г. уже загружены за дату '  + string(cartost.dtost,'99/99/9999') + '. Заменить данные?»') then do:
                                    v-logshow = yes.
                                    v-delall = v-delall + 1.
                                    for each cartost where cartost.sub = v-sub and substr(string(cartost.dtost,'99/99/9999'),4,7) = substr(string(v-dtost,'99/99/9999'),4,7) exclusive-lock:
                                         delete cartost.
                                    end.
                               end.
                                else do:
                                    if v-logshow then leave.
                                    else return.
                                end.
                            end.
                        end.

                       find first cartost where cartost.acc = entry(2,v-text1,";") and (cartost.cif = entry(10,v-text1,";") or cartost.cif = '') and cartost.dtost = date(entry(5,v-text1,";")) no-lock no-error.
                       if not avail cartost then do:

                           num = num + 1.

                           create cartost.
                           assign cartost.bank = trim(entry(1,v-text1,";"))
                                  cartost.acc = trim(entry(2,v-text1,";"))
                                  cartost.dtost = v-dtost
                                  cartost.crc = int(trim(entry(3,v-text1,";")))
                                  cartost.sumost = v-sumost
                                  cartost.sub = v-sub.
                           if cartost.sub = 'lon' then do:
                              assign cartost.sumproc = v-sumproc
                                     cartost.sumost_pros = v-sumost_pros
                                     cartost.sumproc_pros =  v-sumproc_pros
                                     cartost.cif = entry(10,v-text1,";")
                                     cartost.lnrdt = v-dtcred.

                           end.
                       end.
                       else put stream outstream unformatted "Номер строки " + string(v-numstr) +  " Запись по клиенту " + cartost.cif + ' счет ' + cartost.acc + ' дата ' + string(cartost.dtost,'99/99/9999') + ' есть в базе!' skip.
                       v-subold = v-sub.
                    end.
            end.
        end.
     end /*repeat*/.
     input stream instream close.
     unix silent rm -f  kart.txt.
     put stream outstream unformatted ' Загружено записей ' + string(num) skip.
     put stream outstream unformatted '-----карточные счета конец загрузки-----' + string(g-today) + ' ' + g-ofc + ' ' + string(time,'HH:MM:SS') + '  файл ' + entry(i, file_list, "|")  skip.
     output stream outstream close.
 end.

hide message no-pause.
/*message "Загрузка закончена!" view-as alert-box.*/
unix silent value("cptwin logkart.txt wordpad").
unix silent rm -f  logkart.txt.