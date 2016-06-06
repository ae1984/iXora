/* MT998aaaa20h.p
 * MODULE
       Платежная система
 * DESCRIPTION
        формирование уведомления об изменение номера счета юр лиц
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        05/02/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        10/02/2010 galina - добавила информационные сообщения
        17/03/2010 galina - добавила счета гарантии  397 и 396
        31/03/2010 galina - добавила группы счетов 160,161,247,248
        17.01.11 evseev  - добавил группы счетов Недропользователь 518,519,520
        23/09/2011 evseev  - переход на ИИН/БИН
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор

*/
{global.i}
{chbin.i}

def input parameter p-acc as char.
def var v-bik as char.

{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

def var v-acctype as char.
def var v-opertype as char.
def var v-dt as date.

def var v-mt400-n as integer.
def var v-mt400out as char.
def var v-mt400outarc as char.

def var j as integer.

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
def var v-bank as char.
def var v-str1 as char.


find first sysc where sysc.sysc = 'ourbnk' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> 'superman' then message "Не найден параметр ourbnk в sysc!" view-as alert-box.
   return.
end.
v-bank = sysc.chval.

find first sysc where sysc.sysc = 'CLECOD' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> 'superman' then message "Не найден параметр CLECOD в sysc!" view-as alert-box.
   return.
end.
v-bik = sysc.chval.


find first aaa where aaa.aaa = p-acc no-lock no-error.
if lookup(aaa.lgr,"437,478,479,480,481,482,483,484,485,486,487,488,489,237,151,152,153,154,155,156,157,158,171,172,173,174,204,202,208,222,232,242,101,111,194,195,397,396,160,161,247,248,518,519,520") = 0 then return.
if aaa.aaa20 = '' then next.
find last cif where cif.cif = aaa.cif no-lock no-error.
if cif.type = "p" and cif.geo <> '022' then do:
  if g-ofc <> 'superman' then message "Клиент должен быть нерезидентом или юр. лицом!" view-as alert-box.
  return.
end.
if v-bin then do:
    if trim(cif.bin) = '' then do:
       if g-ofc <> 'superman' then message "У клиента нет БИН!" view-as alert-box.
      return.
    end.
end.
else do:
    if trim(cif.jss) = '' then do:
       if g-ofc <> 'superman' then message "У клиента нет РНН!" view-as alert-box.
      return.
    end.
end.

v-opertype = '3'.

if aaa.lgr begins "4" then v-acctype = '05'.
else v-acctype = '20'.

v-dt = aaa.regdt.

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
put stream mt400 unformatted v-text /*skip*/.

if v-bin then
    v-text = "/ACCOUNT/" + v-bik  + "/" + aaa.aaa + "/" + v-clecod + "/" + aaa.aaa20 + "/" + v-acctype + "/" + string(year(v-dt) mod 1000,'99') + string(month(v-dt),'99') + string(day(v-dt),'99')  + "/"  + cif.bin.
else
    v-text = "/ACCOUNT/" + v-bik  + "/" + aaa.aaa + "/" + v-clecod + "/" + aaa.aaa20 + "/" + v-acctype + "/" + string(year(v-dt) mod 1000,'99') + string(month(v-dt),'99') + string(day(v-dt),'99')  + "/"  + cif.jss.
put stream mt400 unformatted skip v-text.


v-text = "-\}".
put stream mt400 unformatted skip v-text.

output stream mt400 close.

v-file = "ACC" + string(v-mt400-n,'999999') + ".txt".

unix silent value("un-win1 " + v-file0 + " " + v-file).

find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> 'superman' then message "Не найден параметр lbeks в sysc!" view-as alert-box.
   return.
end.

/*для теста v-mt400out = "Administrator@db01:C:/STAT/NK/OUT".*/
/* для реального сервера*/
v-mt400out = "Administrator@db01:" + sysc.chval + "IN".
/*Копирование в каталог исходящих телеграмм**/
input through value("scp -q " + v-file + " " + v-mt400out + ";echo $?").
repeat:
  import unformatted v-str.
end.
if v-str <> "0" then    message v-str + " Ошибка копирования в " + v-mt400out view-as alert-box.
else do:
  find first acclet-detail where acclet-detail.bik = v-bik and acclet-detail.opertype = v-opertype and acclet-detail.acc = p-acc use-index bikacc no-lock no-error.
  if not avail acclet-detail then do:
     create acclet-detail.
     assign acclet-detail.accleters = "ACC" + string(v-mt400-n,'999999')
            acclet-detail.jame = cif.jame
            acclet-detail.acc = aaa.aaa20
            acclet-detail.opertype = v-opertype
            acclet-detail.acctype = v-acctype
            acclet-detail.dtout = g-today
            acclet-detail.outtime = time
            acclet-detail.bank = v-bank
            acclet-detail.bik = v-bik
            acclet-detail.accdt = v-dt
            acclet-detail.info = aaa.aaa.
   end.
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
   if g-ofc <> 'superman' then message "Создано МТ998.400!" view-as alert-box.

   unix silent rm -f value (v-file).
   unix silent rm -f value (v-file0).

end.


/*отправка письма ДПС*/
find first acclet-detail where acclet-detail.dtout = g-today use-index dtoutbnk no-lock no-error.
if avail acclet-detail then do:
  find sysc where sysc.sysc = "MT998mail" no-lock no-error.
  if avail sysc then do j = 1 to num-entries(sysc.chval):
    run mail(entry(j,sysc.chval) + "@metrocombank.kz","METROCOMBANK <abpk@metrocombank.kz>", "Уведомление об открытие/закрытие счетов юр. лиц", "Количество уведомлений: " + string(1) + " \n " + "Каталог: L:/TERMINAL/IN"  , "", "","").
  end.
end.



