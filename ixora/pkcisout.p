/* pkcisout.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Запрос и получение ответа из ЦИС
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
        07/04/2005 madiyar
 * CHANGES
        08/04/2005 madiyar - временно (в тестовом режиме) убрал проверку, разрешены ли запросы в ЦИС
                             корректировка формата отчета
        12/04/2005 madiyar - справочники улиц
        18/04/2005 madiyar - включил проверку, разрешены ли запросы в ЦИС
        11/05/2005 madiyar - добавил pk0.i для автоматической перекомпиляции
        18/05/2005 madiyar - стандартизованный вывод даты
                             для интернет-анкеты - отключение сообщений
        19/05/2005 madiyar - если не находит t-anket - сообщение
        20/05/2005 madiyar - текст для "akires" t-anket.value2 передается через шаренную переменную v-cisres
                             для интернет-анкет улицы не по справочнику
        24/05/2005 madiyar - исправил ошибку с инет-анкетами
        07/06/2005 madiyar - во втором запросе - дата через "/"
        24/04/2007 madiyar - определение веб-анкет по полю pkanketa.id_org
        25/04/2007 madiyar - не выводился отчет при вводе анкеты, исправил
        04/06/2007 madiyar - запросы pkcisq1 и pkcisq2 возвращают id клиентов слишком большие для типа integer, сделал char
        12/09/2007 madiyar - pkanketa.id_org - (веб-анкеты обоих типов - "inet" и "wclient")
        19/09/2007 madiyar - для анкет id_org = "wclient" отчет никуда не копируем
        20/09/2007 madiyar - при вводе анкеты в иксору записи pkanketa еще нет, запрос не посылался; исправил
        28/10/2008 madiyar - отредактировал в связи с переходом на новую кодировку
        28/11/2008 madiyar - отправляться инфа должна в koi8r
*/

{global.i}
{pk.i}
{w-2-u.i}

def shared var v-cisres as char.
v-cisres = ''.

def var v-inet as char no-undo init ''.
find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if avail pkanketa then v-inet = pkanketa.id_org.

/* проверить, разрешен ли запрос в АКИ */
find first sysc where sysc.sysc = "pkakiy" no-lock no-error.
if not avail sysc or not sysc.loval then do:
  if v-inet = '' then message skip " Запрос данных в ЦИС в данный момент не работает! " skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
  return.
end.

def var v-str as char no-undo.
def var v-akifile as char no-undo.
def var v-akidirq as char no-undo.
def var v-akidira as char no-undo.
/*def var v-akidir as char no-undo.*/
def var v-akiscr as char no-undo.
def var v-akires as char no-undo.
def var v-qid as char no-undo.

def var time_st as integer no-undo.
def var time_end as integer no-undo.

def var cl_id as char no-undo.
def var cl_name as char no-undo.
def var usrnm as char no-undo.

def var dt as date no-undo.

def stream aki.
def stream aki_rep.

def shared temp-table t-anket like pkanketh.

/* референс запроса   ггггммдд_время_РНН   */

find t-anket where t-anket.kritcod = "rnn" no-error.
if avail t-anket then v-str = t-anket.value1.
else do:
  if v-inet = '' then message skip " Не найден РНН! " skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
  return.
end.
v-qid = string(year(today), "9999") + string(month(today), "99") + string(day(today), "99") + "_" + 
        string(time) + "_" + v-str.

{sysc.i}

v-akidirq = get-sysc-cha ("pkakiq").
v-akidira = get-sysc-cha ("pkakia").
v-akiscr = get-sysc-cha ("pkakis").
/*v-akidir = substr(v-akiscr, 1, r-index(v-akiscr, "/") - 1).*/

if substr(v-akidirq,length(v-akidirq),1) <> "/" then v-akidirq = v-akidirq + "/".
if substr(v-akidira,length(v-akidira),1) <> "/" then v-akidira = v-akidira + "/".
if substr(v-akiscr,length(v-akiscr),1) <> "/" then v-akiscr = v-akiscr + "/".

