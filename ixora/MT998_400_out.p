/* MT998_400_out.p
 * MODULE
       Платежная система
 * DESCRIPTION
        формируем уведомления об откр/закр счетов юр лиц
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
       25.07.2008 galina - укоротила поле :20 до 9 символов
                           собрать счета ЮЛ откр/закр в предыдущий опердень
       09.09.2008 galina - добавлено поле accdt в таблицу acclet-detail (дата открытия/закрытия счета)
       01.12.2008 galina - убрала перикодировку в DOS
                           добавила рассылку уведомлений об отсутвии РНН
       02.12.2008 galina - список рассылки почты об ошибках возвращается параметром
       16.04.2009 galina - удаляем из временнной таблицы счета без РНН
       20.05.2009 galina - добавила код операции (закрытие, открытие счета) при поиске выгрузки за сегодняшний день
       13/10/2009 galina - берем адрес папки для выгрузки из переменной
       27/06/2011 evseev - переход на ИИН/БИН
*/
{global.i}
def new shared temp-table t-acc
 field jame as char
 field bik as char
 field acc as char
 field acctype as char
 field opertype as char
 field rnn as char
 field bin as char
 field dt as date.

def var v-mt400-n as integer.
def var v-mt400out as char.
def var v-mt400outarc as char.

def var j as integer.
def var i as integer.
def stream mt400.
def stream err.
def var v-file0  as char init 'mt400.txt'.
def var v-file as char.
def var v-str as char.
def var v-text as char.
def var v-exist as char.
def var v-exist1 as char.
def var v-errtext as char.
def var v-mlist as char.

def var v-str1 as char.

{chbin.i}
find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> "superman" then message "Не найден параметр lbeks в sysc!" view-as alert-box.
   else run log_write("Не найден параметр lbeks в sysc!").
   return.
end.
i = 0.
if connected ("txb") then disconnect "txb".
bank:
for each txb where txb.consolid = true no-lock:
  if connected ("txb") then disconnect "txb".
  connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') +  " -ld txb -U " + txb.login + " -P " + txb.password).
  run MT998_400(output v-mlist).
  disconnect "txb".
  v-errtext = "".

  find first t-acc no-lock no-error.
  if avail t-acc then do:
    for each t-acc:
      if v-bin then do:
          if t-acc.bin = "" then do:
             if v-errtext <> "" then v-errtext = v-errtext + "\\n".
             v-errtext = v-errtext + "У клиента отсутствует БИН! Филиал: " + txb.name + " Номер счета клиента: " + t-acc.acc.
             delete t-acc.
          end.
      end. else do:
          if t-acc.rnn = "" then do:
             if v-errtext <> "" then v-errtext = v-errtext + "\\n".
             v-errtext = v-errtext + "У клиента отсутствует РНН! Филиал: " + txb.name + " Номер счета клиента: " + t-acc.acc.
             delete t-acc.
          end.
      end.
    end.
  end.

  find first t-acc no-lock no-error.
  if avail t-acc then do:
    /*проверка на выгрузку уведомлений на этот день*/
    find first acclet-detail where acclet-detail.dtout = g-today and acclet-detail.bank= txb.bank and (acclet-detail.opertype = '1' or acclet-detail.opertype = '2') use-index dtoutbnk no-lock no-error.
    if avail acclet-detail then do:
 /*      message "МТ998.400 на " g-today " уже созданы!".*/
       next bank.
    end.
    i = i + 1.
    v-mt400-n = next-value(mt998-n).

    output stream mt400 to value(v-file0).

    v-text = "\{1:F01K054700000000010002536\}".
    put stream mt400 unformatted v-text skip.

    v-text = "\{2:I998KNALOG000000N2020\}".
    put stream mt400 unformatted v-text skip.

    v-text = "\{4:".
    put stream mt400 unformatted v-text skip.

    v-text = ":20:ACC" + string(v-mt400-n,'9999999999999') .
    put stream mt400 unformatted v-text skip.

    v-text = ":12:400".
    put stream mt400 unformatted v-text skip.


    v-text = ":77E:FORMS/A01/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Увед. об откр. и закр. банковских счетов".
    put stream mt400 unformatted v-text /*skip*/.


    for each t-acc:
      if v-bin then do:
          if t-acc.bin <> "" then do:
             v-text = "/ACCOUNT/" + t-acc.bik  + "/" + string(t-acc.acc,'x(20)') + "/" + t-acc.acctype + "/" + t-acc.opertype + "/" + string(year(t-acc.dt) mod 1000,'99') + string(month(t-acc.dt),'99') + string(day(t-acc.dt),'99')  + "/"  + t-acc.bin + "/0000/" + string(year(t-acc.dt) mod 1000,'99') + string(month(t-acc.dt),'99') + string(day(t-acc.dt),'99').
             put stream mt400 unformatted skip v-text.
          end.

      end. else do:
          if t-acc.rnn <> "" then do:
             v-text = "/ACCOUNT/" + t-acc.bik  + "/" + string(t-acc.acc,'x(20)') + "/" + t-acc.acctype + "/" + t-acc.opertype + "/" + string(year(t-acc.dt) mod 1000,'99') + string(month(t-acc.dt),'99') + string(day(t-acc.dt),'99')  + "/"  + t-acc.rnn + "/0000/" + string(year(t-acc.dt) mod 1000,'99') + string(month(t-acc.dt),'99') + string(day(t-acc.dt),'99').
             put stream mt400 unformatted skip v-text.
          end.
      end.
    end.
    v-text = "//".
    put stream mt400 unformatted v-text skip.

    v-text = "-\}".
    put stream mt400 unformatted v-text.

    output stream mt400 close.

    /*перекодировка из формата KOI8 в Dos**/
    v-file = "ACC" + string(v-mt400-n,'9999999999999') + ".txt".
    /*unix silent value("cat " + v-file0 + " | /pragma/bin9/koi2alt > " + v-file).*/
    unix silent value("un-win1 " + v-file0 + " " + v-file).

    /*для теста v-mt400out = "Administrator@db01:C:/STAT/NK/OUT".*/
    /* для реального сервера*/

    v-mt400out = "Administrator@db01:" + sysc.chval + "IN".
