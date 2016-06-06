/* MT998_400_in.p
 * MODULE
       Платежная система
 * DESCRIPTION
        Загрузка подтверждений на уведомления об откр/закр счетов юр лиц
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        23/07/2008 galina
 * BASES
        BANK COMM
 * CHANGES
      24.07.2008 galina - перекомпиляция после загрузки новой таблицы в comm
      28.07.2008 galina - читать адрес отправителя начиная с 18-го символа
                          не удаляем обработанные файлы из папки OUT
      09.09.2008 galina - перекомпеляция в связи с изменениями в таблице acclet-detail
      10.09.2008 galina - перекомпеляция
      26/09/2008 galina - дала права доступа на файлы в каталоге v-mt400inarc
      07/10/2008 galina - не выводить сообщение о загрузке файлов для superman
      24/10/2008 galina - удалила лишний слеш из наименования архивного каталога при смене прав
      28/11/2008 galina - записываем системную дату как дату загрузки уведомления
      01.12.2008 galina - заменила find на find first для таблицы acclet-detail
      02/12/2008 galina - дала права доступа на файлы и подкаталоги в каталоге v-mt400inarc
      16/02/2009 galina - поправила строку копирования из терминала в архив
      27.05.2009 galina - для 20-тизначных счетов ищем по номеру счета и типу операции
      14.09.2009 galina - перекомпиляция
      07/04/2010 galina - убрала лишние проверки
      14/04/2010 galina - поправила определение названй файлов

*/
{global.i}

def var v-mt400in as char.
def var v-mt400inarc as char.
def var v-answer as char.
def var v-form as char.

def temp-table t-answerres
 field accleters as char
 field acc as char
 field opertype as char
 field result as char
 field answer as char
 field bik as char
 field dtin as date
 field intime as integer.


def stream mt400.
def var v-file0  as char init 'mt400.txt'.
def var v-exist as char.
def var v-exist1 as char.
def stream err.
def var v-str as char.
def var v-text as char.
def var v-text1 as char.
def var file_list as char.
def var errfile as char.
def var i as integer.
def var j as integer.



/*input through value( "ssh Administrator@db01 dir /B C:\\\\STAT\\\\NK\\\\IN\\\\*.998").*/

/* реальный сервер*/
input through value( 'ssh Administrator@db01.metrobank.kz \\"c:\\\\Program Files\\\\UnixUtils\\\\usr\\\\local\\\\wbin\\\\grep\\" -Elis ":77E:FORMS/A1C/" c:\\\\Capital\\\\Terminal\\\\Out\\\\*.998').
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    if v-str <> '' then do:
        v-str = entry(num-entries(v-str,"\\"),v-str,"\\").
        if file_list  <> "" then file_list  = file_list  + "|".
        file_list  = file_list  + v-str.
    end.
end.

 /*тестовый вариант*
 v-mt400in = "Administrator@db01:C:/STAT/NK/In/".*/
/* для реального сервера*/
v-mt400in = "Administrator@db01:C:/CAPITAL/terminal/OUT".
v-mt400inarc = "/data/import/mt998/" +  string(g-today,'99.99.99') + "/".
if file_list <> "" then do:
   input through value( "find " + v-mt400inarc + ";echo $?").
   repeat:
     import unformatted v-exist1.
   end.
   if v-exist1 <> "0" then unix silent value ("mkdir " + v-mt400inarc).
   unix silent value("chmod -R 777 " + v-mt400inarc).
end.


errfile = " ".
read:
do i = 1 to num-entries(file_list, "|"):
     unix silent value("scp -q " + v-mt400in  + "/"+ entry(i, file_list, "|") + " " + v-mt400inarc + entry(i, file_list, "|")).
     unix silent value("cat " + v-mt400inarc + entry(i, file_list, "|") + " | /pragma/bin9/alt2koi > " + v-file0).
     input from value(v-file0).

     repeat:
        import unformatted v-text1.
        if v-text1 = "-}" then leave.
        v-text1 = trim(v-text1).

        if v-text1 begins ":20:" then do:
           v-answer = substr(v-text1,5).
        end.

        if v-text1 begins "/ACCOUNT" then do:
           find codfr where codfr.codfr = "mt998res" and codfr.code = entry(9,v-text1,"/") no-lock no-error.
           if not avail codfr then do:
             run log_write(entry(i, file_list, "|"), "Неверный код результата завешения операции!" + entry(9,v-text1,"/")).
             unix silent rm -f  value(v-mt400inarc + entry(i, file_list, "|")).
             if  errfile <> " " then errfile = errfile + ", ".
             errfile = errfile + entry(i, file_list, "|").
             next read.
           end.
           create t-answerres.
           assign t-answerres.acc = entry(4,v-text1,"/")
                  t-answerres.opertype = entry(6,v-text1,"/")
                  t-answerres.result = entry(9,v-text1,"/")
                  t-answerres.answer = v-answer
                  t-answerres.dtin = today
                  t-answerres.intime = time
                  t-answerres.bik = entry(3,v-text1,"/").

        end.
     end /*repeat*/.
     input stream mt400 close.
     unix silent rm -f  value(v-file0).
end /*do*/.

find first t-answerres no-lock no-error.
if avail t-answerres then do:
  for each t-answerres no-lock:
    if length(t-answerres.acc) = 20 then find first acclet-detail where acclet-detail.acc = t-answerres.acc and acclet-detail.opertype = t-answerres.opertype use-index accoper no-lock no-error.
    else find first acclet-detail where acclet-detail.bik = t-answerres.bik and acclet-detail.opertype = t-answerres.opertype
    and acclet-detail.acc = t-answerres.acc use-index bikacc no-lock no-error.

    if avail acclet-detail then do:
      find current acclet-detail exclusive-lock.
      assign acclet-detail.result = t-answerres.result
             acclet-detail.answer = t-answerres.answer
             acclet-detail.dtin = t-answerres.dtin
             acclet-detail.intime = t-answerres.intime.
      find current acclet-detail no-lock.
      if g-ofc <> "superman" then message "МТ998.400 загружены!" view-as alert-box.
    end.
  end.
end.

/*отправка писем о необработанных файлах*/
if errfile <> "" then do:
  find sysc where sysc.sysc = "MT998mailerr" no-lock no-error.
  if avail sysc then do j = 1 to num-entries(sysc.chval):
    run mail(entry(j,sysc.chval) + "@metrocombank.kz","METROCOMBANK <abpk@metrocombank.kz>", "Необработаные подтверждения получения уведомлений об открытие/закрытие счетов юр. лиц", "Файлы: " + errfile + "  " + "Каталог: L:/TERMINAL/OUT"  , "", "","").
  end.
end.


procedure log_write.
def input parameter p-filename as char.
def input parameter p-err as char.
     /*запись в логфайл*/
     input through value( "find /data/log/MT998in_err.log;echo $?").
     repeat:
       import unformatted v-exist.
     end.
     if v-exist <> "0" then do:
       output stream err to value("/data/log/MT998in_err.log").
       put stream err "Журнал ошибок при загрузке входящих МТ988.400" skip(3).
     end.
     else output stream err to value("/data/log/MT998in_err.log") append .
     put stream err unformatted string(g-today,"99/99/99") + ", " +  string(time,"hh:mm:ss" ) + " Файл: "  + p-filename + " " + p-err skip.
     output stream err close.
 end.