/* Подготовка каталогов для запросов - ответов */

unix silent value ("if [ ! -d " + v-akidirq + string(year(today)) + " ]; then mkdir " + v-akidirq + string(year(today)) + "; chmod a+rx " + v-akidirq + string(year(today)) + "; fi").
unix silent value ("if [ ! -d " + v-akidirq + string(year(today)) + "/" + string(month(today)) + " ]; then mkdir " + v-akidirq + string(year(today)) + "/" + string(month(today)) + "; chmod a+rx " + v-akidirq + string(year(today)) + "/" + string(month(today)) + "; fi").
unix silent value ("if [ ! -d " + v-akidira + string(year(today)) + " ]; then mkdir " + v-akidira + string(year(today)) + "; chmod a+rx " + v-akidira + string(year(today)) + "; fi").
unix silent value ("if [ ! -d " + v-akidira + string(year(today)) + "/" + string(month(today)) + " ]; then mkdir " + v-akidira + string(year(today)) + "/" + string(month(today)) + "; chmod a+rx " + v-akidira + string(year(today)) + "/" + string(month(today)) + "; fi").

v-akidirq = v-akidirq + string(year(today)) + "/" + string(month(today)) + "/".
v-akidira = v-akidira + string(year(today)) + "/" + string(month(today)) + "/".


v-cisres = string(year(today)) + "/" + string(month(today)) + "/" + "," + v-qid.


output stream aki_rep to pkcisout.htm.
put stream aki_rep unformatted
    "<!-- Отчет по запросу в ЦИС -->" skip
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

find first t-anket where t-anket.kritcod = "lname" no-lock no-error.
if avail t-anket then cl_name = caps(trim(t-anket.value1)).
find first t-anket where t-anket.kritcod = "fname" no-lock no-error.
if avail t-anket then cl_name = cl_name + ' ' + caps(trim(t-anket.value1)).
find first t-anket where t-anket.kritcod = "mname" no-lock no-error.
if avail t-anket then if trim(t-anket.value1) <> '' then cl_name = cl_name + ' ' + caps(trim(t-anket.value1)).
find first t-anket where t-anket.kritcod = "rnn" no-lock no-error. 
put stream aki_rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Отчет по запросу в ЦИС</b></center><BR><BR><BR>" skip
    "<b>Клиент:</b> " cl_name "<BR>" skip
    "<b>РНН:</b> " trim(t-anket.value1) "<BR><BR>" skip.

v-akifile = v-akidirq + "q_" + v-qid + "_1".
v-akires  = v-akidira + "a_" + v-qid + "_1".

output stream aki to value(v-akifile).

find first t-anket where t-anket.kritcod = "numpas" no-lock no-error. 
if not avail t-anket then
  if v-inet = '' then
      message skip " Критерий <Номер документа> не найден! " skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".

put stream aki unformatted
  "login=" get-sysc-cha("pkakil") skip
  "password=" get-sysc-cha("pkakip") skip
  "documentType=3"  skip
  "documentNumber=" trim(t-anket.value1) skip.

output stream aki close.

time_st = time.

input through value(v-akiscr + "simple_doc_ok.pl " + v-akifile + " | koi2win > " + v-akires + ";echo $?").

repeat:
  import v-str.
end.
pause 0.

time_end = time.

if v-str <> "0" then do:
  if v-inet = '' then message skip " Ошибка при проверке сведений в ЦИС! " skip(1) view-as alert-box button ok title " ОШИБКА ".
  return.
end.

put stream aki_rep unformatted
    "<b>Запрос по номеру документа:</b><BR>" skip
    "Время отправки запроса: " string(time_st,"HH:MM:SS") "<BR>" skip
    "Время получения ответа: " string(time_end,"HH:MM:SS") "<BR>" skip
    "Период: " time_end - time_st " секунд(ы)<BR>" skip.