/*Копирование в каталог исходящих телеграмм**/
    input through value("scp -q " + v-file + " " + v-mt400out + ";echo $?").
    repeat:
       import unformatted v-str.
    end.
    if v-str <> "0" then do:
       if g-ofc <> "superman" then message v-str + " Ошибка копирования в " + v-mt400out view-as alert-box.
       else run log_write(v-str + " Ошибка копирования в " + v-mt400out).
    end.
    else do:
    /*Если копирование прошло нормально*/
    /*запись в таблицы*/
      for each t-acc no-lock:
        find first acclet-detail where acclet-detail.bik = t-acc.bik and acclet-detail.opertype = t-acc.opertype and acclet-detail.acc = t-acc.acc use-index bikacc no-lock no-error.
        if not avail acclet-detail then do:
          create acclet-detail.
          assign acclet-detail.accleters = "ACC" + string(v-mt400-n,'9999999999999')
                 acclet-detail.jame = t-acc.jame
                 acclet-detail.acc = t-acc.acc
                 acclet-detail.opertype = t-acc.opertype
                 acclet-detail.acctype = t-acc.acctype
                 acclet-detail.dtout = g-today
                 acclet-detail.outtime = time
                 acclet-detail.bank = txb.bank
                 acclet-detail.bik = t-acc.bik
                 acclet-detail.accdt = t-acc.dt.
        end.

        v-mt400outarc = "/data/export/mt998/" + string(g-today,'99.99.99').
        input through value( "find " + v-mt400outarc + ";echo $?").
        repeat:
           import unformatted v-exist.
        end.
        if v-exist <> "0" then do:
           unix silent value ("mkdir " + v-mt400outarc).
           unix silent value("chmod 777 " + v-mt400outarc).
        end.
        unix silent value("cp " + v-file + " " + v-mt400outarc).
        if g-ofc <> "superman" then message "Создано МТ998.400!" view-as alert-box.
     end.

    end.
    unix silent rm -f value (v-file).
    unix silent rm -f value (v-file0).

   hide all no-pause.
  end.
  if trim(v-errtext) <> "" and trim(v-mlist) <> "" then do j = 1 to num-entries(v-mlist):
    run mail(entry(j,v-mlist) + "@metrocombank.kz","METROCOMBANK <abpk@metrocombank.kz>", "Ошибки  формирования уведомлений об открытие/закрытие счетов юр. лиц", v-errtext, "", "","").
  end.
end.


/*отправка письма ДПС*/
find first acclet-detail where acclet-detail.dtout = g-today use-index dtoutbnk no-lock no-error.
if avail acclet-detail then do:
  find sysc where sysc.sysc = "MT998mail" no-lock no-error.
  if avail sysc then do j = 1 to num-entries(sysc.chval):
    run mail(entry(j,sysc.chval) + "@metrocombank.kz","METROCOMBANK <abpk@metrocombank.kz>", "Уведомление об открытие/закрытие счетов юр. лиц", "Количество уведомлений: " + string(i) + " \n " + "Каталог: L:/TERMINAL/IN"  , "", "","").
  end.
end.
/*end. */

procedure log_write.
def input parameter p-err as char.
     /*запись в логфайл*/
     input through value( "find /data/log/MT998out_err.log;echo $?").
     repeat:
       import unformatted v-exist1.
     end.
     if v-exist1 <> "0" then do:
       output stream err to value("/data/log/MT998out_err.log").
       put stream err "Журнал ошибок при выгрузке МТ988.400" skip(3).
     end.
     else output stream err to value("/data/log/MT998out_err.log") append .
     put stream err unformatted string(g-today,"99/99/99") + ", " +  string(time,"hh:mm:ss" ) +  " " + p-err skip.
     output stream err close.
 end.
