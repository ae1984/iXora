/* MT998aaa20_out.p
 * MODULE
       Платежная система
 * DESCRIPTION
        Отправка уведомление об изменении номеров банковских счетов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        16/04/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        17/04/2009 galina - перекомпеляция
        14.05.2009 galina - явно указала наш новый БИК
        20.05.2009 galina - в одном файле не более 100 счетов
                            добавила код операции (изменение номера счета) при поиске выгрузки за сегодняшний день
        13/10/2009 galina - берем адрес папки для выгрузки из переменной
        15/04/2010 galina - добавила проверку на выгрузку, чтобы не дублировать
        16/04/2010 galina - поправила запись в логфайл
        23/09/2011 evseev  - переход на ИИН/БИН
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
*/
{global.i}
{chbin.i}
def new shared temp-table t-acc
 field jame as char
 field bik as char
 field acc as char
 field acc9 as char
 field acctype as char
 field opertype as char
 field rnn as char
 field bin as char
 field dt as date.

{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

def var v-mt400-n as integer.
def var v-mt400out as char.
def var v-mt400outarc as char.
def var i as integer.
def var j as integer.
def var k as integer.

def stream mt400.
def stream err.
def var v-file0  as char init 'mt400aaa20.txt'.
def var v-file as char.
def var v-str as char.
def var v-text as char.
def var v-exist as char.
def var v-exist1 as char.
def var v-errtext as char.
def var v-mlist as char.
def var v-str1 as char.
def var v-chk as logi init true.

find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> "superman" then message "Не найден параметр lbeks в sysc!" view-as alert-box.
   else run log_write("Не найден параметр lbeks в sysc!").
   return.
end.

k = 0.
if connected ("txb") then disconnect "txb".
bank:
for each txb where txb.consolid = true no-lock:
  if connected ("txb") then disconnect "txb".
  connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') +  " -ld txb -U " + txb.login + " -P " + txb.password).
  run MT998aaa20(output v-mlist).
  disconnect "txb".
  v-errtext = "".

  find first t-acc no-lock no-error.
  if avail t-acc then do:
    for each t-acc:
      if not v-bin then do:
          if trim(t-acc.rnn) = "" then do:
            if v-errtext <> "" then v-errtext = v-errtext + "\\n".
            v-errtext = v-errtext + "У клиента отсутствует РНН! Филиал: " + txb.name + " Номер счета клиента: " + t-acc.acc.
            delete t-acc.
          end.
      end.
      else do:
          if trim(t-acc.bin) = "" then do:
            if v-errtext <> "" then v-errtext = v-errtext + "\\n".
            v-errtext = v-errtext + "У клиента отсутствует ИИН/БИН! Филиал: " + txb.name + " Номер счета клиента: " + t-acc.acc.
            delete t-acc.
          end.
      end.
    end.
  end.

  find first t-acc no-lock no-error.
  if avail t-acc then do:
    find first acclet-detail where acclet-detail.dtout = g-today and acclet-detail.bank= txb.bank and acclet-detail.opertype = '3' use-index dtoutbnk no-lock no-error.
    if avail acclet-detail then do:
        if g-ofc <> "superman" then message "МТ998.400 на " string(g-today) " уже созданы! " txb.name view-as alert-box.
        else run log_write("МТ998.400 на " + string(g-today,'99/99/9999') + " уже созданы! " + txb.name).
        next bank.
    end.

    k = k + 1.
    run header.
    i = 0.
    for each t-acc:
      if (t-acc.rnn <> "" and v-bin = false) or (t-acc.bin <> "" and v-bin = true) then do:
         i = i + 1.
         if i = 101 then run footer.
         if v-bin then
            v-text = "/ACCOUNT/" + t-acc.bik  + "/" + t-acc.acc9 + "/" + v-clecod + "/" + t-acc.acc + "/" + t-acc.acctype + "/" + string(year(t-acc.dt) mod 1000,'99') + string(month(t-acc.dt),'99') + string(day(t-acc.dt),'99')  + "/"  + t-acc.bin.
         else
            v-text = "/ACCOUNT/" + t-acc.bik  + "/" + t-acc.acc9 + "/" + v-clecod + "/" + t-acc.acc + "/" + t-acc.acctype + "/" + string(year(t-acc.dt) mod 1000,'99') + string(month(t-acc.dt),'99') + string(day(t-acc.dt),'99')  + "/"  + t-acc.rnn.
         put stream mt400 unformatted skip v-text.
         find first acclet-detail where acclet-detail.bik = t-acc.bik and acclet-detail.opertype = t-acc.opertype and acclet-detail.acc = t-acc.acc use-index bikacc no-lock no-error.
         if not avail acclet-detail then do:
           create acclet-detail.
           assign acclet-detail.accleters = "ACC" + string(v-mt400-n,'999999')
                  acclet-detail.jame = t-acc.jame
                  acclet-detail.acc = t-acc.acc
                  acclet-detail.opertype = t-acc.opertype
                  acclet-detail.acctype = t-acc.acctype
                  acclet-detail.dtout = g-today
                  acclet-detail.outtime = time
                  acclet-detail.bank = txb.bank
                  acclet-detail.bik = t-acc.bik
                  acclet-detail.accdt = t-acc.dt
                  acclet-detail.info = t-acc.acc9.
         end.

      end.
    end.
    if i > 0 then run footer.

  end.
  if trim(v-errtext) <> "" and trim(v-mlist) <> "" then do j = 1 to num-entries(v-mlist):
    message v-errtext view-as alert-box.
    run mail(entry(j,v-mlist) + "@metrocombank.kz","METROCOMBANK <abpk@metrocombank.kz>", "Ошибки  формирования уведомлений об изменении банковских номеров счетов", v-errtext, "", "","").
  end.
end.


/*отправка письма ДПС*/
find first acclet-detail where acclet-detail.dtout = g-today use-index dtoutbnk no-lock no-error.
if avail acclet-detail then do:
  find sysc where sysc.sysc = "MT998mail" no-lock no-error.
  if avail sysc then do j = 1 to num-entries(sysc.chval):
    run mail(entry(j,sysc.chval) + "@metrocombank.kz","METROCOMBANK <abpk@metrocombank.kz>", "Уведомление об изменении номеров банковских счетов", "Количество уведомлений: " + string(k) + " \n " + "Каталог: L:/TERMINAL/IN"  , "", "","").
  end.
end.

procedure header.
    v-mt400-n = next-value(mt998aaa20-n).

    output stream mt400 to value(v-file0).

    v-text = "\{1:F01K054700000000010002536\}".
    put stream mt400 unformatted v-text skip.

    v-text = "\{2:I998KNALOG000000N2020\}".
    put stream mt400 unformatted v-text skip.

    v-text = "\{4:".
    put stream mt400 unformatted v-text skip.

    v-text = ":20:ACC" + string(v-mt400-n,'999999') .
    put stream mt400 unformatted v-text skip.

    v-text = ":12:400".
    put stream mt400 unformatted v-text skip.

    v-text = ":77E:FORMS/A03/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + "/Увед. об изменении банковских счетов".
    put stream mt400 unformatted v-text.
end procedure.

procedure footer.
    put stream mt400 unformatted skip.

    v-text = "-\}".
    put stream mt400 unformatted v-text.

    output stream mt400 close.

    v-file = "ACC" + string(v-mt400-n,'999999') + ".txt".

    unix silent value("un-win1 " + v-file0 + " " + v-file).

    /*0для теста v-mt400out = "Administrator@db01:C:/STAT/NK/OUT".*/
    /* для реального сервера
    v-mt400out = "Administrator@db01:C:/CAPITAL/terminal/IN".*/
    v-mt400out = "Administrator@db01:" + sysc.chval + "IN".
    /*проверка на выгрузку уведомлений на этот день*/

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
        v-mt400outarc = "/data/export/mt998aaa20/" + string(g-today,'99.99.99').
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
        unix silent rm -f value (v-file).
        unix silent rm -f value (v-file0).
        if i = 101 then do:
          i = 0.
          run header.
        end.
    end.

   hide all no-pause.
end procedure.


procedure log_write.
def input parameter p-err as char.
     /*запись в логфайл*/
     input through value( "find /data/log/MT998aaa20out_err.log;echo $?").
     repeat:
       import unformatted v-exist1.
     end.
     if v-exist1 <> "0" then do:
       output stream err to value("/data/log/MT998aaa20out_err.log").
       put stream err "Журнал ошибок при выгрузке МТ988.400 по 20-тизначным счетам" skip(3).
     end.
     else output stream err to value("/data/log/MT998aaa20out_err.log") append .
     put stream err unformatted string(g-today,"99/99/99") + ", " +  string(time,"hh:mm:ss" ) +  " " + p-err skip.
     output stream err close.
 end.