output stream aki_rep close.

v-cisres = v-cisres + "," + trim(string(time_st)) + "," + trim(string(time_end)).

run pkcisq1(v-akires, output cl_id).

/* если анализ ответа вернул id = "-1" (клиент по номеру документа не найден) посылаем запрос по имени/дате рождения */
if cl_id = "-1" then do:
    
    v-akifile = v-akidirq + "q_" + v-qid + "_2".
    v-akires  = v-akidira + "a_" + v-qid + "_2".
    
    output stream aki to value(v-akifile).
    
    put stream aki unformatted
      "login=" get-sysc-cha("pkakil") skip
      "password=" get-sysc-cha("pkakip") skip.
    
    find first t-anket where t-anket.kritcod = "lname" no-lock no-error. 
    if avail t-anket then do:
      put stream aki unformatted "surname=" w-2-u(caps(trim(t-anket.value1))) skip.
    end.
    else do:
      if v-inet = '' then
        message skip " Критерий <Фамилия> не найден! " skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
    end.
    
    find first t-anket where t-anket.kritcod = "fname" no-lock no-error. 
    if avail t-anket then do:
      put stream aki unformatted "name=" w-2-u(caps(trim(t-anket.value1))) skip.
    end.
    else do:
      if v-inet = '' then
        message skip " Критерий <Имя> не найден! " skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
    end.
    
    find first t-anket where t-anket.kritcod = "mname" no-lock no-error. 
    if avail t-anket then do:
      put stream aki unformatted "patronymic=" w-2-u(caps(trim(t-anket.value1))) skip.
    end.
    else do:
      if v-inet = '' then
        message skip " Критерий <Отчество> не найден! " skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
    end.
    
    find first t-anket where t-anket.kritcod = "bdt" no-lock no-error. 
    if avail t-anket then do:
      dt = date(trim(t-anket.value1)).
      put stream aki unformatted
        "birthDate=" string(day(dt),"99") "/" string(month(dt),"99") "/" string(year(dt),"9999") skip.
    end.
    else do:
      if v-inet = '' then
        message skip " Критерий <Дата рождения> не найден! " skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
    end.
    
    output stream aki close.
    
    time_st = time.
    
    input through value(v-akiscr + "simple_person_data_ok.pl " + v-akifile + " | koi2win > " + v-akires + ";echo $?").
    
    repeat:
      import v-str.
    end.
    pause 0.
    
    time_end = time.
    
    if v-str <> "0" then do:
      message skip " Ошибка при проверке сведений в ЦИС! " skip(1) view-as alert-box button ok title " ОШИБКА ".
      return.
    end.
    
    output stream aki_rep to pkcisout.htm append.
    put stream aki_rep unformatted
      "<b>Запрос по ФИО и дате рождения:</b><BR>" skip
      "Время отправки запроса: " string(time_st,"HH:MM:SS") "<BR>" skip
      "Время получения ответа: " string(time_end,"HH:MM:SS") "<BR>" skip
      "Период: " time_end - time_st " секунд(ы)<BR>" skip.
    output stream aki_rep close.
    
    v-cisres = v-cisres + "," + trim(string(time_st)) + "," + trim(string(time_end)).
    
    run pkcisq2(v-akires, output cl_id).
    
end.

if cl_id = "-1" then do:
  if v-inet = '' then unix silent cptwin pkcisout.htm excel.
  return.
end.


v-akifile = v-akidirq + "q_" + v-qid + "_3".
v-akires  = v-akidira + "a_" + v-qid + "_3".

output stream aki to value(v-akifile).

put stream aki unformatted
  "login=" get-sysc-cha("pkakil") skip
  "password=" get-sysc-cha("pkakip") skip
  "id=" cl_id skip.

find first pkkrit where pkkrit.kritcod = "street1" no-lock no-error.
find first t-anket where t-anket.kritcod = "street1" no-lock no-error.
if avail t-anket and trim(t-anket.value1) <> '' then do:
  if v-inet = '' then do:
    find first codfr where codfr.codfr = pkkrit.kritspr and codfr.code = t-anket.value1 no-lock no-error.
    put stream aki unformatted "residence_streetName=" w-2-u(caps(trim(codfr.name[1]))) skip.
  end.
  else do:
    put stream aki unformatted "residence_streetName=" w-2-u(caps(trim(t-anket.value1))) skip.
  end.
end.
else do:
  if v-inet = '' then message skip " Критерий <Прописка - Улица> не найден !" skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
  put stream aki unformatted "residence_streetName=" skip.
end.

find first t-anket where t-anket.kritcod = "house1" no-lock no-error.
if avail t-anket then do:
  put stream aki unformatted "residence_houseNumber=" caps(trim(t-anket.value1)) skip.
end.
else do:
  if v-inet = '' then
     message skip " Критерий <Прописка - Дом> не найден !" skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
  put stream aki unformatted "residence_houseNumber=" skip.
end.

find first t-anket where t-anket.kritcod = "apart1" no-lock no-error.
if avail t-anket then do:
  put stream aki unformatted "residence_flatNumber=" caps(trim(t-anket.value1)) skip.
end.
else do:
  if v-inet = '' then
     message skip " Критерий <Прописка - Квартира> не найден !" skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
  put stream aki unformatted "residence_flatNumber=" skip.
end.

find first pkkrit where pkkrit.kritcod = "nedvstreet" no-lock no-error.
find first t-anket where t-anket.kritcod = "nedvstreet" no-lock no-error.
if avail t-anket then do:
  if t-anket.value1 <> '' then do:
    if v-inet = '' then do:
      find first codfr where codfr.codfr = pkkrit.kritspr and codfr.code = t-anket.value1 no-lock no-error.
      put stream aki unformatted "realty_streetName=" w-2-u(caps(trim(codfr.name[1]))) skip.
    end.
    else do:
      put stream aki unformatted "realty_streetName=" w-2-u(caps(trim(t-anket.value1))) skip.
    end.
  end.
end.

find first t-anket where t-anket.kritcod = "nedvhouse" no-lock no-error.
if avail t-anket then do:
  if t-anket.value1 <> '' then put stream aki unformatted "realty_houseNumber=" caps(trim(t-anket.value1)) skip.
end.

find first t-anket where t-anket.kritcod = "nedvapart" no-lock no-error.
if avail t-anket then do:
  if t-anket.value1 <> '' then put stream aki unformatted "realty_flatNumber=" caps(trim(t-anket.value1)) skip.
end.

output stream aki close.

time_st = time.

input through value(v-akiscr + "simple_comparison_ok.pl " + v-akifile + " | koi2win > " + v-akires + ";echo $?").

repeat:
  import v-str.
end.
pause 0.

time_end = time.

if v-str <> "0" then do:
  if v-inet = '' then message skip " Ошибка при проверке сведений в ЦИС! " skip(1) view-as alert-box button ok title " ОШИБКА ".
  return.
end.

output stream aki_rep to pkcisout.htm append.
put stream aki_rep unformatted
   "<b>Запрос по недвижимости:</b><BR>" skip
   "Время отправки запроса: " string(time_st,"HH:MM:SS") "<BR>" skip
   "Время получения ответа: " string(time_end,"HH:MM:SS") "<BR>" skip
   "Период: " time_end - time_st " секунд(ы)<BR>" skip.
output stream aki_rep close.

v-cisres = v-cisres + "," + trim(string(time_st)) + "," + trim(string(time_end)).

run pkcisq3(v-akires).

if v-inet = '' then unix silent cptwin pkcisout.htm excel.
else if v-inet = "inet" then unix silent value("mv pkcisout.htm /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/pkcisout.htm").

